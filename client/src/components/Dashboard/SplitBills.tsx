import React, { useState } from 'react';
import './SplitBills.css';

interface SplitBill {
    id: string;
    description: string;
    amount: number;
    paidBy: string;
    splitBetween: string[];
    date: string;
    status: 'pending' | 'settled';
}

const SplitBills: React.FC = () => {
    const [bills, setBills] = useState<SplitBill[]>([
        {
            id: '1',
            description: 'Dinner at Restaurant',
            amount: 120.00,
            paidBy: 'John Doe',
            splitBetween: ['John Doe', 'Jane Smith', 'Mike Johnson'],
            date: '2024-03-15',
            status: 'pending'
        },
        {
            id: '2',
            description: 'Movie Tickets',
            amount: 45.00,
            paidBy: 'Jane Smith',
            splitBetween: ['John Doe', 'Jane Smith'],
            date: '2024-03-14',
            status: 'settled'
        }
    ]);

    const [showAddBill, setShowAddBill] = useState(false);
    const [newBill, setNewBill] = useState({
        description: '',
        amount: '',
        paidBy: '',
        splitBetween: [] as string[]
    });

    const friends = [
        { id: '1', name: 'John Doe' },
        { id: '2', name: 'Jane Smith' },
        { id: '3', name: 'Mike Johnson' }
    ];

    const handleAddBill = (e: React.FormEvent) => {
        e.preventDefault();
        const bill: SplitBill = {
            id: Date.now().toString(),
            description: newBill.description,
            amount: parseFloat(newBill.amount),
            paidBy: newBill.paidBy,
            splitBetween: newBill.splitBetween,
            date: new Date().toISOString().split('T')[0],
            status: 'pending'
        };
        setBills([...bills, bill]);
        setNewBill({
            description: '',
            amount: '',
            paidBy: '',
            splitBetween: []
        });
        setShowAddBill(false);
    };

    const handleSplitBetweenChange = (friendName: string) => {
        setNewBill(prev => ({
            ...prev,
            splitBetween: prev.splitBetween.includes(friendName)
                ? prev.splitBetween.filter(name => name !== friendName)
                : [...prev.splitBetween, friendName]
        }));
    };

    const calculateSplitAmount = (bill: SplitBill) => {
        return (bill.amount / bill.splitBetween.length).toFixed(2);
    };

    return (
        <div className="split-bills">
            <div className="bills-header">
                <h2>Split Bills</h2>
                <button 
                    className="add-bill-btn"
                    onClick={() => setShowAddBill(true)}
                >
                    Add New Bill
                </button>
            </div>

            {showAddBill && (
                <div className="add-bill-modal">
                    <div className="modal-content">
                        <h3>Add New Bill</h3>
                        <form onSubmit={handleAddBill}>
                            <div className="form-group">
                                <label htmlFor="description">Description</label>
                                <input
                                    type="text"
                                    id="description"
                                    value={newBill.description}
                                    onChange={(e) => setNewBill({ ...newBill, description: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label htmlFor="amount">Amount</label>
                                <input
                                    type="number"
                                    id="amount"
                                    value={newBill.amount}
                                    onChange={(e) => setNewBill({ ...newBill, amount: e.target.value })}
                                    required
                                    min="0"
                                    step="0.01"
                                />
                            </div>
                            <div className="form-group">
                                <label htmlFor="paidBy">Paid By</label>
                                <select
                                    id="paidBy"
                                    value={newBill.paidBy}
                                    onChange={(e) => setNewBill({ ...newBill, paidBy: e.target.value })}
                                    required
                                >
                                    <option value="">Select a friend</option>
                                    {friends.map(friend => (
                                        <option key={friend.id} value={friend.name}>
                                            {friend.name}
                                        </option>
                                    ))}
                                </select>
                            </div>
                            <div className="form-group">
                                <label>Split Between</label>
                                <div className="split-between-options">
                                    {friends.map(friend => (
                                        <label key={friend.id} className="checkbox-label">
                                            <input
                                                type="checkbox"
                                                checked={newBill.splitBetween.includes(friend.name)}
                                                onChange={() => handleSplitBetweenChange(friend.name)}
                                            />
                                            {friend.name}
                                        </label>
                                    ))}
                                </div>
                            </div>
                            <div className="form-actions">
                                <button type="submit" className="submit-btn">Add Bill</button>
                                <button 
                                    type="button" 
                                    className="cancel-btn"
                                    onClick={() => setShowAddBill(false)}
                                >
                                    Cancel
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            <div className="bills-list">
                {bills.map(bill => (
                    <div key={bill.id} className="bill-card">
                        <div className="bill-header">
                            <h3>{bill.description}</h3>
                            <span className={`status-badge ${bill.status}`}>
                                {bill.status.charAt(0).toUpperCase() + bill.status.slice(1)}
                            </span>
                        </div>
                        <div className="bill-details">
                            <div className="bill-info">
                                <p className="amount">${bill.amount.toFixed(2)}</p>
                                <p className="date">{bill.date}</p>
                            </div>
                            <div className="bill-split">
                                <p>Paid by: {bill.paidBy}</p>
                                <p>Split between: {bill.splitBetween.join(', ')}</p>
                                <p className="split-amount">
                                    Each person pays: ${calculateSplitAmount(bill)}
                                </p>
                            </div>
                        </div>
                        {bill.status === 'pending' && (
                            <div className="bill-actions">
                                <button className="action-btn">Mark as Settled</button>
                                <button className="action-btn">Edit</button>
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
};

export default SplitBills; 