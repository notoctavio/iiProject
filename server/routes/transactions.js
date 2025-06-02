const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');
const auth = require('../middleware/auth');

// GET /api/transactions/monthly-summary
router.get('/monthly-summary', auth, async (req, res) => {
  try {
    const today = new Date();
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

    // Obține toate tranzacțiile din luna curentă
    const transactions = await Transaction.find({
      userId: req.user.id,
      date: {
        $gte: firstDayOfMonth,
        $lte: lastDayOfMonth
      }
    }).sort({ date: -1 });

    // Calculează sumarul
    const summary = transactions.reduce((acc, transaction) => {
      const amount = transaction.amount;
      
      if (transaction.type === 'income') {
        acc.income += amount;
        acc.net += amount;
      } else if (transaction.type === 'expense') {
        acc.expenses += amount;
        acc.net -= amount;
        
        if (transaction.isSubscription) {
          acc.subscriptions += amount;
        }
      }
      
      return acc;
    }, {
      income: 0,
      expenses: 0,
      subscriptions: 0,
      net: 0
    });

    res.json({
      summary,
      transactions
    });
  } catch (error) {
    console.error('Error fetching monthly summary:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router; 