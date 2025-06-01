const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
    description: {
        type: String,
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    splitType: {
        type: String,
        enum: ['50-50', 'payer-full', 'payee-full', 'custom'],
        default: '50-50'
    },
    splitPercentage: {
        type: Number,
        min: 0,
        max: 100,
        default: 50
    },
    status: {
        type: String,
        enum: ['pending', 'completed'],
        default: 'pending'
    },
    payer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    payee: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    date: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Index for faster queries
transactionSchema.index({ payer: 1, payee: 1 });
transactionSchema.index({ status: 1 });

const Transaction = mongoose.model('Transaction', transactionSchema);

module.exports = Transaction; 