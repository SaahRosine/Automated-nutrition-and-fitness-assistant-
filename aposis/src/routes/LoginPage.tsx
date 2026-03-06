import { createFileRoute } from '@tanstack/react-router'
import { Login } from '../components/Login'

export const Route = createFileRoute('/LoginPage')({
  component: LoginPage,
})

function LoginPage() {
  return (
    <main className="page-wrap px-4 pb-8 pt-14">
      <section className="island-shell rise-in relative overflow-hidden rounded-[2rem] px-6 py-10 sm:px-10 sm:py-14">
        <Login />
      </section>
    </main>
  )
}
