import React, { useState } from 'react';
import personalTransactionService, { Transaction } from '../../services/personalTransactionService'; // Importăm serviciul și tipul

interface AddTransactionProps {
    onTransactionAdded: () => void;
    onCancel: () => void; // Adăugăm un handler pentru anulare/închidere
}

const AddTransaction: React.FC<AddTransactionProps> = ({ onTransactionAdded, onCancel }) => {
    const [formData, setFormData] = useState({
        description: '',
        amount: '',
        type: 'expense' as 'expense' | 'income',
        category: '',
        date: new Date().toISOString().split('T')[0],
        notes: '',
        tags: '',
        isSubscription: false,
        // Inițializăm complet pentru a evita erori, chiar dacă nu toate câmpurile sunt afișate/folosite inițial
        subscriptionDetails: {
            frequency: 'monthly' as 'monthly' | 'yearly',
            nextDueDate: new Date().toISOString().split('T')[0]
        }
    });

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value, type } = e.target;

        // Gestionare pentru sub-obiectele din subscriptionDetails
        if (name.startsWith('subscriptionDetails.')) {
            const subFieldName = name.split('.')[1];
            setFormData(prev => ({
                ...prev,
                subscriptionDetails: {
                    ...prev.subscriptionDetails,
                    [subFieldName]: value
                }
            }));
        } else if (type === 'checkbox') {
             const checked = (e.target as HTMLInputElement).checked;
             setFormData(prev => ({
                 ...prev,
                 [name]: checked,
                 // Resetează subscriptionDetails când isSubscription devine false
                 ...(name === 'isSubscription' && !checked && { 
                     subscriptionDetails: { 
                         frequency: 'monthly', 
                         nextDueDate: new Date().toISOString().split('T')[0] 
                     }
                  })
             }));
        } else {
            setFormData(prev => ({
                ...prev,
                [name]: value
            }));
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            // Pregătește datele pentru a se potrivi cu expected body-ul backend-ului
            const transactionData: Omit<Transaction, '_id'> = {
                 description: formData.description,
                 amount: parseFloat(formData.amount),
                 type: formData.type,
                 category: formData.category,
                 date: formData.date, // Data este deja în format string YYYY-MM-DD
                 notes: formData.notes,
                 tags: formData.tags ? formData.tags.split(',').map(tag => tag.trim()) : [],
                 isSubscription: formData.isSubscription,
                 // Include subscriptionDetails doar dacă este subscripție și nextDueDate are valoare
                 ...(formData.isSubscription && formData.subscriptionDetails?.nextDueDate && {
                     subscriptionDetails: {
                         frequency: formData.subscriptionDetails.frequency,
                         nextDueDate: formData.subscriptionDetails.nextDueDate, // Trimitem string-ul YYYY-MM-DD
                     }
                 })
            };

            console.log('Submitting personal transaction data:', transactionData);

            const addedTransaction = await personalTransactionService.addTransaction(transactionData);
            console.log('Personal transaction added successfully:', addedTransaction);

            // Resetare form și închidere modal la succes
            setFormData({
                description: '',
                amount: '',
                type: 'expense',
                category: '',
                date: new Date().toISOString().split('T')[0],
                notes: '',
                tags: '',
                isSubscription: false,
                subscriptionDetails: { // Resetează la valoarea inițială
                    frequency: 'monthly',
                    nextDueDate: new Date().toISOString().split('T')[0]
                }
            });
            onTransactionAdded(); // Notifică părintele pentru refresh
            onCancel(); // Închide modalul

        } catch (error: any) {
            console.error('Error adding personal transaction:', error);
            // Afișează o eroare mai specifică utilizatorului
            alert('Failed to add transaction: ' + (error.response?.data?.error || error.message || 'Unknown error'));
        }
    };

    console.log('AddTransaction.tsx: Rendering component', new Date().toLocaleTimeString());

    return (
        <div className="add-transaction-form">
            <h2>Add New Transaction</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="description">Description</label>
                    <input type="text" id="description" name="description" value={formData.description} onChange={handleChange} required placeholder="e.g., Groceries"/>
                </div>
                <div className="form-group">
                    <label htmlFor="amount">Amount</label>
                    <input type="number" id="amount" name="amount" value={formData.amount} onChange={handleChange} step="0.01" min="0" required placeholder="0.00"/>
                </div>
                <div className="form-group">
                    <label htmlFor="type">Type</label>
                    <select id="type" name="type" value={formData.type} onChange={handleChange} required>
                        <option value="expense">Expense</option>
                        <option value="income">Income</option>
                    </select>
                </div>
                <div className="form-group">
                    <label htmlFor="category">Category</label>
                    <input type="text" id="category" name="category" value={formData.category} onChange={handleChange} required placeholder="e.g., Food"/>
                </div>
                <div className="form-group">
                    <label htmlFor="date">Date</label>
                    <input type="date" id="date" name="date" value={formData.date} onChange={handleChange} required />
                </div>
                <div className="form-group">
                    <label htmlFor="notes">Notes</label>
                    <textarea id="notes" name="notes" value={formData.notes} onChange={handleChange} placeholder="Optional notes"></textarea>
                </div>
                <div className="form-group">
                    <label htmlFor="tags">Tags (comma separated)</label>
                    <input type="text" id="tags" name="tags" value={formData.tags} onChange={handleChange} placeholder="e.g., bills, utilities"/>
                </div>
                <div className="form-group checkbox">
                    <label>
                        <input type="checkbox" name="isSubscription" checked={formData.isSubscription} onChange={handleChange} /> This is a subscription
                    </label>
                </div>
                {formData.isSubscription && (
                    <div className="subscription-details">
                        <div className="form-group">
                            <label htmlFor="frequency">Frequency</label>
                            <select id="frequency" name="subscriptionDetails.frequency" value={formData.subscriptionDetails.frequency} onChange={handleChange} required>
                                <option value="monthly">Monthly</option>
                                <option value="yearly">Yearly</option>
                            </select>
                        </div>
                         <div className="form-group">
                            <label htmlFor="nextDueDate">Next Due Date</label>
                            <input type="date" id="nextDueDate" name="subscriptionDetails.nextDueDate" value={formData.subscriptionDetails.nextDueDate} onChange={handleChange} required />
                        </div>
                    </div>
                )}
                <div className="form-actions">
                    <button type="button" className="cancel-btn" onClick={onCancel}>Cancel</button>
                    <button type="submit" className="submit-button">Add Transaction</button>
                </div>
            </form>
        </div>
    );
};

export default AddTransaction; 