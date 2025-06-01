import React, { useState, useEffect } from 'react';
import './FriendsDebts.css';

interface User {
  _id: string;
  fullName: string;
  email: string;
}

interface Transaction {
  _id: string;
  description: string;
  amount: number;
  splitType: '50-50' | 'full';
  status: 'pending' | 'completed';
  payer: User;
  payee: User;
  date: string;
}

interface FriendBalance {
  friend: User;
  balance: number;
}

const FriendsDebts: React.FC = () => {
  const [friendBalances, setFriendBalances] = useState<FriendBalance[]>([]);
  const [recentTransactions, setRecentTransactions] = useState<Transaction[]>([]);

  useEffect(() => {
    const loadData = async () => {
      try {
        // Load balances
        const balancesResponse = await fetch('http://localhost:3000/friends/balances', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (balancesResponse.ok) {
          const balances = await balancesResponse.json();
          setFriendBalances(balances);
        }

        // Load recent transactions
        const transactionsResponse = await fetch('http://localhost:3000/friends/transactions', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (transactionsResponse.ok) {
          const transactions = await transactionsResponse.json();
          // Get only the 5 most recent pending transactions
          setRecentTransactions(
            transactions
              .filter((t: Transaction) => t.status === 'pending')
              .slice(0, 5)
          );
        }
      } catch (error) {
        console.error('Error loading data:', error);
      }
    };

    loadData();
  }, []);

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric'
    });
  };

  return (
    <div className="pro-card pro-friends">
      <h2>Friends & Debts</h2>
      
      {/* Friend Balances */}
      <div className="pro-friends-list">
        {friendBalances.map(({ friend, balance }) => (
          <div key={friend._id} className="pro-friend-item">
            <div className="pro-friend-avatar">
              {friend.fullName.charAt(0).toUpperCase()}
            </div>
            <div className="pro-friend-info">
              <span className="pro-friend-name">{friend.fullName}</span>
              <span className={`pro-friend-amount ${balance >= 0 ? 'positive' : 'negative'}`}>
                {balance >= 0 
                  ? `Owes you ${formatAmount(balance)}` 
                  : `You owe ${formatAmount(Math.abs(balance))}`}
              </span>
            </div>
            {balance !== 0 && (
              <button 
                className={`${balance >= 0 ? 'pro-remind-btn' : 'pro-pay-btn'}`}
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
        ))}
        {friendBalances.length === 0 && (
          <div className="no-friends-message">
            No friends or pending debts
          </div>
        )}
      </div>

      {/* Recent Transactions */}
      {recentTransactions.length > 0 && (
        <div className="pro-recent-transactions">
          <h3>Recent Pending Bills</h3>
          <div className="pro-transactions-list">
            {recentTransactions.map(transaction => (
              <div key={transaction._id} className="pro-transaction-item">
                <div className="pro-transaction-info">
                  <span className="pro-transaction-friend">
                    {transaction.payer._id === localStorage.getItem('userId') 
                      ? transaction.payee.fullName 
                      : transaction.payer.fullName}
                  </span>
                  <span className="pro-transaction-desc">{transaction.description}</span>
                  <span className="pro-transaction-date">{formatDate(transaction.date)}</span>
                </div>
                <span className={`pro-transaction-amount ${
                  transaction.payer._id === localStorage.getItem('userId') ? 'positive' : 'negative'
                }`}>
                  {transaction.payer._id === localStorage.getItem('userId')
                    ? formatAmount(transaction.amount)
                    : `-${formatAmount(transaction.amount)}`}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default FriendsDebts; 