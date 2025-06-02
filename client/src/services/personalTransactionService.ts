import axios from 'axios';

const API_URL = 'http://localhost:3000/personal-transactions';

export interface Transaction {
    _id: string;
    description: string;
    amount: number;
    type: 'income' | 'expense';
    category: string;
    date: string;
    isSubscription: boolean;
    subscriptionDetails?: {
        frequency: 'monthly' | 'yearly';
        nextDueDate?: string;
    };
    tags: string[];
    notes?: string;
}

export interface MonthlySummary {
    income: number;
    expenses: number;
    subscriptions: number;
    net: number;
}

const getAuthHeader = () => {
    const token = localStorage.getItem('token');
    return token ? { Authorization: `Bearer ${token}` } : {};
};

const personalTransactionService = {
    async getTransactions(): Promise<Transaction[]> {
        try {
            const response = await axios.get(API_URL, { headers: getAuthHeader() });
            return response.data;
        } catch (error) {
            console.error('Error fetching transactions:', error);
            throw error;
        }
    },

    async addTransaction(transaction: Omit<Transaction, '_id'>): Promise<Transaction> {
        try {
            const response = await axios.post(API_URL, transaction, { headers: getAuthHeader() });
            return response.data;
        } catch (error) {
            console.error('Error adding transaction:', error);
            throw error;
        }
    },

    async updateTransaction(id: string, transaction: Partial<Transaction>): Promise<Transaction> {
        try {
            const response = await axios.put(`${API_URL}/${id}`, transaction, { headers: getAuthHeader() });
            return response.data;
        } catch (error) {
            console.error('Error updating transaction:', error);
            throw error;
        }
    },

    async deleteTransaction(id: string): Promise<void> {
        try {
            await axios.delete(`${API_URL}/${id}`, { headers: getAuthHeader() });
        } catch (error) {
            console.error('Error deleting transaction:', error);
            throw error;
        }
    },

    async getMonthlySummary(): Promise<MonthlySummary> {
        try {
            const response = await axios.get(`${API_URL}/summary`, { headers: getAuthHeader() });
            return response.data;
        } catch (error) {
            console.error('Error fetching monthly summary:', error);
            throw error;
        }
    }
};

export default personalTransactionService; 