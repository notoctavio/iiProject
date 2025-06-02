import React, { useEffect, useState } from 'react';
import { Transaction } from '../../services/personalTransactionService';
import personalTransactionService from '../../services/personalTransactionService';
import { format } from 'date-fns';

interface TransactionListProps {
    transactions: Transaction[];
}

const TransactionList: React.FC<TransactionListProps> = ({ transactions }) => {

    if (!transactions || transactions.length === 0) {
        return <p>No transactions to display.</p>;
    }

    return (
        <div className="transaction-list">
            <div className="transactions">
                {transactions.map((transaction) => (
                    <div key={transaction._id} className={`transaction ${transaction.type}`}>
                        <div className="transaction-header">
                            <h3>{transaction.description}</h3>
                            <span className={`amount ${transaction.type}`}>
                                {transaction.type === 'expense' ? '-' : '+'}${transaction.amount.toFixed(2)}
                            </span>
                        </div>
                        <div className="transaction-details">
                            <span className="category">{transaction.category}</span>
                            <span className="date">
                                {format(new Date(transaction.date), 'MMM dd, yyyy')}
                            </span>
                            {transaction.isSubscription && (
                                <span className="subscription-badge">Subscription</span>
                            )}
                        </div>
                        {transaction.notes && (
                            <p className="notes">{transaction.notes}</p>
                        )}
                        {transaction.tags && transaction.tags.length > 0 && (
                            <div className="tags">
                                {transaction.tags.map((tag: string) => (
                                    <span key={tag} className="tag">
                                        {tag}
                                    </span>
                                ))}
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
};

export default TransactionList;