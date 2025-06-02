import React, { useState } from 'react';

interface AddFriendTransactionProps {
    friendId: string;
    friendName: string;
    onTransactionAdded: () => void;
    onCancel: () => void;
}

const AddFriendTransaction: React.FC<AddFriendTransactionProps> = ({
    friendId,
    friendName,
    onTransactionAdded,
    onCancel
}) => {
    const [formData, setFormData] = useState({
        description: '',
        amount: '',
        splitType: '50-50' as '50-50' | 'full' | 'payer-full' | 'payee-full',
        splitPercentage: '50'
    });

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            let backendSplitType: '50-50' | 'payer-full' | 'payee-full';
            if (formData.splitType === '50-50') {
                backendSplitType = '50-50';
            } else {
                backendSplitType = 'payer-full';
            }

            const response = await fetch('http://localhost:3000/friends/transaction', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                },
                body: JSON.stringify({
                    friendId,
                    description: formData.description,
                    amount: parseFloat(formData.amount),
                    splitType: backendSplitType,
                })
            });

            if (response.ok) {
                onTransactionAdded();
            } else {
                const error = await response.json();
                alert(error.error || 'Failed to add transaction');
            }
        } catch (error) {
            console.error('Error adding transaction:', error);
            alert('Failed to add transaction');
        }
    };

    return (
        <div className="add-transaction-modal">
            <div className="modal-content">
                <h2>Add Transaction with {friendName}</h2>
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label htmlFor="description">Description</label>
                        <input
                            type="text"
                            id="description"
                            name="description"
                            value={formData.description}
                            onChange={handleChange}
                            required
                            placeholder="What's this for?"
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="amount">Amount</label>
                        <input
                            type="number"
                            id="amount"
                            name="amount"
                            value={formData.amount}
                            onChange={handleChange}
                            step="0.01"
                            min="0"
                            required
                            placeholder="0.00"
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="splitType">Split Type</label>
                        <select
                            id="splitType"
                            name="splitType"
                            value={formData.splitType}
                            onChange={handleChange}
                            required
                        >
                            <option value="50-50">Split 50-50</option>
                            <option value="full">I paid full amount</option>
                        </select>
                    </div>

                    <div className="form-actions">
                        <button type="button" className="cancel-btn" onClick={onCancel}>
                            Cancel
                        </button>
                        <button type="submit" className="submit-btn">
                            Add Transaction
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default AddFriendTransaction; 