const express = require('express');
const router = express.Router();
const User = require('../models/User');
const auth = require('../middleware/auth');
const bcrypt = require('bcryptjs');

// Update profile
router.patch('/update-profile', auth, async (req, res) => {
  try {
    const { fullName, email, currentPassword, newPassword } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // If changing password, verify current password
    if (newPassword) {
      const isMatch = await bcrypt.compare(currentPassword, user.password);
      if (!isMatch) {
        return res.status(400).json({ error: 'Current password is incorrect' });
      }
      user.password = await bcrypt.hash(newPassword, 10);
    }

    // Update other fields
    if (fullName) user.fullName = fullName;
    if (email) user.email = email;

    await user.save();

    res.json({
      fullName: user.fullName,
      email: user.email,
      plan: user.plan
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update preferences
router.put('/preferences', auth, async (req, res) => {
  try {
    const { emailNotifications, monthlyReport, darkMode, currency } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update preferences
    user.preferences = {
      ...user.preferences,
      emailNotifications,
      monthlyReport,
      darkMode,
      currency
    };

    await user.save();
    res.json(user.preferences);
  } catch (error) {
    console.error('Error updating preferences:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update notification settings
router.put('/notifications', auth, async (req, res) => {
  try {
    const { lowBalanceAlert, subscriptionReminders, billReminders, weeklyInsights } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update notification settings
    user.notificationSettings = {
      ...user.notificationSettings,
      lowBalanceAlert,
      subscriptionReminders,
      billReminders,
      weeklyInsights
    };

    await user.save();
    res.json(user.notificationSettings);
  } catch (error) {
    console.error('Error updating notification settings:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get user settings
router.get('/settings', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      fullName: user.fullName,
      email: user.email,
      plan: user.plan,
      preferences: user.preferences || {},
      notificationSettings: user.notificationSettings || {}
    });
  } catch (error) {
    console.error('Error fetching user settings:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router; 