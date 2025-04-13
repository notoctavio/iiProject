import React, { useState } from 'react';
import './FinancialReports.css';

interface ChartData {
  labels: string[];
  values: number[];
  type: 'expense' | 'income' | 'savings';
}

export const FinancialReports: React.FC = () => {
  const [selectedPeriod, setSelectedPeriod] = useState('month');
  const [selectedChart, setSelectedChart] = useState('expenses');

  const mockChartData: Record<string, ChartData> = {
    expenses: {
      labels: ['Food', 'Rent', 'Transport', 'Entertainment', 'Shopping', 'Others'],
      values: [850, 1200, 300, 450, 600, 280],
      type: 'expense'
    },
    income: {
      labels: ['Salary', 'Investments', 'Freelance', 'Other'],
      values: [3500, 800, 1200, 300],
      type: 'income'
    },
    savings: {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      values: [500, 750, 600, 850, 1000, 1200],
      type: 'savings'
    }
  };

  return (
    <div className="financial-reports">
      <div className="reports-header">
        <h2>Financial Reports & Analytics</h2>
        <div className="period-selector">
          <button 
            className={`period-btn ${selectedPeriod === 'month' ? 'active' : ''}`}
            onClick={() => setSelectedPeriod('month')}
          >
            Month
          </button>
          <button 
            className={`period-btn ${selectedPeriod === 'quarter' ? 'active' : ''}`}
            onClick={() => setSelectedPeriod('quarter')}
          >
            Quarter
          </button>
          <button 
            className={`period-btn ${selectedPeriod === 'year' ? 'active' : ''}`}
            onClick={() => setSelectedPeriod('year')}
          >
            Year
          </button>
        </div>
      </div>

      <div className="reports-grid">
        <div className="chart-section">
          <div className="chart-controls">
            <button 
              className={`chart-btn ${selectedChart === 'expenses' ? 'active' : ''}`}
              onClick={() => setSelectedChart('expenses')}
            >
              Expenses
            </button>
            <button 
              className={`chart-btn ${selectedChart === 'income' ? 'active' : ''}`}
              onClick={() => setSelectedChart('income')}
            >
              Income
            </button>
            <button 
              className={`chart-btn ${selectedChart === 'savings' ? 'active' : ''}`}
              onClick={() => setSelectedChart('savings')}
            >
              Savings
            </button>
          </div>

          <div className="chart-container">
            <div className="chart-visualization">
              {/* Here you would integrate a real chart library */}
              <div className="mock-chart">
                {mockChartData[selectedChart].labels.map((label, index) => (
                  <div key={label} className="chart-bar">
                    <div 
                      className="bar-fill"
                      style={{ 
                        height: `${(mockChartData[selectedChart].values[index] / Math.max(...mockChartData[selectedChart].values)) * 100}%`
                      }}
                    ></div>
                    <span className="bar-label">{label}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="insights-section">
          <h3>Financial Insights</h3>
          <div className="insights-grid">
            <div className="insight-card positive">
              <span className="insight-icon">📈</span>
              <div className="insight-content">
                <h4>Savings Growth</h4>
                <p>Your savings increased by 25% compared to last month</p>
              </div>
            </div>
            <div className="insight-card warning">
              <span className="insight-icon">⚠️</span>
              <div className="insight-content">
                <h4>Entertainment Spending</h4>
                <p>Entertainment expenses are 15% higher than usual</p>
              </div>
            </div>
            <div className="insight-card info">
              <span className="insight-icon">💡</span>
              <div className="insight-content">
                <h4>Savings Opportunity</h4>
                <p>You could save $200 more by reducing dining out</p>
              </div>
            </div>
          </div>
        </div>

        <div className="trends-section">
          <h3>Spending Trends</h3>
          <div className="trends-timeline">
            <div className="trend-point">
              <div className="trend-date">June</div>
              <div className="trend-amount increase">+12%</div>
              <div className="trend-description">Overall spending increased</div>
            </div>
            <div className="trend-point">
              <div className="trend-date">May</div>
              <div className="trend-amount decrease">-8%</div>
              <div className="trend-description">Reduced transportation costs</div>
            </div>
            <div className="trend-point">
              <div className="trend-date">April</div>
              <div className="trend-amount increase">+5%</div>
              <div className="trend-description">Higher grocery expenses</div>
            </div>
          </div>
        </div>

        <div className="export-section">
          <h3>Export Reports</h3>
          <div className="export-options">
            <button className="export-btn">
              <span className="export-icon">📊</span>
              Export as PDF
            </button>
            <button className="export-btn">
              <span className="export-icon">📑</span>
              Export as Excel
            </button>
            <button className="export-btn">
              <span className="export-icon">📧</span>
              Email Report
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FinancialReports; 