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
  balance: number;
  transactions: Transaction[];
}

interface Transaction {
  id: string;
  description: string;
  amount: number;
  date: string;
  type: 'debt' | 'credit';
  status: 'pending' | 'completed';
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
    splitType: '50-50'
  });

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
          // Add balance and transactions to each friend (you can modify this based on your needs)
          const friendsWithBalance = data.map((friend: User) => ({
            ...friend,
            balance: 0,
            transactions: []
          }));
          setFriends(friendsWithBalance);
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

    loadFriends();
    loadFriendRequests();
  }, []);

  // Load available users for friend requests
  const loadUsers = async () => {
    try {
      const response = await fetch('http://localhost:3000/friends/users', {
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
      const response = await fetch(`http://localhost:3000/friends/accept/${requestId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        // Reload friends and requests
        window.location.reload();
      } else {
        const data = await response.json();
        alert(data.error || 'Failed to accept friend request');
      }
    } catch (error) {
      console.error('Error accepting friend request:', error);
      alert('Failed to accept friend request');
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

  const handleSplitPayment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedFriend) return;

    const amount = parseFloat(newTransaction.amount);
    const splitAmount = newTransaction.splitType === '50-50' ? amount / 2 : amount;

    const newTransactionData: Transaction = {
      id: Date.now().toString(),
      description: newTransaction.description,
      amount: splitAmount,
      date: new Date().toISOString().split('T')[0],
      type: 'debt',
      status: 'pending'
    };

    const updatedFriends = friends.map(friend => {
      if (friend._id === selectedFriend._id) {
        return {
          ...friend,
          balance: friend.balance + splitAmount,
          transactions: [newTransactionData, ...friend.transactions]
        };
      }
      return friend;
    });

    setFriends(updatedFriends);
    setNewTransaction({ description: '', amount: '', splitType: '50-50' });
    setShowSplitPayment(false);
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
          
          {friends.map(friend => (
            <div key={friend._id} className="friend-card">
              <div className="friend-avatar">{friend.fullName.charAt(0).toUpperCase()}</div>
              <div className="friend-details">
                <h3>{friend.fullName}</h3>
                <p>{friend.email}</p>
              </div>
              <div className="friend-balance">
                <span className={friend.balance >= 0 ? 'positive' : 'negative'}>
                  {friend.balance >= 0 
                    ? `Owes you ${formatAmount(friend.balance)}` 
                    : `You owe ${formatAmount(Math.abs(friend.balance))}`}
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
                {friend.balance !== 0 && (
                  <button className={`${friend.balance >= 0 ? 'remind-btn' : 'pay-btn'}`}>
                    {friend.balance >= 0 ? 'Remind' : 'Pay'}
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>

        <div className="transactions-list">
          <div className="transactions-header">
            <h2>Recent Activity</h2>
            <div className="transaction-filters">
              <button className="filter-btn active">All</button>
              <button className="filter-btn">Pending</button>
              <button className="filter-btn">Completed</button>
            </div>
          </div>

          {friends.flatMap(friend => 
            friend.transactions.map(transaction => (
              <div key={transaction.id} className="transaction-item">
                <div className="transaction-info">
                  <span className="transaction-friend">{friend.fullName}</span>
                  <span className="transaction-desc">{transaction.description}</span>
                  <span className="transaction-date">{formatDate(transaction.date)}</span>
                </div>
                <span className={`transaction-amount ${transaction.type === 'debt' ? 'positive' : 'negative'}`}>
                  {transaction.type === 'debt' 
                    ? formatAmount(transaction.amount)
                    : `-${formatAmount(transaction.amount)}`}
                </span>
              </div>
            ))
          )}
        </div>
      </div>

      {showAddFriend && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Add New Friend</h2>
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
                  onChange={(e) => setNewTransaction({ ...newTransaction, splitType: e.target.value })}
                >
                  <option value="50-50">Split 50/50</option>
                  <option value="full">Full Amount</option>
                </select>
              </div>
              <div className="modal-actions">
                <button type="button" onClick={() => setShowSplitPayment(false)}>Cancel</button>
                <button type="submit">Split Payment</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Friends; 