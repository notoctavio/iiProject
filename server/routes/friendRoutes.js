const express = require('express');
const router = express.Router();
const User = require('../models/User');
const FriendRequest = require('../models/FriendRequest');
const auth = require('../middleware/auth');

// Get all users (excluding current user and existing friends)
router.get('/users', auth, async (req, res) => {
    try {
        const currentUser = await User.findById(req.user.id);
        const users = await User.find({
            _id: { 
                $nin: [...currentUser.friends, req.user.id] 
            }
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
    try {
        const request = await FriendRequest.findOne({
            _id: req.params.requestId,
            receiver: req.user.id,
            status: 'pending'
        });

        if (!request) {
            return res.status(404).json({ error: 'Friend request not found' });
        }

        // Update request status
        request.status = 'accepted';
        await request.save();

        // Add each user to the other's friends list
        await User.findByIdAndUpdate(req.user.id, {
            $addToSet: { friends: request.sender }
        });
        await User.findByIdAndUpdate(request.sender, {
            $addToSet: { friends: req.user.id }
        });

        res.json({ message: 'Friend request accepted' });
    } catch (error) {
        res.status(500).json({ error: 'Error accepting friend request' });
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

module.exports = router; 