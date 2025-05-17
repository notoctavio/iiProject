import React, { ReactElement } from 'react';
import './Pricing.css';

interface PricingProps {
  onSelectPlan: (plan: string) => void;
}

const Icon = ({ name }: { name: string }) => {
  const icons: { [key: string]: ReactElement } = {
    security: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
      </svg>
    ),
    updates: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" />
        <path d="M3 3v5h5" />
        <path d="M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16" />
        <path d="M16 16h5v5" />
      </svg>
    ),
    support: (
      <svg viewBox="0 0 24 24" fill="none" stroke="#ffffff" strokeWidth="2">
        <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
      </svg>
    )
  };

  return icons[name] || null;
};

const Pricing: React.FC<PricingProps> = ({ onSelectPlan }) => {
  const plans = [
    {
      name: 'Free',
      price: '0',
      period: 'forever',
      features: [
        'Basic expense tracking',
        'Monthly budget planning',
        'Transaction history',
        'Basic reports',
        'Email support'
      ],
      popular: false,
      cta: 'Get Started'
    },
    {
      name: 'Pro',
      price: '4.99',
      period: 'month',
      features: [
        'Everything in Free',
        'Advanced analytics',
        'Custom categories',
        'Bill reminders',
        'Export reports',
        'Priority support',
        'Family sharing (up to 2 members)'
      ],
      popular: true,
      cta: 'Start Free Trial'
    },
    {
      name: 'Family',
      price: '9.99',
      period: 'month',
      features: [
        'Everything in Pro',
        'Unlimited family members',
        'Shared budgets',
        'Family goals',
        'Advanced security',
        '24/7 priority support',
        'Custom integrations'
      ],
      popular: false,
      cta: 'Start Free Trial'
    }
  ];

  return (
    <div className="pricing-container">
      <div className="pricing-header">
        <h1>Simple, Transparent Pricing</h1>
        <p>Choose the plan that's right for you and start your financial journey today</p>
      </div>
      
      <div className="pricing-grid">
        {plans.map((plan) => (
          <div key={plan.name} className={`pricing-card ${plan.popular ? 'popular' : ''}`}>
            {plan.popular && <div className="popular-badge">Most Popular</div>}
            <div className="plan-header">
              <h2>{plan.name}</h2>
              <div className="price">
                <span className="currency">$</span>
                <span className="amount">{plan.price}</span>
                <span className="period">/{plan.period}</span>
              </div>
            </div>
            <ul className="features-list">
              {plan.features.map((feature, index) => (
                <li key={index}>
                  <span className="check-icon">✓</span>
                  {feature}
                </li>
              ))}
            </ul>
            <button 
              className={`plan-cta ${plan.popular ? 'popular' : ''}`}
              onClick={() => onSelectPlan(plan.name)}
            >
              {plan.cta}
            </button>
          </div>
        ))}
      </div>

      <div className="pricing-footer">
        <h3>All plans include:</h3>
        <div className="common-features">
          <div className="feature">
            <div className="feature-icon">
              <Icon name="security" />
            </div>
            <span>Bank-level security</span>
          </div>
          <div className="feature">
            <div className="feature-icon">
              <Icon name="updates" />
            </div>
            <span>Regular updates</span>
          </div>
          <div className="feature">
            <div className="feature-icon">
              <Icon name="support" />
            </div>
            <span>Community support</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Pricing; 