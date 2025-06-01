import { useState, useEffect } from 'react';
import './App.css';
import Pricing from './components/Pricing/Pricing';
import Features from './components/Features/Features';
import Login from './Login';
import Friends from './components/Friends/Friends';
import { HomeIcon, CardsIcon, TransactionsIcon, BucketsIcon, SettingsIcon, UserIcon, CardIcon, PlusIcon } from './components/Icons';

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [showRegister, setShowRegister] = useState(false);
  const [showPricing, setShowPricing] = useState(false);
  const [showFeatures, setShowFeatures] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState('');
  const [showLoginPassword, setShowLoginPassword] = useState(false);
  const [showRegisterPassword, setShowRegisterPassword] = useState(false);
  const [userData, setUserData] = useState({
    fullName: '',
    email: '',
    password: '',
    plan: ''
  });
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    // Remove automatic login on token presence
    const token = localStorage.getItem('token');
    if (token) {
      // Only verify token if user explicitly tries to access protected routes
      fetch(`${process.env.REACT_APP_API_URL}/auth/verify`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      .then(response => {
        if (!response.ok) {
          localStorage.removeItem('token');
          setIsLoggedIn(false);
        }
      })
      .catch(() => {
        localStorage.removeItem('token');
        setIsLoggedIn(false);
      });
    }
  }, []);

  const handleLogin = async (email: string, password: string) => {
    try {
      console.log('Attempting login with:', { Email: email, Password: password });
      const response = await fetch('http://localhost:3000/auth/login', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        credentials: 'include',
        body: JSON.stringify({ Email: email, Password: password }),
      });

      const data = await response.json();
      console.log('Login response:', { status: response.status, data });

      if (response.ok) {
        localStorage.setItem('token', data.token);
        setUserData(prev => ({
          ...prev,
          fullName: data.user?.fullName || 'User',
          email: email
        }));
        setIsLoggedIn(true);
        setShowRegister(false);
      } else {
        console.error('Login failed:', data.error);
        alert(data.error || 'Login failed');
      }
    } catch (error) {
      console.error('Login error:', error);
      alert('Login failed. Please try again.');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    setIsLoggedIn(false);
    setUserData({
      fullName: '',
      email: '',
      password: '',
      plan: ''
    });
    setShowRegister(false);
    setIsLoginMode(true);
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
    
    try {
      console.log('Attempting registration with:', {
        FullName: userData.fullName,
        Email: userData.email,
        Password: userData.password,
        Plan: selectedPlan
      });

      const response = await fetch('http://localhost:3000/auth/register', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        credentials: 'include',
        body: JSON.stringify({
          FullName: userData.fullName,
          Email: userData.email,
          Password: userData.password,
          Plan: selectedPlan
        }),
      });

      const data = await response.json();
      console.log('Registration response:', { status: response.status, data });

      if (response.ok) {
        localStorage.setItem('token', data.token);
        setUserData(prev => ({
          ...prev,
          plan: selectedPlan
        }));
        setIsLoggedIn(true);
        setShowRegister(false);
      } else {
        console.error('Registration failed:', data.error);
        alert(data.error || 'Registration failed');
      }
    } catch (error) {
      console.error('Registration error:', error);
      alert('Registration failed. Please try again.');
    }
  };

  const handleLogoClick = () => {
    setIsLoggedIn(false);
    setIsLoginMode(true);
    setShowRegister(false);
    setShowPricing(false);
    setShowFeatures(false);
    setSelectedPlan('');
    setUserData({
      fullName: '',
      email: '',
      password: '',
      plan: ''
    });
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
                <div className="logo-container" onClick={handleLogoClick} style={{ cursor: 'pointer' }}>
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
                  <div className="auth-container">
                    <div className="auth-header">
                      <h2>Welcome Back!</h2>
                      <p>We're excited to see you again</p>
                    </div>
                    <form className="auth-form" onSubmit={(e) => {
                      e.preventDefault();
                      handleLogin(userData.email, userData.password);
                    }}>
                      <div className="input-group">
                        <input
                          type="email"
                          name="email"
                          placeholder="Email address"
                          value={userData.email}
                          onChange={handleInputChange}
                          required
                        />
                      </div>
                      <div className="input-group password-group">
                        <input
                          type={showLoginPassword ? "text" : "password"}
                          name="password"
                          placeholder="Password"
                          value={userData.password}
                          onChange={handleInputChange}
                          required
                        />
                        <button
                          type="button"
                          className="password-toggle"
                          onClick={() => setShowLoginPassword(!showLoginPassword)}
                          aria-label={showLoginPassword ? "Hide password" : "Show password"}
                        >
                          {showLoginPassword ? (
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                              <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                          ) : (
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                              <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                              <line x1="1" y1="1" x2="23" y2="23"></line>
                            </svg>
                          )}
                        </button>
                      </div>
                      <button 
                        type="submit" 
                        className="auth-button"
                      >
                        Sign In
                      </button>
                    </form>
                    <div className="auth-footer">
                      <p>Don't have an account?</p>
                              <button className="switch-form-btn" onClick={() => setIsLoginMode(false)}>
                        Create Account
                              </button>
                            </div>
                  </div>
                ) : (
                  <div className="auth-container">
                    <div className="auth-header">
                      <h2>Create Account</h2>
                      <p>Join Budgetly and start managing your finances</p>
                    </div>
                    <form onSubmit={handleRegisterSubmit} className="auth-form">
                      {selectedPlan && (
                        <div className="selected-plan-badge">
                          <span>Selected Plan:</span>
                          <strong>{selectedPlan}</strong>
                              </div>
                      )}
                              <div className="input-group">
                                <input
                                    type="text"
                                    name="fullName"
                          placeholder="Full Name"
                                    value={userData.fullName}
                                    onChange={handleInputChange}
                                    required
                                />
                              </div>
                              <div className="input-group">
                                <input
                                    type="email"
                                    name="email"
                          placeholder="Email address"
                                    value={userData.email}
                                    onChange={handleInputChange}
                                    required
                                />
                              </div>
                      <div className="input-group password-group">
                                <input
                          type={showRegisterPassword ? "text" : "password"}
                                    name="password"
                          placeholder="Create password"
                                    value={userData.password}
                                    onChange={handleInputChange}
                                    required
                                />
                        <button
                          type="button"
                          className="password-toggle"
                          onClick={() => setShowRegisterPassword(!showRegisterPassword)}
                          aria-label={showRegisterPassword ? "Hide password" : "Show password"}
                        >
                          {showRegisterPassword ? (
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                              <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                          ) : (
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                              <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                              <line x1="1" y1="1" x2="23" y2="23"></line>
                            </svg>
                          )}
                        </button>
                              </div>
                      <button type="submit" className="auth-button">
                        Create Account
                              </button>
                            </form>
                    <div className="auth-footer">
                      <p>Already have an account?</p>
                              <button className="switch-form-btn" onClick={() => setIsLoginMode(true)}>
                        Sign In
                              </button>
                            </div>
                  </div>
                      )}
                    </div>
                  </div>
              )}
            </>
        ) : (
        <div className="dashboard-container">
              <nav className="navbar">
            <div className="logo-container" onClick={handleLogoClick}>
                  <span className="logo-text">Budgetly</span>
              <span className="logo-dot">.</span>
            </div>
            <div className="nav-actions pro-nav-actions">
              <span className="user-name-pro">{userData.fullName}</span>
              <div className="user-avatar-pro">{userData.fullName.charAt(0).toUpperCase()}</div>
              <button className="logout-btn-pro" onClick={handleLogout} title="Logout">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#64748b" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                  <polyline points="16 17 21 12 16 7"></polyline>
                  <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
              </button>
                </div>
          </nav>

          <div className="dashboard-content pro-dashboard-content">
            <aside className="pro-sidebar">
              <div className="pro-sidebar-menu">
                <button 
                  className={`pro-sidebar-btn ${activeTab === 'overview' ? 'active' : ''}`}
                  onClick={() => setActiveTab('overview')}
                >
                  <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                    <path d="M9 22V12h6v10" />
                  </svg>
                  Overview
                </button>
                <button 
                  className={`pro-sidebar-btn ${activeTab === 'expenses' ? 'active' : ''}`}
                  onClick={() => setActiveTab('expenses')}
                >
                  <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M12 2v20M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6" />
                  </svg>
                  Expenses
                </button>
                <button 
                  className={`pro-sidebar-btn ${activeTab === 'friends' ? 'active' : ''}`}
                  onClick={() => setActiveTab('friends')}
                >
                  <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" />
                    <circle cx="9" cy="7" r="4" />
                    <path d="M23 21v-2a4 4 0 00-3-3.87" />
                    <path d="M16 3.13a4 4 0 010 7.75" />
                  </svg>
                  Friends
                </button>
                <button className="pro-sidebar-btn">
                  <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="3" />
                    <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z" />
                  </svg>
                  Settings
                </button>
              </div>
            </aside>

            <main className="pro-main">
              {activeTab === 'friends' ? (
                <Friends />
              ) : activeTab === 'expenses' ? (
                <div className="expenses-page">
                  <div className="expenses-header">
                    <h1>Expenses & Income</h1>
                    <div className="expenses-actions">
                      <button className="expense-action-btn">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <path d="M12 5v14M5 12h14" />
                        </svg>
                        Add Transaction
                      </button>
                      <div className="expense-filter">
                        <select className="expense-select">
                          <option>This Month</option>
                          <option>Last Month</option>
                          <option>Last 3 Months</option>
                          <option>This Year</option>
                        </select>
                      </div>
                    </div>
                  </div>

                  <div className="expenses-grid">
                    <div className="expense-card subscriptions">
                      <div className="expense-card-header">
                        <h2>Active Subscriptions</h2>
                        <button className="add-expense-btn">
                          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <path d="M12 5v14M5 12h14" />
                          </svg>
                          Add New
                        </button>
                      </div>
                      <div className="expense-list">
                        <div className="expense-item subscription">
                          <div className="expense-icon netflix">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <path d="M2 12h6m-2 4h10M8 8h14" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Netflix</span>
                            <span className="expense-date">Monthly • Next: June 15</span>
                          </div>
                          <span className="expense-amount negative">-$14.99</span>
                        </div>
                        <div className="expense-item subscription">
                          <div className="expense-icon spotify">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <circle cx="12" cy="12" r="10" />
                              <path d="M8 14s2.5-1 4-1 4 1 4 1M8 12s2.5-1 4-1 4 1 4 1M8 10s2.5-1 4-1 4 1 4 1" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Spotify</span>
                            <span className="expense-date">Monthly • Next: June 20</span>
                          </div>
                          <span className="expense-amount negative">-$9.99</span>
                        </div>
                        <div className="expense-item subscription">
                          <div className="expense-icon adobe">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <path d="M12 3L4 9v12h16V9l-8-6z" />
                              <path d="M12 3v18" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Adobe Creative Cloud</span>
                            <span className="expense-date">Monthly • Next: June 22</span>
                          </div>
                          <span className="expense-amount negative">-$52.99</span>
                        </div>
                        <div className="expense-item subscription">
                          <div className="expense-icon gym">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <path d="M6 4h12a2 2 0 012 2v12a2 2 0 01-2 2H6a2 2 0 01-2-2V6a2 2 0 012-2z" />
                              <path d="M9 12h6" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Gym Membership</span>
                            <span className="expense-date">Monthly • Next: July 1</span>
                          </div>
                          <span className="expense-amount negative">-$35.00</span>
                        </div>
                      </div>
                    </div>

                    <div className="expense-card income">
                      <div className="expense-card-header">
                        <h2>Regular Income</h2>
                        <button className="add-expense-btn">
                          <PlusIcon /> Add New
                  </button>
                      </div>
                      <div className="expense-list">
                        <div className="expense-item salary">
                          <div className="expense-icon salary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <rect x="2" y="4" width="20" height="16" rx="2" />
                              <path d="M12 8v8m-4-4h8" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Salary</span>
                            <span className="expense-date">Monthly • Next: June 25</span>
                          </div>
                          <span className="expense-amount positive">+$4,500.00</span>
                        </div>
                        <div className="expense-item freelance">
                          <div className="expense-icon freelance">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <path d="M12 4L4 8l8 4 8-4-8-4zM4 12l8 4 8-4M4 16l8 4 8-4" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Freelance</span>
                            <span className="expense-date">Variable • Avg: $800/mo</span>
                          </div>
                          <span className="expense-amount positive">+$800.00</span>
                        </div>
                      </div>
                    </div>

                    <div className="expense-card recent">
                      <div className="expense-card-header">
                        <h2>Recent Transactions</h2>
                        <div className="expense-card-tabs">
                          <button className="expense-tab active">All</button>
                          <button className="expense-tab">Expenses</button>
                          <button className="expense-tab">Income</button>
                        </div>
                      </div>
                      <div className="expense-list">
                        <div className="expense-item groceries">
                          <div className="expense-icon groceries">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Groceries</span>
                            <span className="expense-date">Today, 2:30 PM</span>
                          </div>
                          <span className="expense-amount negative">-$65.40</span>
                        </div>
                        <div className="expense-item transport">
                          <div className="expense-icon transport">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <rect x="2" y="8" width="20" height="12" rx="2" />
                              <path d="M6 12h12M8 16h8" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Transport</span>
                            <span className="expense-date">Yesterday</span>
                          </div>
                          <span className="expense-amount negative">-$25.00</span>
                        </div>
                        <div className="expense-item dining">
                          <div className="expense-icon dining">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                              <path d="M15 11c.6 0 1-.4 1-1V4c0-.6-.4-1-1-1s-1 .4-1 1v6c0 .6.4 1 1 1zM7 11c.6 0 1-.4 1-1V4c0-.6-.4-1-1-1s-1 .4-1 1v6c0 .6.4 1 1 1zM11 11c.6 0 1-.4 1-1V4c0-.6-.4-1-1-1s-1 .4-1 1v6c0 .6.4 1 1 1zM19 11H5c-1.1 0-2 .9-2 2v7c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2v-7c0-1.1-.9-2-2-2z" />
                            </svg>
                          </div>
                          <div className="expense-details">
                            <span className="expense-name">Restaurant</span>
                            <span className="expense-date">June 10</span>
                          </div>
                          <span className="expense-amount negative">-$42.80</span>
                        </div>
                      </div>
                    </div>

                    <div className="expense-card summary">
                      <div className="expense-card-header">
                        <h2>Monthly Summary</h2>
                        <div className="summary-total positive">+$2,941.82</div>
                      </div>
                      <div className="summary-stats">
                        <div className="summary-stat">
                          <span className="stat-label">Income</span>
                          <span className="stat-value positive">+$5,300.00</span>
                        </div>
                        <div className="summary-stat">
                          <span className="stat-label">Expenses</span>
                          <span className="stat-value negative">-$2,358.18</span>
                        </div>
                        <div className="summary-stat">
                          <span className="stat-label">Subscriptions</span>
                          <span className="stat-value negative">-$24.98</span>
                        </div>
                      </div>
                      <div className="summary-chart">
                        <div className="chart-legend">
                          <div className="legend-item">
                            <span className="legend-color income"></span>
                            <span className="legend-label">Income</span>
                          </div>
                          <div className="legend-item">
                            <span className="legend-color expenses"></span>
                            <span className="legend-label">Expenses</span>
                          </div>
                        </div>
                        <div className="chart-placeholder">
                          [Monthly trend chart will be here]
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <>
                  <div className="pro-main-header">
                    <h1>Welcome back!</h1>
                  </div>
                  <div className="pro-main-grid">
                    <div className="pro-card pro-accounts">
                      <h2>Monthly Overview</h2>
                      <div className="pro-accounts-list">
                        <div className="pro-accounts-row">
                          <span>Monthly Expenses</span>
                          <span className="pro-accounts-value text-red">-$1,240.00</span>
                        </div>
                        <div className="pro-accounts-row">
                          <span>Active Subscriptions</span>
                          <span className="pro-accounts-value text-blue">$89.99/mo</span>
                        </div>
                        <div className="pro-accounts-row">
                          <span>Expected Income</span>
                          <span className="pro-accounts-value text-green">+$2,500.00</span>
                        </div>
                        <div className="pro-accounts-row pro-accounts-total">
                          <span>Net Flow</span>
                          <span className="pro-accounts-value text-green">+$1,170.01</span>
                        </div>
                      </div>
                    </div>

                    <div className="pro-card pro-upcoming">
                      <h2>Upcoming Payments</h2>
                      <div className="pro-upcoming-list">
                        <div className="pro-upcoming-row">
                          <span className="pro-upcoming-date">14/06/24</span>
                          <span className="pro-upcoming-amount negative">-$14.99</span>
                          <span className="pro-upcoming-desc">Netflix</span>
                          <span className="pro-upcoming-badge badge-gray">Subscription</span>
                        </div>
                        <div className="pro-upcoming-row">
                          <span className="pro-upcoming-date">15/06/24</span>
                          <span className="pro-upcoming-amount negative">-$9.99</span>
                          <span className="pro-upcoming-desc">Spotify</span>
                          <span className="pro-upcoming-badge badge-gray">Subscription</span>
                        </div>
                        <div className="pro-upcoming-row">
                          <span className="pro-upcoming-date">20/06/24</span>
                          <span className="pro-upcoming-amount positive">+$2,500</span>
                          <span className="pro-upcoming-desc">Salary</span>
                          <span className="pro-upcoming-badge badge-green">Income</span>
                        </div>
                      </div>
                    </div>

                    <div className="pro-card pro-friends">
                      <h2>Friends & Debts</h2>
                      <div className="pro-friends-list">
                        <div className="pro-friend-item">
                          <div className="pro-friend-avatar">A</div>
                          <div className="pro-friend-info">
                            <span className="pro-friend-name">Alex</span>
                            <span className="pro-friend-amount positive">Owes you $45</span>
                          </div>
                          <button className="pro-remind-btn">Remind</button>
                        </div>
                        <div className="pro-friend-item">
                          <div className="pro-friend-avatar">S</div>
                          <div className="pro-friend-info">
                            <span className="pro-friend-name">Sarah</span>
                            <span className="pro-friend-amount negative">You owe $23</span>
                          </div>
                          <button className="pro-pay-btn">Pay</button>
                        </div>
                        <div className="pro-friend-item">
                          <div className="pro-friend-avatar">M</div>
                          <div className="pro-friend-info">
                            <span className="pro-friend-name">Mike</span>
                            <span className="pro-friend-amount positive">Owes you $15</span>
                          </div>
                          <button className="pro-remind-btn">Remind</button>
                        </div>
                      </div>
                    </div>

                    <div className="pro-card pro-spending">
                      <h2>Spending Categories</h2>
                      <div className="pro-spending-list">
                        <div className="pro-spending-item">
                          <div className="pro-spending-info">
                            <span className="pro-spending-category">Subscriptions</span>
                            <span className="pro-spending-amount">$89.99</span>
                          </div>
                          <div className="pro-spending-bar">
                            <div className="pro-spending-progress" style={{width: '15%'}}></div>
                          </div>
                        </div>
                        <div className="pro-spending-item">
                          <div className="pro-spending-info">
                            <span className="pro-spending-category">Food & Dining</span>
                            <span className="pro-spending-amount">$450.00</span>
                          </div>
                          <div className="pro-spending-bar">
                            <div className="pro-spending-progress" style={{width: '45%'}}></div>
                          </div>
                        </div>
                        <div className="pro-spending-item">
                          <div className="pro-spending-info">
                            <span className="pro-spending-category">Transportation</span>
                            <span className="pro-spending-amount">$120.00</span>
                          </div>
                          <div className="pro-spending-bar">
                            <div className="pro-spending-progress" style={{width: '25%'}}></div>
                          </div>
                        </div>
                      </div>
                    </div>
              </div>
            </>
              )}
            </main>
          </div>
        </div>
        )}
      </div>
  );
}

export default App;