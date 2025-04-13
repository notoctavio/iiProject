import React from 'react';
import './About.css';

const About: React.FC = () => {
  const teamMembers = [
    {
      id: 1,
      name: 'Sarah Johnson',
      role: 'Founder & CEO',
      bio: 'Former financial advisor with 10+ years of experience in personal finance and technology.',
      image: 'https://randomuser.me/api/portraits/women/44.jpg'
    },
    {
      id: 2,
      name: 'Michael Chen',
      role: 'CTO',
      bio: 'Tech innovator with a background in AI and machine learning, focused on creating intelligent financial solutions.',
      image: 'https://randomuser.me/api/portraits/men/32.jpg'
    },
    {
      id: 3,
      name: 'Emily Rodriguez',
      role: 'Head of Design',
      bio: 'Award-winning UX designer passionate about creating intuitive and beautiful financial experiences.',
      image: 'https://randomuser.me/api/portraits/women/68.jpg'
    },
    {
      id: 4,
      name: 'David Kim',
      role: 'Head of Customer Success',
      bio: 'Dedicated to ensuring every user gets the most value from Budgetly with personalized support.',
      image: 'https://randomuser.me/api/portraits/men/75.jpg'
    }
  ];

  const values = [
    {
      id: 1,
      title: 'Transparency',
      description: 'We believe in complete transparency in both our product and our business practices.',
      icon: '🔍'
    },
    {
      id: 2,
      title: 'Empowerment',
      description: 'Our goal is to empower individuals and families with the knowledge and tools they need to make better financial decisions.',
      icon: '💪'
    },
    {
      id: 3,
      title: 'Innovation',
      description: 'We continuously innovate to bring you the most advanced financial management tools available.',
      icon: '💡'
    },
    {
      id: 4,
      title: 'Community',
      description: "We're building a community of financially savvy individuals who support and learn from each other.",
      icon: '🤝'
    }
  ];

  return (
    <div className="about-container">
      <div className="about-header">
        <h1>Our Story</h1>
        <p>Building a better financial future for everyone</p>
      </div>
      
      <div className="about-story">
        <div className="story-content">
          <h2>The Budgetly Journey</h2>
          <p>
            Budgetly was founded in 2020 with a simple mission: to make personal finance management accessible, intuitive, and effective for everyone. Our founder, Sarah Johnson, had spent years as a financial advisor and noticed that many of her clients struggled with the same challenges - tracking expenses, sticking to budgets, and planning for the future.
          </p>
          <p>
            She realized that existing financial apps were either too complex, too basic, or too focused on investing rather than everyday financial management. There was a clear gap in the market for a solution that combined powerful financial tools with an intuitive, user-friendly interface.
          </p>
          <p>
            Today, Budgetly has grown into a comprehensive financial management platform used by thousands of individuals and families worldwide. We continue to innovate and expand our features based on user feedback and the latest advancements in financial technology.
          </p>
        </div>
        <div className="story-image">
          <div className="image-container">
            <img src="https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80" alt="Budgetly office" />
          </div>
        </div>
      </div>
      
      <div className="about-values">
        <h2>Our Values</h2>
        <div className="values-grid">
          {values.map(value => (
            <div key={value.id} className="value-card">
              <div className="value-icon">{value.icon}</div>
              <h3>{value.title}</h3>
              <p>{value.description}</p>
            </div>
          ))}
        </div>
      </div>
      
      <div className="about-team">
        <h2>Meet Our Team</h2>
        <p className="team-intro">We're a diverse group of financial experts, technologists, and designers passionate about helping you achieve your financial goals.</p>
        
        <div className="team-grid">
          {teamMembers.map(member => (
            <div key={member.id} className="team-card">
              <div className="member-image">
                <img src={member.image} alt={member.name} />
              </div>
              <h3>{member.name}</h3>
              <p className="member-role">{member.role}</p>
              <p className="member-bio">{member.bio}</p>
            </div>
          ))}
        </div>
      </div>
      
      <div className="about-mission">
        <div className="mission-content">
          <h2>Our Mission</h2>
          <p>
            At Budgetly, our mission is to empower individuals and families with the tools and knowledge they need to take control of their financial future. We believe that everyone deserves access to powerful financial management tools, regardless of their financial literacy or background.
          </p>
          <p>
            By combining cutting-edge technology with intuitive design, we're making it easier than ever to track expenses, create budgets, set financial goals, and make informed financial decisions.
          </p>
          <p>
            We're not just building a product - we're building a movement towards better financial health and literacy for everyone.
          </p>
        </div>
      </div>
      
      <div className="about-cta">
        <h2>Join Us on Our Mission</h2>
        <p>Experience the difference that intelligent financial management can make in your life</p>
        <button className="cta-button">Get Started Free</button>
      </div>
    </div>
  );
};

export default About; 