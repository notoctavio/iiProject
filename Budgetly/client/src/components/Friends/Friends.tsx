import React, { useState } from 'react';
import './Friends.css';

interface Friend {
  id: string;
  name: string;
  avatar: string;
  email: string;
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
  const [friends, setFriends] = useState<Friend[]>([
    {
      id: '1',
      name: 'Alex Johnson',
      avatar: 'AJ',
      email: 'alex@example.com',
      balance: 45.00,
      transactions: [
        {
          id: 't1',
          description: 'Dinner at Italian Restaurant',
          amount: 45.00,
          date: '2024-06-10',
          type: 'debt',
          status: 'pending'
        }
      ]
    },
    {
      id: '2',
      name: 'Sarah Miller',
      avatar: 'SM',
      email: 'sarah@example.com',
      balance: -23.00,
      transactions: [
        {
          id: 't2',
          description: 'Movie tickets',
          amount: 23.00,
          date: '2024-06-09',
          type: 'credit',
          status: 'pending'
        }
      ]
    }
  ]);

  const [showAddFriend, setShowAddFriend] = useState(false);
  const [showSplitPayment, setShowSplitPayment] = useState(false);
  const [selectedFriend, setSelectedFriend] = useState<Friend | null>(null);
  const [newFriend, setNewFriend] = useState({ name: '', email: '' });
  const [newTransaction, setNewTransaction] = useState({
    description: '',
    amount: '',
    splitType: '50-50'
  });

  const handleAddFriend = (e: React.FormEvent) => {
    e.preventDefault();
    const newFriendData: Friend = {
      id: Date.now().toString(),
      name: newFriend.name,
      avatar: newFriend.name.split(' ').map(n => n[0]).join(''),
      email: newFriend.email,
      balance: 0,
      transactions: []
    };
    setFriends([...friends, newFriendData]);
    setNewFriend({ name: '', email: '' });
    setShowAddFriend(false);
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
      if (friend.id === selectedFriend.id) {
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
        <button 
          className="add-friend-btn"
          onClick={() => setShowAddFriend(true)}
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M12 5v14M5 12h14" />
          </svg>
          Add Friend
        </button>
      </div>

      <div className="friends-grid">
        <div className="friends-list">
          <div className="friends-list-header">
            <h2>Your Friends</h2>
            <p>{friends.length} {friends.length === 1 ? 'friend' : 'friends'}</p>
          </div>
          
          {friends.map(friend => (
            <div key={friend.id} className="friend-card">
              <div className="friend-avatar">{friend.avatar}</div>
              <div className="friend-details">
                <h3>{friend.name}</h3>
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
                  <span className="transaction-friend">{friend.name}</span>
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
            <form onSubmit={handleAddFriend}>
              <div className="input-group">
                <label>Name</label>
                <input
                  type="text"
                  value={newFriend.name}
                  onChange={(e) => setNewFriend({ ...newFriend, name: e.target.value })}
                  placeholder="Enter friend's name"
                  required
                />
              </div>
              <div className="input-group">
                <label>Email</label>
                <input
                  type="email"
                  value={newFriend.email}
                  onChange={(e) => setNewFriend({ ...newFriend, email: e.target.value })}
                  placeholder="Enter friend's email"
                  required
                />
              </div>
              <div className="modal-actions">
                <button type="button" onClick={() => setShowAddFriend(false)}>Cancel</button>
                <button type="submit">Add Friend</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showSplitPayment && selectedFriend && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Split Payment with {selectedFriend.name}</h2>
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