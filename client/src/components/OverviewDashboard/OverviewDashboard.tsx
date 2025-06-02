import React, { useEffect, useState } from 'react';
import personalTransactionService, { Transaction, MonthlySummary } from '../../services/personalTransactionService';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar
} from 'recharts';
import './OverviewDashboard.css';

// Helper pentru a extrage luna dintr-o dată
function getMonthYear(dateStr: string) {
  const d = new Date(dateStr);
  return `${d.toLocaleString('default', { month: 'short' })} ${d.getFullYear()}`;
}

const OverviewDashboard: React.FC = () => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [monthlySummary, setMonthlySummary] = useState<MonthlySummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
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
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div className="error">{error}</div>;

  // Monthly Overview
  const income = monthlySummary?.income || 0;
  const expenses = monthlySummary?.expenses || 0;
  const subscriptions = monthlySummary?.subscriptions || 0;
  const net = monthlySummary?.net || 0;

  // Upcoming Payments (următoarele subscripții sau venituri)
  const now = new Date();
  const upcoming = transactions
    .filter(t => {
      if (t.isSubscription && t.subscriptionDetails?.nextDueDate) {
        return new Date(t.subscriptionDetails.nextDueDate) > now;
      }
      if (t.type === 'income' && new Date(t.date) > now) {
        return true;
      }
      return false;
    })
    .sort((a, b) => {
      const dateA = a.isSubscription ? new Date(a.subscriptionDetails?.nextDueDate || a.date) : new Date(a.date);
      const dateB = b.isSubscription ? new Date(b.subscriptionDetails?.nextDueDate || b.date) : new Date(b.date);
      return dateA.getTime() - dateB.getTime();
    })
    .slice(0, 5);

  // Spending Categories (doar cheltuieli)
  const categoryMap: { [cat: string]: number } = {};
  transactions.forEach(t => {
    if (t.type === 'expense') {
      categoryMap[t.category] = (categoryMap[t.category] || 0) + t.amount;
    }
  });
  const categories = Object.entries(categoryMap).map(([cat, sum]) => ({ category: cat, amount: sum }));
  categories.sort((a, b) => b.amount - a.amount);

  // Date pentru grafic: evoluție lunară venituri/cheltuieli (ultimele 6 luni)
  const monthsSet = new Set<string>();
  const nowMonth = new Date();
  for (let i = 5; i >= 0; i--) {
    const d = new Date(nowMonth.getFullYear(), nowMonth.getMonth() - i, 1);
    monthsSet.add(`${d.getFullYear()}-${d.getMonth()}`);
  }
  const monthsArr = Array.from(monthsSet).map(str => {
    const [year, month] = str.split('-');
    return { year: +year, month: +month };
  });

  const chartData = monthsArr.map(({ year, month }) => {
    const label = `${new Date(year, month).toLocaleString('default', { month: 'short' })} ${year}`;
    const monthIncome = transactions.filter(t => t.type === 'income' && new Date(t.date).getFullYear() === year && new Date(t.date).getMonth() === month).reduce((sum, t) => sum + t.amount, 0);
    const monthExpense = transactions.filter(t => t.type === 'expense' && new Date(t.date).getFullYear() === year && new Date(t.date).getMonth() === month).reduce((sum, t) => sum + t.amount, 0);
    return {
      name: label,
      Income: monthIncome,
      Expenses: monthExpense
    };
  });

  return (
    <div className="overview-dashboard" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 32 }}>
      {/* Sumar dinamic */}
      <section style={{ background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px #0001', gridColumn: '1/2' }}>
        <h2>Monthly Overview</h2>
        <div style={{ marginTop: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
            <span>Income</span>
            <span style={{ color: '#22c55e', fontWeight: 600 }}>+${income.toFixed(2)}</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
            <span>Expenses</span>
            <span style={{ color: '#ef4444', fontWeight: 600 }}>-${expenses.toFixed(2)}</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
            <span>Subscriptions</span>
            <span style={{ color: '#6366f1', fontWeight: 600 }}>-${subscriptions.toFixed(2)}</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontWeight: 700, fontSize: 18, marginTop: 12 }}>
            <span>Net Flow</span>
            <span style={{ color: net >= 0 ? '#22c55e' : '#ef4444' }}>{net >= 0 ? '+' : '-'}${Math.abs(net).toFixed(2)}</span>
          </div>
        </div>
      </section>
      {/* Upcoming payments */}
      <section style={{ background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px #0001', gridColumn: '2/3' }}>
        <h2>Upcoming Payments</h2>
        <ul style={{ marginTop: 16, listStyle: 'none', padding: 0 }}>
          {upcoming.length === 0 && <li style={{ color: '#888' }}>No upcoming payments.</li>}
          {upcoming.map((t, idx) => {
            const date = t.isSubscription ? t.subscriptionDetails?.nextDueDate : t.date;
            return (
              <li key={t._id + idx} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
                <span>{new Date(date || '').toLocaleDateString()} <b>{t.description}</b></span>
                <span style={{ color: t.type === 'income' ? '#22c55e' : '#ef4444', fontWeight: 600 }}>{t.type === 'income' ? '+' : '-'}${t.amount.toFixed(2)}</span>
                <span style={{ background: t.isSubscription ? '#e0e7ff' : '#dcfce7', color: t.isSubscription ? '#6366f1' : '#22c55e', borderRadius: 8, padding: '2px 8px', fontSize: 12, marginLeft: 8 }}>{t.isSubscription ? 'Subscription' : 'Income'}</span>
              </li>
            );
          })}
        </ul>
      </section>
      {/* Spending categories */}
      <section style={{ background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px #0001', gridColumn: '1/2' }}>
        <h2>Spending Categories</h2>
        <ul style={{ marginTop: 16, listStyle: 'none', padding: 0 }}>
          {categories.length === 0 && <li style={{ color: '#888' }}>No expenses this month.</li>}
          {categories.map(cat => (
            <li key={cat.category} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
              <span>{cat.category}</span>
              <span style={{ color: '#ef4444', fontWeight: 600 }}>-${cat.amount.toFixed(2)}</span>
            </li>
          ))}
        </ul>
        {/* Bar chart pe categorii */}
        {categories.length > 0 && (
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={categories.slice(0, 6)} layout="vertical" margin={{ left: 20 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis type="number" hide />
              <YAxis dataKey="category" type="category" width={100} />
              <Tooltip />
              <Bar dataKey="amount" fill="#6366f1" radius={[0, 8, 8, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </section>
      {/* Grafic statistic */}
      <section style={{ background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px #0001', gridColumn: '2/3' }}>
        <h2>Statistics</h2>
        <ResponsiveContainer width="100%" height={260}>
          <LineChart data={chartData} margin={{ top: 20, right: 30, left: 0, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="Income" stroke="#22c55e" strokeWidth={3} dot={{ r: 4 }} />
            <Line type="monotone" dataKey="Expenses" stroke="#ef4444" strokeWidth={3} dot={{ r: 4 }} />
          </LineChart>
        </ResponsiveContainer>
      </section>
    </div>
  );
};

export default OverviewDashboard; 