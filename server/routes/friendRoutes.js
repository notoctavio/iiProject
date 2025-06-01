const express = require('express');
const router = express.Router();
const User = require('../models/User');
const FriendRequest = require('../models/FriendRequest');
const Transaction = require('../models/Transaction');
const auth = require('../middleware/auth');
const mongoose = require('mongoose');

// Get all users (excluding current user and existing friends)
router.get('/users', auth, async (req, res) => {
    try {
        const currentUser = await User.findById(req.user.id);
        const searchTerm = req.query.search || '';
        
        // Create search query
        const searchQuery = searchTerm ? {
            $or: [
                { fullName: { $regex: searchTerm, $options: 'i' } },
                { email: { $regex: searchTerm, $options: 'i' } }
            ]
        } : {};

        const users = await User.find({
            _id: { 
                $nin: [...currentUser.friends, req.user.id] 
            },
            ...searchQuery
        }).select('fullName email');
        
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: 'Error fetching users' });
    }
});

// Get friend requests
router.get('/requests', auth, async (req, res) => {
    try {
        const requests = await FriendRequest.find({
            receiver: req.user.id,
            status: 'pending'
        }).populate('sender', 'fullName email');
        res.json(requests);
    } catch (error) {
        res.status(500).json({ error: 'Error fetching friend requests' });
    }
});

// Send friend request
router.post('/request/:userId', auth, async (req, res) => {
    try {
        const receiver = await User.findById(req.params.userId);
        if (!receiver) {
            return res.status(404).json({ error: 'User not found' });
        }

        const friendRequest = new FriendRequest({
            sender: req.user.id,
            receiver: req.params.userId
        });

        await friendRequest.save();
        res.json(friendRequest);
    } catch (error) {
        if (error.code === 11000) {
            res.status(400).json({ error: 'Friend request already sent' });
        } else {
            res.status(500).json({ error: 'Error sending friend request' });
        }
    }
});

// Accept friend request
router.post('/accept/:requestId', auth, async (req, res) => {
    console.log('Accepting friend request:', {
        requestId: req.params.requestId,
        userId: req.user.id
    });

    try {
        // First verify the request exists and belongs to the current user
        const request = await FriendRequest.findOne({
            _id: req.params.requestId,
            receiver: req.user.id,
            status: 'pending'
        });

        console.log('Found friend request:', request);

        if (!request) {
            console.log('Friend request not found or already processed');
            return res.status(404).json({ error: 'Friend request not found or already processed' });
        }

        // Start a session for transaction
        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            // Update request status
            request.status = 'accepted';
            await request.save({ session });

            // Get both users
            const [currentUser, senderUser] = await Promise.all([
                User.findById(req.user.id).session(session),
                User.findById(request.sender).session(session)
            ]);

            if (!currentUser || !senderUser) {
                throw new Error('One or both users not found');
            }

            // Add each user to the other's friends list
            await Promise.all([
                User.findByIdAndUpdate(
                    currentUser._id,
                    { $addToSet: { friends: senderUser._id } },
                    { session, new: true }
                ),
                User.findByIdAndUpdate(
                    senderUser._id,
                    { $addToSet: { friends: currentUser._id } },
                    { session, new: true }
                )
            ]);

            // Commit the transaction
            await session.commitTransaction();
            console.log('Friend request accepted successfully');

            res.json({
                success: true,
                message: 'Friend request accepted',
                requestId: request._id,
                senderId: request.sender,
                receiverId: request.receiver
            });
        } catch (error) {
            // If anything fails, abort the transaction
            await session.abortTransaction();
            throw error;
        } finally {
            session.endSession();
        }
    } catch (error) {
        console.error('Error accepting friend request:', {
            error: error.message,
            stack: error.stack,
            requestId: req.params.requestId,
            userId: req.user.id
        });
        res.status(500).json({
            error: 'Error accepting friend request',
            details: error.message
        });
    }
});

// Reject friend request
router.post('/reject/:requestId', auth, async (req, res) => {
    try {
        const request = await FriendRequest.findOne({
            _id: req.params.requestId,
            receiver: req.user.id,
            status: 'pending'
        });

        if (!request) {
            return res.status(404).json({ error: 'Friend request not found' });
        }

        request.status = 'rejected';
        await request.save();
        res.json({ message: 'Friend request rejected' });
    } catch (error) {
        res.status(500).json({ error: 'Error rejecting friend request' });
    }
});

