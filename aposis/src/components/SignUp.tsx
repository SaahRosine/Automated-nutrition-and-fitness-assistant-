import { buttonStyles, inputStyles,linkStyles } from "#/styles/style";
import { useNavigate } from "@tanstack/react-router";
import { Suspense, useState,lazy} from "react";

const ErrorPopup = lazy(() => import("./Error").then(module => ({ default: module.ErrorPopup })));

export function SignUp() {
    const navigate = useNavigate();
    const [showError, setShowError] = useState(false);
    const [email, setEmail] = useState("");
    const [name, setName] = useState("");
    const [code, setCode] = useState("");
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
        setCode(e.target.value);
    };
    const handleSubmit = (e: React.SubmitEvent<HTMLFormElement>) => {
        if (password !== confirmPassword) {
            setError("Passwords do not match");
            setShowError(true);
            return;
        }
        e.preventDefault();
        setLoading(true);
        fetch(`${import.meta.env.VITE_DJANGO_URL}/api/auth/register-admin/`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ email, name, password, code }),
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
                className="bg-gray-200 dark:bg-gray-800 rounded-lg shadow-xl overflow-hidden"
            >
                <div className="p-8">
                <h2 className="text-center text-3xl font-extrabold text-bg-gray-900  dark:text-white">
                    Welcome to the Admin Sign Up Page
                </h2>
                <p className="mt-4 text-center text-gray-600 dark:text-gray-400">Sign in to continue</p>
                <form method="POST" onSubmit={handleSubmit} className="mt-8 space-y-6">
                    <div className="rounded-md shadow-sm">
                    <div>
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
                    </div>
                    <div className="mt-4">
                        <label className="sr-only" htmlFor="name">name</label>
                        <input
                        placeholder="name"
                        className={inputStyles}
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
                        className={inputStyles}
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
                        className={inputStyles}
                        required
                        autoComplete="current-password"
                        type="password"
                        name="confirmPassword"
                        onChange={handleConfirmPasswordChange}
                        id="confirmPassword"
                        />
                    </div>
                    <div className="mt-4">
                        <label className="sr-only" htmlFor="code">Verification Code</label>
                        <input
                        placeholder="Verification Code"
                        className={inputStyles}
                        required
                        autoComplete="off"
                        type="text"
                        name="code"
                        onChange={handleCodeChange}
                        id="code"
                        />
                    </div>
                    </div>
        
                    <div className="flex items-center justify-between mt-4">
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
                        className={buttonStyles}
                        type="submit"
                        disabled={loading}
                    >
                        Sign In
                    </button>
                    </div>
                </form>
                </div>
                <div className="px-8 py-4 bg-gray-300 dark:bg-gray-700 text-center">
                <span className="text-gray-800 dark:text-gray-400">Don't have an account?</span>
                <a 
                    className={linkStyles} href="/LoginPage"
                >Sign up
                </a>
                </div>
            </div>
            </div>
    );
}