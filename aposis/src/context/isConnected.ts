import Cookies from "js-cookie";

export const isConnected = () => {
    const token = Cookies.get("token");
    return !!token; // Returns true if token exists, false otherwise
}