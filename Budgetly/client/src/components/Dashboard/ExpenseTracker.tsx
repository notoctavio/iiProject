import React, { useState } from 'react';
import './ExpenseTracker.css';

interface Transaction {
  id: string;
  type: 'income' | 'expense';
  amount: number;
  category: string;
  date: Date;
  description: string;
  userId: string;
}

interface Budget {
  category: string;
  limit: number;
  spent: number;
  period: 'monthly' | 'weekly';
}

export const ExpenseTracker: React.FC = () => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [selectedCategory, setSelectedCategory] = useState('all');

  const categories = [
    { id: 'food', name: 'Food & Dining', icon: '🍽️' },
    { id: 'rent', name: 'Rent & Utilities', icon: '🏠' },
    { id: 'entertainment', name: 'Entertainment', icon: '🎬' },
    { id: 'transport', name: 'Transportation', icon: '🚗' },
    { id: 'shopping', name: 'Shopping', icon: '🛍️' },
    { id: 'health', name: 'Healthcare', icon: '⚕️' },
    { id: 'travel', name: 'Travel', icon: '✈️' },
    { id: 'other', name: 'Other', icon: '📦' }
  ];

  return (
    <div className="expense-tracker">
      <div className="expense-header">
        <h2>Expense Tracker</h2>
        <div className="period-selector">
          <button className="period-btn active">Month</button>
          <button className="period-btn">Week</button>
          <button className="period-btn">Year</button>
        </div>
      </div>

      <div className="expense-grid">
        <div className="expense-summary">
          <div className="summary-card income">
            <h3>Total Income</h3>
            <span className="amount">$5,240.00</span>
            <span className="trend positive">+12.5%</span>
          </div>
          <div className="summary-card expenses">
            <h3>Total Expenses</h3>
            <span className="amount">$3,180.00</span>
            <span className="trend negative">+8.2%</span>
          </div>
          <div className="summary-card balance">
            <h3>Net Balance</h3>
            <span className="amount">$2,060.00</span>
            <span className="trend positive">+16.8%</span>
          </div>
        </div>

        <div className="expense-categories">
          <h3>Spending by Category</h3>
          <div className="category-grid">
            {categories.map(category => (
              <div 
                key={category.id} 
                className={`category-card ${selectedCategory === category.id ? 'active' : ''}`}
                onClick={() => setSelectedCategory(category.id)}
              >
                <span className="category-icon">{category.icon}</span>
                <span className="category-name">{category.name}</span>
                <span className="category-amount">$840.00</span>
                <div className="category-progress">
                  <div 
                    className="progress-bar" 
                    style={{ width: '65%' }}
                  ></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="budget-alerts">
          <h3>Budget Alerts</h3>
          <div className="alerts-list">
            <div className="alert-item warning">
              <span className="alert-icon">⚠️</span>
              <div className="alert-content">
                <h4>Entertainment Budget</h4>
                <p>85% of monthly budget used</p>
              </div>
              <span className="alert-amount">$425/$500</span>
            </div>
            <div className="alert-item danger">
              <span className="alert-icon">🚨</span>
              <div className="alert-content">
                <h4>Dining Budget</h4>
                <p>Exceeded monthly budget by 15%</p>
              </div>
              <span className="alert-amount">$575/$500</span>
            </div>
          </div>
        </div>

        <div className="recent-activity">
          <h3>Recent Activity</h3>
          <div className="activity-list">
            <div className="activity-item expense">
              <div className="activity-icon">🍽️</div>
              <div className="activity-details">
                <h4>Restaurant Dinner</h4>
                <p>Food & Dining</p>
              </div>
              <div className="activity-amount">
                <span className="amount negative">-$85.00</span>
                <span className="date">Today</span>
              </div>
            </div>
            <div className="activity-item income">
              <div className="activity-icon">💰</div>
              <div className="activity-details">
                <h4>Salary Deposit</h4>
                <p>Regular Income</p>
              </div>
              <div className="activity-amount">
                <span className="amount positive">+$3,500.00</span>
                <span className="date">Yesterday</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExpenseTracker; 