import { SignUp } from '#/components/SignUp'
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/SignUpPage')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="w-[90%] md:w-[70%] lg:w-[60%] mx-auto mt-10 flex flex-col items-center">
      <SignUp />
    </div>
  )
}
