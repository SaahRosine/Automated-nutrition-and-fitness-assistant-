import { createFileRoute } from '@tanstack/react-router'
import { Login } from '../components/Login'

export const Route = createFileRoute('/LoginPage')({
    component: LoginPage,
})

function LoginPage() {
    return (
        <div className="w-[90%] md:w-[70%] lg:w-[60%] mx-auto mt-10 flex flex-col items-center">
            <Login />
        </div>
    )
}
