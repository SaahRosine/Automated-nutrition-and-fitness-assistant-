import { useEffect, useState } from "react";

interface ErrorPopupProps {
    message: string;
    onClose: () => void;
}

export function ErrorPopup({ message, onClose }: Readonly<ErrorPopupProps>) {
    const [visible, setVisible] = useState(true);

    useEffect(() => {
        const timer = setTimeout(() => {
        setVisible(false);
        onClose();
        }, 5000);
        return () => clearTimeout(timer);
    }, [onClose]);

    if (!visible) return null;

    return (
        <div className="fixed top-4 right-4 bg-red-600 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-pulse">
        <p>{message}</p>
        </div>
    );
}
