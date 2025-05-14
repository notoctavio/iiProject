import {useState} from "react";
import './Login.css';

const Login = ({ onLoginSuccess }: { onLoginSuccess: () => void }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState('');
    const [showPassword, setShowPassword] = useState(false);

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();

        try {
            const response = await fetch('http://localhost:3000/api/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password }),
            });

            if (response.ok) {
                const data = await response.json();
                setMessage(data.message);
                localStorage.setItem('token', data.token); // Salvează token-ul
                onLoginSuccess(); // Apelează funcția pentru a seta utilizatorul ca logat
            } else {
                const errorData = await response.json();
                setMessage(errorData.message);
            }
        } catch (error) {
            setMessage('An error occurred. Please try again.');
        }
    };

    return (
        <form onSubmit={handleLogin} className="login-form">
            <div className="input-group">
                <label>Email</label>
                <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="john@example.com"
                    required
                />
            </div>
            <div className="input-group">
                <label>Password</label>
                <div className="password-input-container">
                    <input
                        type={showPassword ? "text" : "password"}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="••••••••"
                        required
                    />
                    <button
                        type="button"
                        className="toggle-password"
                        onClick={() => setShowPassword(!showPassword)}
                    >
                        {showPassword ? "Hide" : "Show"}
                    </button>
                </div>
            </div>
            {message && <p className="message">{message}</p>}
            <button type="submit" className="login-btn">
                Sign In
            </button>
        </form>
    );
};
export default Login;