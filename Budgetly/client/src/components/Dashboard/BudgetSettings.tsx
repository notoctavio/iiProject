import React, { useState } from 'react';
import './BudgetSettings.css';

interface BudgetAlert {
  category: string;
  threshold: number;
  type: 'amount' | 'percentage';
  notificationType: 'email' | 'push' | 'both';
}

interface CategoryBudget {
  category: string;
  limit: number;
  spent: number;
  color: string;
}

export const BudgetSettings: React.FC = () => {
  const [alerts, setAlerts] = useState<BudgetAlert[]>([
    {
      category: 'Food',
      threshold: 80,
      type: 'percentage',
      notificationType: 'both'
    },
    {
      category: 'Entertainment',
      threshold: 200,
      type: 'amount',
      notificationType: 'push'
    }
  ]);

  const [categoryBudgets, setCategoryBudgets] = useState<CategoryBudget[]>([
    {
      category: 'Food',
      limit: 500,
      spent: 350,
      color: '#4CAF50'
    },
    {
      category: 'Rent',
      limit: 1200,
      spent: 1200,
      color: '#2196F3'
    },
    {
      category: 'Entertainment',
      limit: 300,
      spent: 250,
      color: '#FF9800'
    },
    {
      category: 'Transport',
      limit: 200,
      spent: 150,
      color: '#9C27B0'
    }
  ]);

  const [newAlert, setNewAlert] = useState<BudgetAlert>({
    category: '',
    threshold: 0,
    type: 'percentage',
    notificationType: 'email'
  });

  const handleAddAlert = () => {
    if (newAlert.category && newAlert.threshold > 0) {
      setAlerts([...alerts, newAlert]);
      setNewAlert({
        category: '',
        threshold: 0,
        type: 'percentage',
        notificationType: 'email'
      });
    }
  };

  const handleUpdateBudget = (category: string, newLimit: number) => {
    setCategoryBudgets(
      categoryBudgets.map(budget =>
        budget.category === category ? { ...budget, limit: newLimit } : budget
      )
    );
  };

  return (
    <div className="budget-settings">
      <div className="settings-header">
        <h2>Budget Settings & Alerts</h2>
      </div>

      <div className="settings-grid">
        <section className="category-budgets">
          <h3>Category Budgets</h3>
          <div className="budgets-list">
            {categoryBudgets.map(budget => (
              <div key={budget.category} className="budget-item">
                <div className="budget-info">
                  <h4>{budget.category}</h4>
                  <div className="budget-progress">
                    <div 
                      className="progress-bar"
                      style={{
                        width: `${(budget.spent / budget.limit) * 100}%`,
                        backgroundColor: budget.color
                      }}
                    ></div>
                  </div>
                  <div className="budget-numbers">
                    <span>${budget.spent} spent</span>
                    <span>of ${budget.limit}</span>
                  </div>
                </div>
                <div className="budget-actions">
                  <input
                    type="number"
                    value={budget.limit}
                    onChange={(e) => handleUpdateBudget(budget.category, Number(e.target.value))}
                    min="0"
                    step="10"
                  />
                  <button className="update-btn">Update</button>
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className="alert-settings">
          <h3>Budget Alerts</h3>
          <div className="alerts-list">
            {alerts.map((alert, index) => (
              <div key={index} className="alert-item">
                <div className="alert-info">
                  <h4>{alert.category}</h4>
                  <p>
                    Alert when spending reaches {alert.threshold}
                    {alert.type === 'percentage' ? '%' : '$'}
                  </p>
                  <span className="notification-type">
                    {alert.notificationType === 'both' 
                      ? 'Email & Push' 
                      : alert.notificationType.charAt(0).toUpperCase() + alert.notificationType.slice(1)}
                  </span>
                </div>
                <button 
                  className="delete-btn"
                  onClick={() => setAlerts(alerts.filter((_, i) => i !== index))}
                >
                  Delete
                </button>
              </div>
            ))}
          </div>

          <div className="add-alert">
            <h4>Add New Alert</h4>
            <div className="alert-form">
              <select 
                value={newAlert.category}
                onChange={(e) => setNewAlert({ ...newAlert, category: e.target.value })}
              >
                <option value="">Select Category</option>
                {categoryBudgets.map(budget => (
                  <option key={budget.category} value={budget.category}>
                    {budget.category}
                  </option>
                ))}
              </select>

              <div className="threshold-input">
                <input
                  type="number"
                  value={newAlert.threshold}
                  onChange={(e) => setNewAlert({ ...newAlert, threshold: Number(e.target.value) })}
                  min="0"
                />
                <select
                  value={newAlert.type}
                  onChange={(e) => setNewAlert({ ...newAlert, type: e.target.value as 'amount' | 'percentage' })}
                >
                  <option value="percentage">%</option>
                  <option value="amount">$</option>
                </select>
              </div>

              <select
                value={newAlert.notificationType}
                onChange={(e) => setNewAlert({ ...newAlert, notificationType: e.target.value as 'email' | 'push' | 'both' })}
              >
                <option value="email">Email</option>
                <option value="push">Push</option>
                <option value="both">Both</option>
              </select>

              <button className="add-btn" onClick={handleAddAlert}>
                Add Alert
              </button>
            </div>
          </div>
        </section>

        <section className="notification-preferences">
          <h3>Notification Preferences</h3>
          <div className="preferences-list">
            <div className="preference-item">
              <label>
                <input type="checkbox" defaultChecked />
                Email Notifications
              </label>
              <p>Receive detailed budget reports and alerts via email</p>
            </div>
            <div className="preference-item">
              <label>
                <input type="checkbox" defaultChecked />
                Push Notifications
              </label>
              <p>Get instant alerts on your device when reaching budget thresholds</p>
            </div>
            <div className="preference-item">
              <label>
                <input type="checkbox" defaultChecked />
                Weekly Summary
              </label>
              <p>Receive a weekly summary of your spending and budget status</p>
            </div>
            <div className="preference-item">
              <label>
                <input type="checkbox" />
                Smart Suggestions
              </label>
              <p>Get AI-powered suggestions for budget optimization</p>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
};

export default BudgetSettings; 