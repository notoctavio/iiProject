import React from 'react';
import './Pricing.css';

interface PricingProps {
  onSelectPlan: (plan: string) => void;
}

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
            <span className="feature-icon">🔒</span>
            <span>Bank-level security</span>
          </div>
          <div className="feature">
            <span className="feature-icon">📱</span>
            <span>Mobile apps</span>
          </div>
          <div className="feature">
            <span className="feature-icon">🔄</span>
            <span>Regular updates</span>
          </div>
          <div className="feature">
            <span className="feature-icon">💬</span>
            <span>Community support</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Pricing; 