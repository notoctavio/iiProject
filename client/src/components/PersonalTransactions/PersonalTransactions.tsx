import React, { useState, useEffect } from 'react';
import TransactionList from './TransactionList';
import AddTransaction from './AddTransaction'; // Reactivat
import personalTransactionService, { MonthlySummary, Transaction } from '../../services/personalTransactionService';
import './PersonalTransactions.css';
import { PlusIcon } from '../Icons';

// ADAUGĂ LOG AICI
console.log('PersonalTransactions.tsx: Component rendering or re-rendering', new Date().toLocaleTimeString());

const PersonalTransactions: React.FC = () => {
    // console.log('PersonalTransactions.tsx: Functional component body executing'); // Log alternativ, se poate adăuga aici
    const [showAddForm, setShowAddForm] = useState(false);
    const [monthlySummary, setMonthlySummary] = useState<MonthlySummary | null>(null);
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const fetchTransactionsAndSummary = async () => {
        try {
            const [summary, allTransactions] = await Promise.all([
                personalTransactionService.getMonthlySummary(),
                personalTransactionService.getTransactions()
            ]);
            setMonthlySummary(summary);
            setTransactions(allTransactions);
            setError(null);
        } catch (err) {
            setError('Failed to fetch data');
            console.error('Error fetching data:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchTransactionsAndSummary();
    }, []);

    const handleTransactionAdded = () => {
        setShowAddForm(false);
        fetchTransactionsAndSummary(); // Refresh data after adding transaction
    };

    if (loading) return <div>Loading...</div>;
    if (error) return <div className="error">{error}</div>;

    const activeSubscriptions = transactions.filter(t => t.isSubscription && t.type === 'expense');
    const regularIncome = transactions.filter(t => t.type === 'income' && !t.isSubscription);
    const recentTransactions = transactions.filter(t => !t.isSubscription).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    return (
        <div className="personal-transactions">
            <div className="pro-main-header">
                <h1>Expenses & Income</h1>
                <button
                    className="add-button primary"
                    onClick={() => {
                        // console.log('Button clicked! Toggling form visibility.'); // Eliminat
                        // console.log('Current showAddForm state before toggle:', showAddForm); // Eliminat
                        setShowAddForm(!showAddForm);
                    }}
                >
                    <PlusIcon /> {showAddForm ? 'Cancel' : 'Add Transaction'} {/* Text buton restaurat */}
                </button>
            </div>

            {/* Modal pentru AddTransaction restaurat */}
            {showAddForm && (
                <div className="modal-overlay">
                    <div className="modal-content">
                         <AddTransaction
                            onTransactionAdded={handleTransactionAdded}
                            onCancel={() => setShowAddForm(false)}
                         />
                    </div>
                </div>
            )}

            <div className="sections-grid">
                <div className="subscriptions-section">
                    <div className="section-header">
                         <h2>Active Subscriptions</h2>
                         {/* Butonul Add New eliminat */}
                    </div>
                    {/* Render Active Subscriptions List */}
                     {activeSubscriptions.length > 0 ? (
                         <TransactionList transactions={activeSubscriptions} />
                     ) : (
                         <p>No active subscriptions.</p>
                     )}
                </div>

                 <div className="income-section">
                     <div className="section-header">
                         <h2>Regular Income</h2>
                         {/* Butonul Add New eliminat */}
                     </div>
                    {/* Render Regular Income List */}
                     {regularIncome.length > 0 ? (
                         <TransactionList transactions={regularIncome} />
                     ) : (
                         <p>No regular income.</p>
                     )}
                 </div>
             </div>

             <div className="recent-transactions-section">
                 <div className="section-header">
                     <h2>Recent Transactions</h2>
                     {/* Buttons All, Expenses, Income - will implement later */}
                 </div>
                 {/* Render Recent Transactions List */}
                 {recentTransactions.length > 0 ? (
                     <TransactionList transactions={recentTransactions} />
                 ) : (
                     <p>No recent transactions.</p>
                 )}
             </div>

            <div className="summary-section">
                <h2>Monthly Summary</h2>
                {monthlySummary && (
                    <div className="summary-cards">
                        <div className="summary-card income">
                            <h3>Income</h3>
                            <p>${monthlySummary.income.toFixed(2)}</p>
                        </div>
                        <div className="summary-card expenses">
                            <h3>Expenses</h3>
                            <p>${monthlySummary.expenses.toFixed(2)}</p>
                        </div>
                        <div className="summary-card subscriptions">
                            <h3>Subscriptions</h3>
                            <p>${monthlySummary.subscriptions.toFixed(2)}</p>
                        </div>
                        <div className="summary-card net">
                            <h3>Net</h3>
                            <p className={monthlySummary.net >= 0 ? 'positive' : 'negative'}>
                                ${monthlySummary.net.toFixed(2)}
                            </p>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

export default PersonalTransactions; 