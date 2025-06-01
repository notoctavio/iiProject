import React, { useState, useEffect } from 'react';
import './Friends.css';

interface User {
  _id: string;
  fullName: string;
  email: string;
}

interface FriendRequest {
  _id: string;
  sender: User;
  status: 'pending' | 'accepted' | 'rejected';
}

interface Friend extends User {
  // No additional properties needed since we're using friendBalances
}

type SplitType = '50-50' | 'payer-full' | 'payee-full' | 'custom';

interface Transaction {
  _id: string;
  description: string;
  amount: number;
  splitType: SplitType;
  splitPercentage?: number;
  status: 'pending' | 'completed';
  payer: User;
  payee: User;
  date: string;
  createdAt: string;
}

interface FriendBalance {
  friend: User;
  balance: number;
}

const Friends: React.FC = () => {
  const [friends, setFriends] = useState<Friend[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [friendRequests, setFriendRequests] = useState<FriendRequest[]>([]);
  const [showAddFriend, setShowAddFriend] = useState(false);
  const [showFriendRequests, setShowFriendRequests] = useState(false);
  const [showSplitPayment, setShowSplitPayment] = useState(false);
  const [selectedFriend, setSelectedFriend] = useState<Friend | null>(null);
  const [newTransaction, setNewTransaction] = useState({
    description: '',
    amount: '',
    splitType: '50-50' as SplitType,
    splitPercentage: 50
  });
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [friendBalances, setFriendBalances] = useState<FriendBalance[]>([]);
  const [selectedFriendTransactions, setSelectedFriendTransactions] = useState<Transaction[]>([]);
  const [showTransactions, setShowTransactions] = useState(false);

  useEffect(() => {
    const loadTransactions = async () => {
      try {
        const response = await fetch('http://localhost:3000/friends/transactions', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (response.ok) {
          const data = await response.json();
          setTransactions(data);
        }
      } catch (error) {
        console.error('Error loading transactions:', error);
      }
    };

    loadTransactions();
  }, []);

  // Load friends and friend requests
  useEffect(() => {
    const loadFriends = async () => {
      try {
        const response = await fetch('http://localhost:3000/friends/friends', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (response.ok) {
          const data = await response.json();
          setFriends(data);
        }
      } catch (error) {
        console.error('Error loading friends:', error);
      }
    };

    const loadFriendRequests = async () => {
      try {
        const response = await fetch('http://localhost:3000/friends/requests', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (response.ok) {
          const data = await response.json();
          setFriendRequests(data);
        }
      } catch (error) {
        console.error('Error loading friend requests:', error);
      }
    };

    const loadBalances = async () => {
      try {
        const response = await fetch('http://localhost:3000/friends/balances', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (response.ok) {
          const data = await response.json();
          setFriendBalances(data);
        }
      } catch (error) {
        console.error('Error loading balances:', error);
      }
    };

    loadFriends();
    loadFriendRequests();
    loadBalances();
  }, []);

  // Load available users for friend requests
  const loadUsers = async (searchTerm: string = '') => {
    try {
      const response = await fetch(`http://localhost:3000/friends/users?search=${searchTerm}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setUsers(data);
      }
    } catch (error) {
      console.error('Error loading users:', error);
    }
  };

  const handleSendFriendRequest = async (userId: string) => {
    try {
      const response = await fetch(`http://localhost:3000/friends/request/${userId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        alert('Friend request sent!');
        setShowAddFriend(false);
      } else {
        const data = await response.json();
        alert(data.error || 'Failed to send friend request');
      }
    } catch (error) {
      console.error('Error sending friend request:', error);
      alert('Failed to send friend request');
    }
  };

  const handleAcceptRequest = async (requestId: string) => {
    try {
      console.log('Accepting friend request:', requestId);
      
      const response = await fetch(`http://localhost:3000/friends/accept/${requestId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
          'Content-Type': 'application/json'
        }
      });
      
      const data = await response.json();
      console.log('Accept friend request response:', data);
      
      if (response.ok && data.success) {
        // Remove the accepted request from the list
        setFriendRequests(prev => prev.filter(req => req._id !== requestId));
        
        // Reload friends list
        const friendsResponse = await fetch('http://localhost:3000/friends/friends', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (friendsResponse.ok) {
          const friendsData = await friendsResponse.json();
          setFriends(friendsData);
        }

        // Reload balances
        const balancesResponse = await fetch('http://localhost:3000/friends/balances', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (balancesResponse.ok) {
          const balancesData = await balancesResponse.json();
          setFriendBalances(balancesData);
        }

        // Close the friend requests modal
        setShowFriendRequests(false);
        
        // Show success message
        alert('Friend request accepted successfully!');
      } else {
        throw new Error(data.error || data.details || 'Failed to accept friend request');
      }
    } catch (error: any) {
      console.error('Error accepting friend request:', error);
      alert(error?.message || 'Failed to accept friend request');
    }
  };

  const handleRejectRequest = async (requestId: string) => {
    try {
      const response = await fetch(`http://localhost:3000/friends/reject/${requestId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        setFriendRequests(prev => prev.filter(req => req._id !== requestId));
      } else {
        const data = await response.json();
        alert(data.error || 'Failed to reject friend request');
      }
    } catch (error) {
      console.error('Error rejecting friend request:', error);
      alert('Failed to reject friend request');
    }
  };

  const handleSplitPayment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedFriend) return;

    try {
      const response = await fetch('http://localhost:3000/friends/transaction', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          friendId: selectedFriend._id,
          description: newTransaction.description,
          amount: parseFloat(newTransaction.amount),
          splitType: newTransaction.splitType,
          splitPercentage: newTransaction.splitType === 'custom' ? newTransaction.splitPercentage : undefined
        })
      });

      if (response.ok) {
        const transaction = await response.json();
        setTransactions(prev => [transaction, ...prev]);
        
        // Reload balances
        const balancesResponse = await fetch('http://localhost:3000/friends/balances', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (balancesResponse.ok) {
          const balances = await balancesResponse.json();
          setFriendBalances(balances);
        }

        // Reset form and close modal
        setNewTransaction({ description: '', amount: '', splitType: '50-50', splitPercentage: 50 });
        setShowSplitPayment(false);
        
        // Show success message
        alert('Transaction created successfully!');
      } else {
        const data = await response.json();
        alert(data.error || 'Failed to create transaction');
      }
    } catch (error) {
      console.error('Error creating transaction:', error);
      alert('Failed to create transaction');
    }
  };

  const handleMarkAsCompleted = async (transactionId: string) => {
    try {
      const response = await fetch(`http://localhost:3000/friends/transaction/${transactionId}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (response.ok) {
        // Update transactions list
        setTransactions(prev => 
          prev.map(t => t._id === transactionId ? { ...t, status: 'completed' } : t)
        );

        // Reload balances
        const balancesResponse = await fetch('http://localhost:3000/friends/balances', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (balancesResponse.ok) {
          const balances = await balancesResponse.json();
          setFriendBalances(balances);
        }

        // Show success message
        alert('Transaction marked as completed!');
      }
    } catch (error) {
      console.error('Error updating transaction:', error);
      alert('Failed to update transaction');
    }
  };

  const loadFriendTransactions = async (friendId: string) => {
    try {
      const response = await fetch(`http://localhost:3000/friends/transactions/${friendId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setSelectedFriendTransactions(data);
        setShowTransactions(true);
      }
    } catch (error) {
      console.error('Error loading friend transactions:', error);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  };

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2
    }).format(amount);
  };

  return (
    <div className="friends-container">
      <div className="friends-header">
        <h1>Friends</h1>
        <div className="friends-actions">
          <button 
            className="friend-requests-btn"
            onClick={() => {
              setShowFriendRequests(true);
              setShowAddFriend(false);
            }}
          >
            {friendRequests.length > 0 && (
              <span className="request-badge">{friendRequests.length}</span>
            )}
            Friend Requests
          </button>
          <button 
            className="add-friend-btn"
            onClick={() => {
              setShowAddFriend(true);
              setShowFriendRequests(false);
              loadUsers();
            }}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M12 5v14M5 12h14" />
            </svg>
            Add Friend
          </button>
        </div>
      </div>

      <div className="friends-grid">
        <div className="friends-list">
          <div className="friends-list-header">
            <h2>Your Friends</h2>
            <p>{friends.length} {friends.length === 1 ? 'friend' : 'friends'}</p>
          </div>
          
          {friends.map(friend => {
            const balance = friendBalances.find(b => b.friend._id === friend._id)?.balance || 0;
            return (
              <div key={friend._id} className="friend-card">
                <div className="friend-avatar">{friend.fullName.charAt(0).toUpperCase()}</div>
                <div className="friend-details">
                  <h3>{friend.fullName}</h3>
                  <p>{friend.email}</p>
                </div>
                <div className="friend-balance">
                  <span className={balance >= 0 ? 'positive' : 'negative'}>
                    {balance >= 0 
                      ? `Owes you ${formatAmount(balance)}` 
                      : `You owe ${formatAmount(Math.abs(balance))}`}
                  </span>
                </div>
                <div className="friend-actions">
                  <button 
                    className="split-btn"
                    onClick={() => {
                      setSelectedFriend(friend);
                      setShowSplitPayment(true);
                    }}
                  >
                    Split Payment
                  </button>
                  <button 
                    className="transactions-btn"
                    onClick={() => loadFriendTransactions(friend._id)}
                  >
                    View History
                  </button>
                  {balance !== 0 && (
                    <button 
                      className={`${balance >= 0 ? 'remind-btn' : 'pay-btn'}`}
                      onClick={() => {
                        if (balance >= 0) {
                          alert(`Reminder sent to ${friend.fullName}`);
                        } else {
                          alert('Payment feature coming soon!');
                        }
                      }}
                    >
                      {balance >= 0 ? 'Remind' : 'Pay'}
                    </button>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        <div className="transactions-list">
          <div className="transactions-header">
            <h2>Recent Activity</h2>
            <div className="transaction-filters">
              <button 
                className={`filter-btn ${!showTransactions ? 'active' : ''}`}
                onClick={() => {
                  setShowTransactions(false);
                }}
              >
                All
              </button>
              <button 
                className={`filter-btn ${showTransactions ? 'active' : ''}`}
                onClick={() => {
                  setShowTransactions(true);
                }}
              >
                Pending
              </button>
            </div>
          </div>

          {(showTransactions ? transactions.filter(t => t.status === 'pending') : transactions).map(transaction => (
            <div key={transaction._id} className="transaction-item">
              <div className="transaction-info">
                <span className="transaction-friend">
                  {transaction.payer._id === localStorage.getItem('userId') 
                    ? transaction.payee.fullName 
                    : transaction.payer.fullName}
                </span>
                <span className="transaction-desc">{transaction.description}</span>
                <span className="transaction-date">{formatDate(transaction.date)}</span>
                <span className={`transaction-status ${transaction.status}`}>
                  {transaction.status}
                </span>
              </div>
              <div className="transaction-actions">
                <span className={`transaction-amount ${
                  transaction.payer._id === localStorage.getItem('userId') ? 'positive' : 'negative'
                }`}>
                  {transaction.payer._id === localStorage.getItem('userId')
                    ? formatAmount(transaction.amount)
                    : `-${formatAmount(transaction.amount)}`}
                </span>
                {transaction.status === 'pending' && (
                  <button 
                    className="complete-btn"
                    onClick={() => handleMarkAsCompleted(transaction._id)}
                  >
                    Mark as Paid
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {showAddFriend && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Add New Friend</h2>
            <div className="search-container">
              <input
                type="text"
                placeholder="Search by name or email..."
                className="search-input"
                onChange={(e) => loadUsers(e.target.value)}
              />
            </div>
            <div className="users-list">
              {users.map(user => (
                <div key={user._id} className="user-item">
                  <div className="user-info">
                    <div className="user-avatar">{user.fullName.charAt(0).toUpperCase()}</div>
                    <div>
                      <h3>{user.fullName}</h3>
                      <p>{user.email}</p>
                    </div>
                  </div>
                  <button 
                    className="add-user-btn"
                    onClick={() => handleSendFriendRequest(user._id)}
                  >
                    Add Friend
                  </button>
                </div>
              ))}
            </div>
            <button 
              className="close-modal-btn"
              onClick={() => setShowAddFriend(false)}
            >
              Close
            </button>
          </div>
        </div>
      )}

      {showFriendRequests && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Friend Requests</h2>
            <div className="requests-list">
              {friendRequests.length === 0 ? (
                <p className="no-requests">No pending friend requests</p>
              ) : (
                friendRequests.map(request => (
                  <div key={request._id} className="request-item">
                    <div className="request-info">
                      <div className="request-avatar">
                        {request.sender.fullName.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <h3>{request.sender.fullName}</h3>
                        <p>{request.sender.email}</p>
                      </div>
                    </div>
                    <div className="request-actions">
                      <button 
                        className="accept-btn"
                        onClick={() => handleAcceptRequest(request._id)}
                      >
                        Accept
                      </button>
                      <button 
                        className="reject-btn"
                        onClick={() => handleRejectRequest(request._id)}
                      >
                        Reject
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
            <button 
              className="close-modal-btn"
              onClick={() => setShowFriendRequests(false)}
            >
              Close
            </button>
          </div>
        </div>
      )}

      {showSplitPayment && selectedFriend && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Split Payment with {selectedFriend.fullName}</h2>
            <form onSubmit={handleSplitPayment}>
              <div className="input-group">
                <label>Description</label>
                <input
                  type="text"
                  value={newTransaction.description}
                  onChange={(e) => setNewTransaction({ ...newTransaction, description: e.target.value })}
                  placeholder="What's this for?"
                  required
                />
              </div>
              <div className="input-group">
                <label>Total Amount</label>
                <input
                  type="number"
                  value={newTransaction.amount}
                  onChange={(e) => setNewTransaction({ ...newTransaction, amount: e.target.value })}
                  placeholder="Enter total amount"
                  min="0"
                  step="0.01"
                  required
                />
              </div>
              <div className="input-group">
                <label>Split Type</label>
                <select
                  value={newTransaction.splitType}
                  onChange={(e) => {
                    const splitType = e.target.value as SplitType;
                    setNewTransaction({ 
                      ...newTransaction, 
                      splitType,
                      splitPercentage: splitType === 'custom' ? newTransaction.splitPercentage : 50
                    });
                  }}
                >
                  <option value="50-50">Split 50/50</option>
                  <option value="payer-full">You pay full amount</option>
                  <option value="payee-full">Friend pays full amount</option>
                  <option value="custom">Custom split</option>
                </select>
              </div>
              
              {newTransaction.splitType === 'custom' && (
                <div className="input-group">
                  <label>Your Share Percentage</label>
                  <div className="percentage-input">
                    <input
                      type="range"
                      min="0"
                      max="100"
                      value={newTransaction.splitPercentage}
                      onChange={(e) => setNewTransaction({ 
                        ...newTransaction, 
                        splitPercentage: parseInt(e.target.value)
                      })}
                    />
                    <span className="percentage-value">{newTransaction.splitPercentage}%</span>
                  </div>
                  <div className="split-preview">
                    <p>You pay: {formatAmount((parseFloat(newTransaction.amount) || 0) * (newTransaction.splitPercentage / 100))}</p>
                    <p>Friend pays: {formatAmount((parseFloat(newTransaction.amount) || 0) * ((100 - newTransaction.splitPercentage) / 100))}</p>
                  </div>
                </div>
              )}

              <div className="modal-actions">
                <button type="button" onClick={() => setShowSplitPayment(false)}>Cancel</button>
                <button type="submit">Split Payment</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showTransactions && selectedFriendTransactions.length > 0 && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Transaction History</h2>
            <div className="transactions-list">
              {selectedFriendTransactions.map(transaction => (
                <div key={transaction._id} className="transaction-item">
                  <div className="transaction-info">
                    <span className="transaction-desc">{transaction.description}</span>
                    <span className="transaction-date">{formatDate(transaction.date)}</span>
                    <span className={`transaction-status ${transaction.status}`}>
                      {transaction.status}
                    </span>
                  </div>
                  <div className="transaction-actions">
                    <span className={`transaction-amount ${
                      transaction.payer._id === localStorage.getItem('userId') ? 'positive' : 'negative'
                    }`}>
                      {transaction.payer._id === localStorage.getItem('userId')
                        ? formatAmount(transaction.amount)
                        : `-${formatAmount(transaction.amount)}`}
                    </span>
                    {transaction.status === 'pending' && (
                      <button 
                        className="complete-btn"
                        onClick={() => handleMarkAsCompleted(transaction._id)}
                      >
                        Mark as Paid
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
            <button 
              className="close-modal-btn"
              onClick={() => setShowTransactions(false)}
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default Friends; 