// Get friends list
router.get('/friends', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).populate('friends', 'fullName email');
        res.json(user.friends);
    } catch (error) {
        res.status(500).json({ error: 'Error fetching friends' });
    }
});

// Create a new transaction (split payment)
router.post('/transaction', auth, async (req, res) => {
    try {
        const { friendId, description, amount, splitType, splitPercentage } = req.body;
        
        // Verify friend relationship
        const user = await User.findById(req.user.id);
        if (!user.friends.includes(friendId)) {
            return res.status(400).json({ error: 'User is not your friend' });
        }

        // Calculate the actual amount based on split type
        let actualAmount = parseFloat(amount);
        let payerAmount, payeeAmount;

        switch (splitType) {
            case '50-50':
                payerAmount = actualAmount / 2;
                payeeAmount = actualAmount / 2;
                break;
            case 'payer-full':
                payerAmount = actualAmount;
                payeeAmount = 0;
                break;
            case 'payee-full':
                payerAmount = 0;
                payeeAmount = actualAmount;
                break;
            case 'custom':
                if (!splitPercentage || splitPercentage < 0 || splitPercentage > 100) {
                    return res.status(400).json({ error: 'Invalid split percentage' });
                }
                payerAmount = (actualAmount * splitPercentage) / 100;
                payeeAmount = actualAmount - payerAmount;
                break;
            default:
                return res.status(400).json({ error: 'Invalid split type' });
        }

        const transaction = new Transaction({
            description,
            amount: actualAmount,
            splitType,
            splitPercentage: splitType === 'custom' ? splitPercentage : undefined,
            payer: req.user.id,
            payee: friendId,
            status: 'pending'
        });

        await transaction.save();
        
        // Populate user details for response
        await transaction.populate('payer payee', 'fullName email');
        
        res.json(transaction);
    } catch (error) {
        console.error('Transaction creation error:', error);
        res.status(500).json({ error: 'Error creating transaction' });
    }
});

// Get all transactions for current user
router.get('/transactions', auth, async (req, res) => {
    try {
        const transactions = await Transaction.find({
            $or: [
                { payer: req.user.id },
                { payee: req.user.id }
            ]
        })
        .populate('payer payee', 'fullName email')
        .sort({ createdAt: -1 });

        res.json(transactions);
    } catch (error) {
        res.status(500).json({ error: 'Error fetching transactions' });
    }
});

// Get transactions with a specific friend
router.get('/transactions/:friendId', auth, async (req, res) => {
    try {
        const transactions = await Transaction.find({
            $or: [
                { payer: req.user.id, payee: req.params.friendId },
                { payer: req.params.friendId, payee: req.user.id }
            ]
        })
        .populate('payer payee', 'fullName email')
        .sort({ createdAt: -1 });

        res.json(transactions);
    } catch (error) {
        res.status(500).json({ error: 'Error fetching transactions' });
    }
});

// Update transaction status (mark as completed)
router.put('/transaction/:transactionId', auth, async (req, res) => {
    try {
        const transaction = await Transaction.findOne({
            _id: req.params.transactionId,
            $or: [
                { payer: req.user.id },
                { payee: req.user.id }
            ]
        });

        if (!transaction) {
            return res.status(404).json({ error: 'Transaction not found' });
        }

        transaction.status = 'completed';
        await transaction.save();

        res.json(transaction);
    } catch (error) {
        res.status(500).json({ error: 'Error updating transaction' });
    }
});

// Get friend balances (how much they owe you or you owe them)
router.get('/balances', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).populate('friends', 'fullName email');
        const balances = [];

        for (const friend of user.friends) {
            const transactions = await Transaction.find({
                $or: [
                    { payer: req.user.id, payee: friend._id },
                    { payer: friend._id, payee: req.user.id }
                ],
                status: 'pending'
            });

            let balance = 0;
            transactions.forEach(transaction => {
                if (transaction.payer.toString() === req.user.id) {
                    // You paid, friend owes you
                    balance += transaction.amount;
                } else {
                    // Friend paid, you owe them
                    balance -= transaction.amount;
                }
            });

            balances.push({
                friend: {
                    _id: friend._id,
                    fullName: friend.fullName,
                    email: friend.email
                },
                balance
            });
        }

        res.json(balances);
    } catch (error) {
        res.status(500).json({ error: 'Error calculating balances' });
    }
});

module.exports = router; 