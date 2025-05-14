import React, { useState } from 'react';
import './App.css';
import ExpenseTracker from './components/Dashboard/ExpenseTracker';
import FinancialReports from './components/Dashboard/FinancialReports';
import BudgetSettings from './components/Dashboard/BudgetSettings';
import FamilyBudget from './components/Dashboard/FamilyBudget';
import Pricing from './components/Pricing/Pricing';
import Features from './components/Features/Features';
import Login from './Login';



function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [showRegister, setShowRegister] = useState(false);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showPricing, setShowPricing] = useState(false);
  const [showFeatures, setShowFeatures] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState('');
  const [userData, setUserData] = useState({
    fullName: '',
    email: '',
    password: '',
    plan: ''
  });
  const [registrationError, setRegistrationError] = useState('');

  const handleLogin = () => {
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
  };

  const handleGetStarted = () => {
    setShowPricing(true);
  };

  const handlePricingClick = () => {
    setShowPricing(true);
  };

  const handleFeaturesClick = () => {
    setShowFeatures(true);
    setShowPricing(false);
  };

  const handleBackToHome = () => {
    setShowPricing(false);
    setShowFeatures(false);
  };

  const handlePlanSelect = (plan: string) => {
    console.log('Plan selected:', plan);
    setSelectedPlan(plan);
    setShowRegister(true);
    setShowPricing(false);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setUserData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setRegistrationError('');

    try {
        const response = await fetch('http://localhost:3000/auth/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                FullName: userData.fullName,
                Email: userData.email,
                Password: userData.password,
                Plan: selectedPlan || 'Free'
            }),
        });

        const data = await response.json();

        if (response.ok) {
            console.log('Registration successful:', data);
            // Salvăm datele utilizatorului
            localStorage.setItem('user', JSON.stringify({
                fullName: userData.fullName,
                email: userData.email,
                plan: selectedPlan || 'Free'
            }));
            handleLogin(); // Log the user in
            setShowRegister(false); // Close the modal
        } else {
            setRegistrationError(data.error || 'Registration failed. Please try again.');
            console.error('Registration failed:', data);
        }
    } catch (error) {
        console.error('Registration error:', error);
        setRegistrationError('An error occurred. Please try again.');
    }
  };

  const renderDashboardContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <ExpenseTracker />;
      case 'reports':
        return <FinancialReports />;
      case 'family':
        return <FamilyBudget />;
      case 'settings':
        return <BudgetSettings />;
      default:
        return <ExpenseTracker />;
    }
  };

  const renderContent = () => {
    if (showPricing) {
      return <Pricing onSelectPlan={(plan: string) => handlePlanSelect(plan)} />;
    }
    if (showFeatures) {
      return <Features onSelectPlan={() => setShowPricing(true)} />;
    }
    return (
        <div className="hero">
          <div className="hero-content">
            <h1>Smart banking for<br />Smart people</h1>
            <p>Budgetly helps you track expenses, set budgets, and achieve your financial goals with ease. Join thousands of users who have transformed their financial lives.</p>
            <button className="cta-button" onClick={handleGetStarted}>Get Started</button>
            <div className="stats">
              <div className="stat">
                <h3>10K+</h3>
                <p>Active Users</p>
              </div>
              <div className="stat">
                <h3>$2M+</h3>
                <p>Tracked</p>
              </div>
              <div className="stat">
                <h3>4.8</h3>
                <p>App Rating</p>
              </div>
            </div>
          </div>
          <div className="hero-image">
            <div className="dashboard-preview">
              <div className="window-controls">
                <span className="close"></span>
                <span className="minimize"></span>
                <span className="maximize"></span>
              </div>
              <div className="dashboard-content">
                <div className="sidebar">
                  <div className="menu-item active">
                    <span className="icon">📊</span>
                    Dashboard
                  </div>
                  <div className="menu-item">
                    <span className="icon">📈</span>
                    Reports
                  </div>
                  <div className="menu-item">
                    <span className="icon">👨‍👩‍👧‍👦</span>
                    Family
                  </div>
                  <div className="menu-item">
                    <span className="icon">⚙️</span>
                    Settings
                  </div>
                </div>
                <div className="main-content">
                  <div className="balance-card">
                    <h3>Total Balance</h3>
                    <h2>$5,240.00</h2>
                  </div>
                  <div className="add-transaction">
                    <button>+ Add Transaction</button>
                  </div>
                  <div className="recent-transactions">
                    <h3>Recent Transactions</h3>
                    <div className="transaction">
                      <span>🛒</span>
                      <span>Grocery Shopping</span>
                      <span className="amount">-$85.00</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
    );
  };

  return (
      <div className="app-container">
        <div className="background-elements">
          <div className="gradient-bg"></div>
          <div className="circle circle-1"></div>
          <div className="circle circle-2"></div>
          <div className="circle circle-3"></div>
        </div>

        {!isLoggedIn ? (
            <>
              <nav className="navbar">
                <div className="logo-container">
                  <span className="logo-text">Budgetly</span>
                  <span className="logo-dot">.</span>
                </div>
                <div className="nav-links">
                  <a href="#features" onClick={(e) => {
                    e.preventDefault();
                    handleFeaturesClick();
                  }}>Features</a>
                  <a href="#pricing" onClick={(e) => {
                    e.preventDefault();
                    handlePricingClick();
                  }}>Pricing</a>
                  <a href="#about">About</a>
                  <button className="nav-login-btn" onClick={() => setShowRegister(true)}>Login</button>
                </div>
              </nav>

              <section className="hero-section">
                {renderContent()}
              </section>

              {showRegister && (
                  <div className="modal-overlay">
                    <div className="signup-modal">
                      <button className="close-btn" onClick={() => setShowRegister(false)}>×</button>
                      {isLoginMode ? (
                          <>
                            <h2>Login</h2>
                            <Login onLoginSuccess={() => {
                              setIsLoggedIn(true); // Setează utilizatorul ca logat
                              setShowRegister(false); // Închide modalul
                            }} />
                            <div className="form-footer">
                              Don't have an account?{' '}
                              <button className="switch-form-btn" onClick={() => setIsLoginMode(false)}>
                                Create an Account
                              </button>
                            </div>
                          </>
                      ) : (
                          <>
                            <h2>Create Your Account</h2>
                            <form onSubmit={handleRegisterSubmit}>
                              <div className="selected-plan">
                                <p>Selected Plan: <strong>{selectedPlan || 'Free'}</strong></p>
                              </div>
                              {registrationError && (
                                <div className="error-message">
                                  {registrationError}
                                </div>
                              )}
                              <div className="input-group">
                                <label>Full Name</label>
                                <input
                                    type="text"
                                    name="fullName"
                                    placeholder="John Doe"
                                    value={userData.fullName}
                                    onChange={handleInputChange}
                                    required
                                />
                              </div>
                              <div className="input-group">
                                <label>Email</label>
                                <input
                                    type="email"
                                    name="email"
                                    placeholder="john@example.com"
                                    value={userData.email}
                                    onChange={handleInputChange}
                                    required
                                />
                              </div>
                              <div className="input-group">
                                <label>Password</label>
                                <input
                                    type="password"
                                    name="password"
                                    placeholder="••••••••"
                                    value={userData.password}
                                    onChange={handleInputChange}
                                    required
                                />
                              </div>
                              <button type="submit" className="signup-btn">
                                Start Your Journey
                              </button>
                            </form>
                            <div className="form-footer">
                              Already have an account?{' '}
                              <button className="switch-form-btn" onClick={() => setIsLoginMode(true)}>
                                Login
                              </button>
                            </div>
                          </>
                      )}
                    </div>
                  </div>
              )}
            </>
        ) : (
            <>
              <nav className="navbar">
                <div className="logo-container">
                  <span className="logo-text">Budgetly</span>
                  <span className="logo-dot"></span>
                </div>
                <div className="nav-links">
                  <button
                      className={`nav-link ${activeTab === 'dashboard' ? 'active' : ''}`}
                      onClick={() => setActiveTab('dashboard')}
                  >
                    Dashboard
                  </button>
                  <button
                      className={`nav-link ${activeTab === 'reports' ? 'active' : ''}`}
                      onClick={() => setActiveTab('reports')}
                  >
                    Reports
                  </button>
                  <button
                      className={`nav-link ${activeTab === 'family' ? 'active' : ''}`}
                      onClick={() => setActiveTab('family')}
                  >
                    Family
                  </button>
                  <button
                      className={`nav-link ${activeTab === 'settings' ? 'active' : ''}`}
                      onClick={() => setActiveTab('settings')}
                  >
                    Settings
                  </button>
                  <div className="user-info">
                    <span className="user-name">{userData.fullName || 'User'}</span>
                    <button className="logout-btn" onClick={handleLogout}>Logout</button>
                  </div>
                </div>
              </nav>
              <div className="dashboard-container">
                {renderDashboardContent()}
              </div>
            </>
        )}
      </div>
  );
}

export default App;