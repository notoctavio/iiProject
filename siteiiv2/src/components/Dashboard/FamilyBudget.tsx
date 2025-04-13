import React, { useState } from 'react';
import './FamilyBudget.css';

interface FamilyMember {
  id: string;
  name: string;
  role: 'admin' | 'member';
  avatar: string;
}

interface SharedBudget {
  id: string;
  name: string;
  totalAmount: number;
  spent: number;
  category: string;
  members: string[];
  dueDate?: Date;
}

export const FamilyBudget: React.FC = () => {
  const [familyMembers, setFamilyMembers] = useState<FamilyMember[]>([
    { id: '1', name: 'John Doe', role: 'admin', avatar: '👨' },
    { id: '2', name: 'Jane Doe', role: 'member', avatar: '👩' },
    { id: '3', name: 'Mike Doe', role: 'member', avatar: '👦' },
    { id: '4', name: 'Sarah Doe', role: 'member', avatar: '👧' }
  ]);

  const [sharedBudgets, setSharedBudgets] = useState<SharedBudget[]>([
    {
      id: '1',
      name: 'Family Vacation',
      totalAmount: 5000,
      spent: 2500,
      category: 'travel',
      members: ['1', '2', '3', '4']
    },
    {
      id: '2',
      name: 'Monthly Groceries',
      totalAmount: 1000,
      spent: 750,
      category: 'food',
      members: ['1', '2']
    }
  ]);

  return (
    <div className="family-budget">
      <div className="family-header">
        <div className="family-info">
          <h2>Family Budget Management</h2>
          <div className="family-members">
            {familyMembers.map(member => (
              <div key={member.id} className="member-avatar" title={member.name}>
                <span className="avatar">{member.avatar}</span>
                {member.role === 'admin' && <span className="admin-badge">👑</span>}
              </div>
            ))}
            <button className="add-member-btn">+</button>
          </div>
        </div>
        <button className="invite-btn">
          <span>Invite Family Member</span>
          <span className="btn-icon">✉️</span>
        </button>
      </div>

      <div className="shared-budgets">
        <div className="section-header">
          <h3>Shared Budgets</h3>
          <button className="new-budget-btn">Create New Budget</button>
        </div>
        
        <div className="budget-cards">
          {sharedBudgets.map(budget => (
            <div key={budget.id} className="budget-card">
              <div className="budget-header">
                <h4>{budget.name}</h4>
                <div className="members-avatars">
                  {familyMembers
                    .filter(member => budget.members.includes(member.id))
                    .map(member => (
                      <span key={member.id} className="small-avatar" title={member.name}>
                        {member.avatar}
                      </span>
                    ))}
                </div>
              </div>
              
              <div className="budget-progress">
                <div className="progress-bar">
                  <div 
                    className="progress-fill"
                    style={{ width: `${(budget.spent / budget.totalAmount) * 100}%` }}
                  ></div>
                </div>
                <div className="budget-amounts">
                  <span className="spent">${budget.spent}</span>
                  <span className="total">/${budget.totalAmount}</span>
                </div>
              </div>

              <div className="budget-footer">
                <button className="details-btn">View Details</button>
                <button className="contribute-btn">Contribute</button>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="family-activity">
        <h3>Family Activity</h3>
        <div className="activity-timeline">
          <div className="timeline-item">
            <div className="timeline-icon">💰</div>
            <div className="timeline-content">
              <p><strong>Jane Doe</strong> contributed $100 to Family Vacation fund</p>
              <span className="timeline-time">2 hours ago</span>
            </div>
          </div>
          <div className="timeline-item">
            <div className="timeline-icon">🛒</div>
            <div className="timeline-content">
              <p><strong>John Doe</strong> added grocery expenses ($150)</p>
              <span className="timeline-time">Yesterday</span>
            </div>
          </div>
          <div className="timeline-item">
            <div className="timeline-icon">✨</div>
            <div className="timeline-content">
              <p><strong>Mike Doe</strong> created new shared budget "Summer Camp"</p>
              <span className="timeline-time">2 days ago</span>
            </div>
          </div>
        </div>
      </div>

      <div className="savings-goals">
        <h3>Family Savings Goals</h3>
        <div className="goals-grid">
          <div className="goal-card">
            <div className="goal-icon">🏠</div>
            <h4>New House</h4>
            <div className="goal-progress">
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: '45%' }}></div>
              </div>
              <div className="goal-amounts">
                <span className="current">$45,000</span>
                <span className="target">/$100,000</span>
              </div>
            </div>
            <button className="contribute-btn">Contribute</button>
          </div>
          
          <div className="goal-card">
            <div className="goal-icon">🚗</div>
            <h4>Family Car</h4>
            <div className="goal-progress">
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: '75%' }}></div>
              </div>
              <div className="goal-amounts">
                <span className="current">$22,500</span>
                <span className="target">/$30,000</span>
              </div>
            </div>
            <button className="contribute-btn">Contribute</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FamilyBudget; 