import React from 'react';
import './Features.css';

const Features = ({ onSelectPlan }: { onSelectPlan: () => void }) => {
  const features = [
    {
      icon: "📊",
      title: "Smart Budget Tracking",
      description: "Automatically categorize your expenses and track your spending patterns with intelligent analytics.",
      highlight: "AI-Powered Categorization"
    },
    {
      icon: "🎯",
      title: "Financial Goals",
      description: "Set and achieve your financial goals with personalized recommendations and progress tracking.",
      highlight: "Custom Goal Setting"
    },
    {
      icon: "👨‍👩‍👧‍👦",
      title: "Family Budgeting",
      description: "Share budgets and expenses with family members while maintaining individual privacy.",
      highlight: "Multi-User Support"
    },
    {
      icon: "📈",
      title: "Advanced Analytics",
      description: "Get detailed insights into your spending habits with visual reports and trend analysis.",
      highlight: "Visual Reports"
    },
    {
      icon: "🔔",
      title: "Smart Notifications",
      description: "Receive personalized alerts for unusual spending, bill payments, and budget limits.",
      highlight: "Real-time Alerts"
    },
    {
      icon: "🔒",
      title: "Bank-Level Security",
      description: "Your financial data is protected with enterprise-grade encryption and security measures.",
      highlight: "256-bit Encryption"
    }
  ];

  return (
    <div className="features-container">
      <div className="features-header">
        <h1>Powerful Features for Your Financial Success</h1>
        <p>Discover all the tools you need to take control of your finances</p>
      </div>

      <div className="features-grid">
        {features.map((feature, index) => (
          <div className="feature-card" key={index}>
            <div className="feature-icon">{feature.icon}</div>
            <h3>{feature.title}</h3>
            <p>{feature.description}</p>
            <span className="feature-highlight">{feature.highlight}</span>
          </div>
        ))}
      </div>

      <div className="features-benefits">
        <div className="benefits-content">
          <h2>Why Choose Budgetly?</h2>
          <ul className="benefits-list">
            <li>
              <span className="check-icon">✓</span>
              Easy to use interface designed for everyone
            </li>
            <li>
              <span className="check-icon">✓</span>
              Secure and private data protection
            </li>
            <li>
              <span className="check-icon">✓</span>
              Regular updates and new features
            </li>
            <li>
              <span className="check-icon">✓</span>
              24/7 customer support
            </li>
          </ul>
        </div>
      </div>

      <div className="features-cta">
        <h2>Ready to Start Your Financial Journey?</h2>
        <p>Choose the perfect plan for your needs and start managing your finances today.</p>
        <button className="select-plan-button" onClick={onSelectPlan}>
          View Pricing Plans
        </button>
      </div>
    </div>
  );
};

export default Features; 