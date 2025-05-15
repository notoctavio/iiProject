const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true
    },
    passwordHash: {
        type: String,
        required: true
    },
    plan: {
        type: String,
        enum: ['Free', 'Pro', 'Family'],
        default: 'Free'
    }
}, {
    timestamps: true, // Adds createdAt and updatedAt automatically
    collection: 'users' // Specifică explicit numele colecției
});

// Method to return user without sensitive data
userSchema.methods.toJSON = function() {
    const user = this.toObject();
    delete user.passwordHash;
    return user;
};

const User = mongoose.model('User', userSchema);

module.exports = User; 