import { useState,lazy, Suspense} from "react";
import { useNavigate } from "@tanstack/react-router";
import Cookies from "js-cookie";
import { buttonStyles, inputStyles, linkStyles } from "#/styles/style";

const ErrorPopup = lazy(() => import("./Error").then(module => ({ default: module.ErrorPopup })));

export function Login() {

const navigate = useNavigate();
const [showError, setShowError] = useState(false);
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
const [error, setError] = useState("");
const [loading, setLoading] = useState(false);

const handleEmailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEmail(e.target.value);
};

const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value);
};

const handleSubmit = (e: React.SubmitEvent<HTMLFormElement>) => {
    e.preventDefault();
    // Handle login logic here, e.g., send a request to the backend
    console.log("Email:", email);
    console.log("Password:", password);
    setLoading(true);
    fetch(`${import.meta.env.VITE_DJANGO_URL}/api/auth/login-admin/`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
    })
    .then((response) => {
        if (!response.ok) {
            setShowError(true);
            setLoading(false);
            throw new Error("Login failed");
        }
        return response.json();
    })
    .then((data) => {
        console.log("Login successful:", data);
        const token = data.token;
        sessionStorage.setItem("Checked", "true");
        Cookies.set("token", token, { expires: 7 }); // Store token in cookies for 7 days
        
        navigate({ to: "/" });
        setLoading(false);
        // Handle successful login, e.g., store token, redirect, etc.
    })
    .catch((error) => {
        console.error("Error during login:", error);
        setError("Invalid email or password");
        setShowError(true);
        setLoading(false);
    })
    .finally(() => {
        setLoading(false);
    });
};

    return (
    <div className="max-w-lg w-full">
        <Suspense fallback={null}>
            {showError && <ErrorPopup message={error} onClose={() => setShowError(false)} />}
        </Suspense>

    <div
        className="bg-gray-200 dark:bg-gray-800 rounded-lg shadow-xl overflow-hidden"
    >
        <div className="p-8">
        <h2 className="text-center text-3xl font-extrabold text-gray-900 dark:text-white">
            Welcome Back
        </h2>
        <p className="mt-4 text-center text-gray-400">Sign in to continue</p>
        <form method="POST" onSubmit={handleSubmit} className="mt-8 space-y-6">
                <label className="sr-only" htmlFor="email">Email address</label>
                <input
                placeholder="Email address"
                className={inputStyles}
                required
                autoComplete="email"
                type="email"
                name="email"
                onChange={handleEmailChange}
                id="email"
                />
                <label className="sr-only" htmlFor="password">Password</label>
                <input
                placeholder="Password"
                className={inputStyles}
                required
                autoComplete="current-password"
                type="password"
                name="password"
                onChange={handlePasswordChange}
                id="password"
                />
                <a
                    className={linkStyles}
                    href="/forgot-password"
                >
                Forgot your password?
                </a>

            <button
                className={buttonStyles}
                type="submit"
                disabled={loading}
            >
                Sign In
            </button>
        </form>
        </div>
        <div className="px-8 py-4 bg-gray-300 dark:bg-gray-700 text-center">
        <span className="text-gray-600 dark:text-gray-400">Don't have an account?</span>
        <a 
            className={linkStyles}
            href="/SignUpPage"
        >
            Sign up
        </a>
        </div>
    </div>
    </div>
);
}