import { useState } from "react";

const CriticalButton = ({ onClick, children }: { onClick: () => void; children: React.ReactNode }) => {
    const [showConfirmation, setShowConfirmation] = useState(false);

        const handleClick = () => {
        setShowConfirmation(true);
        };
    
        const handleConfirm = () => {
        setShowConfirmation(false);
        onClick();
        };
    
        const handleCancel = () => {
        setShowConfirmation(false);
        };
    
        return (
        <>
            <button
            onClick={handleClick}
            className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors duration-300 dark:bg-red-700 dark:hover:bg-red-600"
            >
            {children}
            </button>
            {showConfirmation && (
            <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
                <div className="bg-white p-6 rounded shadow-lg dark:bg-gray-800">
                <p className="mb-4">Are you sure you want to proceed?</p>
                <div className="flex justify-end space-x-4">
                    <button
                    onClick={handleCancel}
                    className="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400 transition-colors duration-300 dark:bg-gray-600 dark:text-gray-300 dark:hover:bg-gray-500">
                    Cancel
                    </button>
                    <button
                    onClick={handleConfirm}
                    className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors duration-300 dark:bg-red-700 dark:hover:bg-red-600"
                    >
                    Confirm
                    </button>
                </div>
                </div>
            </div>
            )}
        </>
        );
    };
    
    export default CriticalButton;