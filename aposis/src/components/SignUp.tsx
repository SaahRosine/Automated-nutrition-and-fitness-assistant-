import { useNavigate } from "@tanstack/react-router";
import { Suspense, useState,lazy} from "react";

const ErrorPopup = lazy(() => import("./Error").then(module => ({ default: module.ErrorPopup })));

export function SignUp() {
    const navigate = useNavigate();
    const [showError, setShowError] = useState(false);
    const [email, setEmail] = useState("");
    const [name, setName] = useState("");
    const [admin_code, setAdmin_Code] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    const handleEmailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setEmail(e.target.value);
    };
    const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setName(e.target.value);
    };
    const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setPassword(e.target.value);
    };
    const handleConfirmPasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setConfirmPassword(e.target.value);
    };
    const handleCodeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setAdmin_Code(e.target.value);
    };
    const handleSubmit = (e: React.SubmitEvent<HTMLFormElement>) => {
        if (password !== confirmPassword) {
            setError("Passwords do not match");
            setShowError(true);
            return;
        }
        e.preventDefault();
        setLoading(true);
        fetch(`${import.meta.env.VITE_DJANGO_URL}/api/auth/register/`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ email, name, password, admin_code: admin_code }),
        })
        .then((response) => {
            if (!response.ok) {
                setShowError(true);
                setLoading(false);
                throw new Error("Registration failed");
            }
            return response.json();
        })
        .then((data) => {
            console.log("Registration successful:", data);
            navigate({ to: "/LoginPage" });
            setLoading(false);
        })
        .catch((error) => {
            console.error("Error during registration:", error);
            setError("Registration failed. Please try again.");
            setShowError(true);
            setLoading(false);
        })
        .finally(() => {
            setLoading(false);
        });
    }
    return (
            <div className="max-w-lg w-full">
                <Suspense fallback={null}>
                    {showError && <ErrorPopup message={error} onClose={() => setShowError(false)} />}
                </Suspense>
        
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
                        <label className="sr-only" htmlFor="name">name</label>
                        <input
                        placeholder="name"
                        className="appearance-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                        required
                        autoComplete="current-password"
                        type="name"
                        name="name"
                        onChange={handleNameChange}
                        id="name"
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
                    <div className="mt-4">
                        <label className="sr-only" htmlFor="confirmPassword">Confirm Password</label>
                        <input
                        placeholder="Confirm Password"
                        className="appearance-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                        required
                        autoComplete="current-password"
                        type="password"
                        name="confirmPassword"
                        onChange={handleConfirmPasswordChange}
                        id="confirmPassword"
                        />
                    </div>
                    <div className="mt-4">
                        <label className="sr-only" htmlFor="admin_code">Verification Code</label>
                        <input
                        placeholder="Verification Code"
                        className="appearance-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-white rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                        required
                        autoComplete="off"
                        type="text"
                        name="admin_code"
                        onChange={handleCodeChange}
                        id="admin_code"
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
                            href="/forgot-password"
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
                    className="font-medium text-indigo-500 hover:text-indigo-400" href="/SignUpPage"
                >Sign up
                </a>
                </div>
            </div>
            </div>
    );
}