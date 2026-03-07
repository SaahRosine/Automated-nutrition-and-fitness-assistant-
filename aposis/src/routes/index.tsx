import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { isConnected } from '#/context/isConnected'
import Cookies from "js-cookie";

export const Route = createFileRoute('/')({ component: App })

function App() {
  const navigate = useNavigate();  // Single useNavigate at top level

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
        if (data.token) {
          Cookies.set("token", data.token);
        }
        // If no new token, keep existing session
      })
      .catch((error) => {
        console.error("Error renewing token:", error);
        // Optionally redirect on error
        // navigate({ to: "/LoginPage" });
      });
  } else {
    // User not connected - redirect to login
    navigate({ to: "/LoginPage" });
  }

  return (
    <main className="page-wrap px-4 pb-8 pt-14">
      Hello
    </main>
  )
}
