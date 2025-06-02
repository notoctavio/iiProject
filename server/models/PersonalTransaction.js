const mongoose = require('mongoose');

const personalTransactionSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    description: {
        type: String,
        required: true,
        trim: true
    },
    amount: {
        type: Number,
        required: true,
        min: 0
    },
    type: {
        type: String,
        required: true,
        enum: ['income', 'expense']
    },
    category: {
        type: String,
        required: true,
        trim: true
    },
    date: {
        type: Date,
        required: true,
        default: Date.now
    },
    isSubscription: {
        type: Boolean,
        default: false
    },
    subscriptionDetails: {
        frequency: {
            type: String,
            enum: ['monthly', 'yearly']
        },
        nextDueDate: Date
    },
    tags: [{
        type: String,
        trim: true
    }],
    notes: {
        type: String,
        trim: true
    }
}, {
    timestamps: true
});

// Add indexes for common queries
personalTransactionSchema.index({ user: 1, date: -1 });
personalTransactionSchema.index({ user: 1, type: 1 });
personalTransactionSchema.index({ user: 1, isSubscription: 1 });

const PersonalTransaction = mongoose.model('PersonalTransaction', personalTransactionSchema);

module.exports = PersonalTransaction; 