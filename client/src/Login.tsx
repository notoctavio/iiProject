import { useState } from "react";

const Login = ({ onLoginSuccess }: { onLoginSuccess: () => void }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState('');

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();

        try {
            const response = await fetch('http://localhost:3000/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                    Email: email, 
                    Password: password 
                }),
            });

            if (response.ok) {
                const data = await response.json();
                setMessage('Login successful');
                if (data.user) {
                    // Salvăm datele utilizatorului în localStorage
                    localStorage.setItem('user', JSON.stringify(data.user));
                }
                onLoginSuccess();
            } else {
                const errorData = await response.json();
                setMessage(errorData.error || 'Login failed');
            }
        } catch (error) {
            setMessage('An error occurred. Please try again.');
            console.error('Login error:', error);
        }
    };

    return (
        <form onSubmit={handleLogin}>
            <div className="input-group">
                <label>Email:</label>
                <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    placeholder="your@email.com"
                />
            </div>
            <div className="input-group">
                <label>Password:</label>
                <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    placeholder="••••••••"
                />
            </div>
            <button type="submit" className="login-btn">Login</button>
            {message && <p className={message.includes('successful') ? 'success-message' : 'error-message'}>{message}</p>}
        </form>
    );
};

export default Login;