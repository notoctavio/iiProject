import type { SVGProps } from 'react';

export const HomeIcon = ({ active = false, ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? '#2563eb' : '#64748b'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <path d="M3 12L12 3l9 9" />
    <path d="M9 21V9h6v12" />
  </svg>
);

export const CardsIcon = ({ active = false, ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? '#2563eb' : '#64748b'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <rect x="2" y="5" width="20" height="14" rx="3" />
    <path d="M2 10h20" />
  </svg>
);

export const TransactionsIcon = ({ active = false, ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? '#2563eb' : '#64748b'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <rect x="3" y="11" width="18" height="7" rx="2" />
    <path d="M16 3h-1a2 2 0 0 0-2 2v6" />
    <path d="M8 3h1a2 2 0 0 1 2 2v6" />
  </svg>
);

export const BucketsIcon = ({ active = false, ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? '#22c55e' : '#64748b'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <rect x="3" y="7" width="18" height="13" rx="2" />
    <path d="M16 3v4" />
    <path d="M8 3v4" />
  </svg>
);

export const SettingsIcon = ({ active = false, ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={active ? '#2563eb' : '#64748b'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <circle cx="12" cy="12" r="3" />
    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
  </svg>
);

export const UserIcon = ({ ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#2563eb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <circle cx="12" cy="8" r="4" />
    <path d="M4 20v-1a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v1" />
  </svg>
);

export const PlusIcon = ({ ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#2563eb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <line x1="12" y1="5" x2="12" y2="19" />
    <line x1="5" y1="12" x2="19" y2="12" />
  </svg>
);

export const CardIcon = ({ ...props }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#2563eb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <rect x="2" y="7" width="20" height="10" rx="2" />
    <path d="M2 10h20" />
    <circle cx="7" cy="15" r="1" />
    <circle cx="17" cy="15" r="1" />
  </svg>
); 