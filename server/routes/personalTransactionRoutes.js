const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const PersonalTransaction = require('../models/PersonalTransaction');
const mongoose = require('mongoose');

// Get all transactions for the current user
router.get('/', auth, async (req, res) => {
    try {
        const transactions = await PersonalTransaction.find({ user: req.user._id })
            .sort({ date: -1 });
        res.json(transactions);
    } catch (error) {
        console.error('Error fetching transactions:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get current balance
router.get('/balance', auth, async (req, res) => {
    try {
        console.log('Calculating balance for user:', req.user.id);
        
        const startOfMonth = new Date();
        startOfMonth.setDate(1);
        startOfMonth.setHours(0, 0, 0, 0);

        const endOfMonth = new Date();
        endOfMonth.setMonth(endOfMonth.getMonth() + 1);
        endOfMonth.setDate(0);
        endOfMonth.setHours(23, 59, 59, 999);

        console.log('Date range:', {
            startOfMonth: startOfMonth.toISOString(),
            endOfMonth: endOfMonth.toISOString()
        });

        // Calculate total income for the month
        const incomeResult = await PersonalTransaction.aggregate([
            {
                $match: {
                    user: new mongoose.Types.ObjectId(req.user.id),
                    type: 'income',
                    date: { $gte: startOfMonth, $lte: endOfMonth }
                }
            },
            {
                $group: {
                    _id: null,
                    total: { $sum: '$amount' }
                }
            }
        ]);

        const monthlyIncome = incomeResult[0]?.total || 0;
        console.log('Monthly income calculated:', monthlyIncome);

        // Calculate expenses including subscriptions
        const expenses = await PersonalTransaction.aggregate([
            {
                $match: {
                    user: new mongoose.Types.ObjectId(req.user.id),
                    type: 'expense',
                    $or: [
                        {
                            date: { $gte: startOfMonth, $lte: endOfMonth },
                            isSubscription: { $ne: true }
                        },
                        {
                            isSubscription: true,
                            'subscriptionDetails.nextBillingDate': { $gte: startOfMonth, $lte: endOfMonth }
                        }
                    ]
                }
            },
            {
                $group: {
                    _id: null,
                    total: { $sum: '$amount' }
                }
            }
        ]);

        const totalExpenses = expenses[0]?.total || 0;
        const balance = monthlyIncome - totalExpenses;

        console.log('Monthly balance calculation:', {
            userId: req.user.id,
            monthlyIncome,
            totalExpenses,
            balance
        });

        res.json({ balance });
    } catch (err) {
        console.error('Error calculating balance:', err);
        res.status(500).json({ message: 'Failed to fetch balance' });
    }
});

// Get transactions by type (expense/income)
router.get('/by-type/:type', auth, async (req, res) => {
    try {
        const transactions = await PersonalTransaction.find({
            user: req.user.id,
            type: req.params.type,
            $or: [
                { isSubscription: { $ne: true } },  // Regular transactions
                { 
                    isSubscription: true,
                    'subscriptionDetails.nextBillingDate': { $exists: true }
                }  // Only valid subscription transactions
            ]
        }).sort({ date: -1 });
        res.json(transactions);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get all subscriptions
router.get('/subscriptions', auth, async (req, res) => {
    try {
        const subscriptions = await PersonalTransaction.find({
            user: req.user.id,
            isSubscription: true,
            'subscriptionDetails.nextBillingDate': { $exists: true }
        }).sort({ 'subscriptionDetails.nextBillingDate': 1 });
        
        console.log('Retrieved subscriptions:', subscriptions.length);
        res.json(subscriptions);
    } catch (err) {
        console.error('Error fetching subscriptions:', err);
        res.status(500).json({ message: err.message });
    }
});

// Get monthly summary
router.get('/summary', auth, async (req, res) => {
    try {
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        const transactions = await PersonalTransaction.find({
            user: req.user._id,
            date: {
                $gte: startOfMonth,
                $lte: endOfMonth
            }
        });

        const summary = transactions.reduce((acc, transaction) => {
            if (transaction.type === 'income') {
                acc.income += transaction.amount;
            } else {
                acc.expenses += transaction.amount;
                if (transaction.isSubscription) {
                    acc.subscriptions += transaction.amount;
                }
            }
            return acc;
        }, { income: 0, expenses: 0, subscriptions: 0 });

        summary.net = summary.income - summary.expenses;

        res.json(summary);
    } catch (error) {
        console.error('Error fetching monthly summary:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Add a new transaction
router.post('/', auth, async (req, res) => {
    try {
        // Validare de bază a datelor primite
        const { description, amount, type, category, date, isSubscription, subscriptionDetails, tags, notes } = req.body;

        if (!description || !amount || !type || !category || !date) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        if (typeof amount !== 'number' || amount < 0) {
             return res.status(400).json({ error: 'Invalid amount' });
        }

        if (type !== 'income' && type !== 'expense') {
             return res.status(400).json({ error: 'Invalid transaction type' });
        }

        // Creare și salvare tranzacție
        const transaction = new PersonalTransaction({
            user: req.user._id,
            description,
            amount,
            type,
            category,
            date: new Date(date), // Asigură-te că data este un obiect Date
            isSubscription: isSubscription || false,
            // Include subscriptionDetails doar dacă este o subscripție și datele sunt prezente
            ...(isSubscription && subscriptionDetails && subscriptionDetails.frequency && subscriptionDetails.nextDueDate && {
                subscriptionDetails: {
                    frequency: subscriptionDetails.frequency,
                    nextDueDate: new Date(subscriptionDetails.nextDueDate) // Asigură-te că și aceasta este un obiect Date
                }
            }),
            tags: tags || [],
            notes: notes || '',
        });

        await transaction.save();

        res.status(201).json(transaction); // Trimite tranzacția salvată înapoi
    } catch (error) {
        console.error('Error adding personal transaction:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Update a transaction
router.put('/:id', auth, async (req, res) => {
    try {
        const transaction = await PersonalTransaction.findOneAndUpdate(
            { _id: req.params.id, user: req.user._id },
            req.body,
            { new: true }
        );
        if (!transaction) {
            return res.status(404).json({ error: 'Transaction not found' });
        }
        res.json(transaction);
    } catch (error) {
        console.error('Error updating transaction:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Delete a transaction
router.delete('/:id', auth, async (req, res) => {
    try {
        const transaction = await PersonalTransaction.findOneAndDelete({
            _id: req.params.id,
            user: req.user._id
        });
        if (!transaction) {
            return res.status(404).json({ error: 'Transaction not found' });
        }
        res.json({ message: 'Transaction deleted' });
    } catch (error) {
        console.error('Error deleting transaction:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router; 