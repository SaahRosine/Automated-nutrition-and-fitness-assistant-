const Button=({ children, onClick }: { children: React.ReactNode; onClick: () => void }) => {
    return (
        <button
        onClick={onClick}
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors duration-300 dark:bg-gray-700 dark:hover:bg-gray-600"
        >
        {children}
        </button>
    );
};

export default Button;