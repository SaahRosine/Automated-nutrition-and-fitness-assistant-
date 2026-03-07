import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { isConnected } from '#/context/isConnected'
import Cookies from "js-cookie";
import { lazy,useState } from 'react';
import CriticalButton from '#/components/criticalButton';

const ErrorPopup = lazy(() => import('#/components/Error').then(module => ({ default: module.ErrorPopup })));
export const Route = createFileRoute('/')({ component: App })

function App() {
  const navigate = useNavigate();  // Single useNavigate at top level
  const [showError, setShowError] = useState(false);
  const [error, setError] = useState("");

  const isUserConnected = isConnected();
  
  if (isUserConnected) {
    // Only renew token if user is connected
    fetch("http://localhost:8000/api/auth/renew-token/", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${Cookies.get("token")}`,
      },
      body: JSON.stringify({ refresh: Cookies.get("refreshToken") }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.message === "Token extended successfully") {
          console.log("Token extended, new expiry:", data.new_expiry);
          
          // Parse the new expiry date and update the cookie
          if (data.new_expiry) {
            const newExpiry = new Date(data.new_expiry);
            const now = new Date();
            // Calculate days until expiry
            let daysUntilExpiry = Math.ceil((newExpiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
            
            // Ensure at least 1 day if the token is valid
            if (daysUntilExpiry < 1) {
              daysUntilExpiry = 1;
            }
            
            // Update the token cookie with new expiration
            Cookies.set("token", Cookies.get("token") || "", { expires: daysUntilExpiry });
            console.log("Token cookie updated, new expiry in days:", daysUntilExpiry);
          }
        }
      })

      .catch((error) => {
        setShowError(true);
        setError("Error renewing token");
        console.error("Error renewing token:", error);
        // Optionally redirect on error
        // navigate({ to: "/LoginPage" });
      });
  } else {
    // User not connected - redirect to login
    navigate({ to: "/LoginPage" });
  }

  const handleLogout = () => {
    fetch("http://localhost:8000/api/auth/logout/", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${Cookies.get("token")}`,
      },
      body: JSON.stringify({ refresh: Cookies.get("refreshToken") }),
    })
    .then((response) => {
      if (!response.ok) {
        throw new Error("Logout failed");
      }
      return response.json();
    })
    .then((data) => {
      Cookies.remove("token");
      Cookies.remove("refreshToken");
      console.log("Logout successful:", data);
      navigate({ to: "/LoginPage" });
      // Optionally show a message or perform additional cleanup
    })
    .catch((error) => {
      setShowError(true);
      setError("Error during logout");
      console.error("Error during logout:", error);
      // Optionally show an error message
    })
  };

  return (
    <main className="page-wrap px-4 pb-8 pt-14">
      <CriticalButton onClick={handleLogout}>
        Logout
      </CriticalButton>
      {showError && <ErrorPopup message={error} onClose={() => setShowError(false)} />}
    </main>
  )
}

