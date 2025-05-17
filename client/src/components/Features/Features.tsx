import type { ReactElement } from 'react';
import './Features.css';

const Icon = ({ name }: { name: string }) => {
  const icons: { [key: string]: ReactElement } = {
    budget: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
      </svg>
    ),
    goals: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <circle cx="12" cy="12" r="10" />
        <path d="M12 6v6l4 2" />
      </svg>
    ),
    family: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
        <circle cx="9" cy="7" r="4" />
        <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
      </svg>
    ),
    analytics: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <path d="M18 20V10" />
        <path d="M12 20V4" />
        <path d="M6 20v-6" />
      </svg>
    ),
    notifications: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
        <path d="M13.73 21a2 2 0 0 1-3.46 0" />
      </svg>
    ),
    security: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
      </svg>
    )
  };

  return icons[name] || null;
};

const Features = ({ onSelectPlan }: { onSelectPlan: () => void }) => {
  const features = [
    {
      icon: "budget",
      title: "Smart Budget Tracking",
      description: "Automatically categorize your expenses and track your spending patterns with intelligent analytics.",
      highlight: "AI-Powered Categorization"
    },
    {
      icon: "goals",
      title: "Financial Goals",
      description: "Set and achieve your financial goals with personalized recommendations and progress tracking.",
      highlight: "Custom Goal Setting"
    },
    {
      icon: "family",
      title: "Family Budgeting",
      description: "Share budgets and expenses with family members while maintaining individual privacy.",
      highlight: "Multi-User Support"
    },
    {
      icon: "analytics",
      title: "Advanced Analytics",
      description: "Get detailed insights into your spending habits with visual reports and trend analysis.",
      highlight: "Visual Reports"
    },
    {
      icon: "notifications",
      title: "Smart Notifications",
      description: "Receive personalized alerts for unusual spending, bill payments, and budget limits.",
      highlight: "Real-time Alerts"
    },
    {
      icon: "security",
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
            <div className="feature-icon">
              <Icon name={feature.icon} />
            </div>
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