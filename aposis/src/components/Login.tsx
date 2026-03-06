import { useState } from "react";
import { useNavigate } from "@tanstack/react-router";

export function Login() {

const navigate = useNavigate();
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
    fetch(`${import.meta.env.VITE_DJANGO_URL}/api/auth/login/`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
    })
    .then((response) => {
        if (!response.ok) {
            setLoading(false);
            throw new Error("Login failed");
        }
        return response.json();
    })
    .then((data) => {
        console.log("Login successful:", data);
        localStorage.setItem("token", data.token);
        navigate({ to: "/" });
        setLoading(false);
        // Handle successful login, e.g., store token, redirect, etc.
    })
    .catch((error) => {
        console.error("Error during login:", error);
        setError("Invalid email or password");
        setLoading(false);
    })
    .finally(() => {
        setLoading(false);
    });
};

    return (
    <div className="max-w-lg w-full">
    <div
        
        className="bg-gray-800 rounded-lg shadow-xl overflow-hidden"
    >
        <div className="p-8">
        <h2 className="text-center text-3xl font-extrabold text-white">
            Welcome Back
        </h2>
        <p className="mt-4 text-center text-gray-400">Sign in to continue</p>
        <form method="POST" onSubmit={handleSubmit} className="mt-8 space-y-6">
            <div className="rounded-md shadow-sm">
            <div>
                <label className="sr-only" htmlFor="email">Email address</label>
                <input
                placeholder="Email address"
                className="appearance-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                required
                autoComplete="email"
                type="email"
                name="email"
                onChange={handleEmailChange}
                id="email"
                />
            </div>
            <div className="mt-4">
                <label className="sr-only" htmlFor="password">Password</label>
                <input
                placeholder="Password"
                className="appearance-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                required
                autoComplete="current-password"
                type="password"
                name="password"
                onChange={handlePasswordChange}
                id="password"
                />
            </div>
            </div>

            <div className="flex items-center justify-between mt-4">
            <div className="flex items-center">
                <input
                className="h-4 w-4 text-indigo-500 focus:ring-indigo-400 border-gray-600 rounded"
                type="checkbox"
                name="remember-me"
                id="remember-me"
                />
                <label className="ml-2 block text-sm text-gray-400" htmlFor="remember-me"
                >Remember me</label
                >
            </div>

            <div className="text-sm">
                <a
                    className="font-medium text-indigo-500 hover:text-indigo-400"
                    href="#"
                >
                Forgot your password?
                </a>
            </div>
            </div>

            <div>
            <button
                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-gray-900 bg-indigo-500 hover:bg-indigo-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                type="submit"
                disabled={loading}
            >
                Sign In
            </button>
            </div>
        </form>
        </div>
        <div className="px-8 py-4 bg-gray-700 text-center">
        <span className="text-gray-400">Don't have an account?</span>
        <a 
            className="font-medium text-indigo-500 hover:text-indigo-400" href="#"
        >Sign up
        </a>
        </div>
    </div>
    </div>
);
}