import { Button } from "@/components/ui/button";
import { inter } from "@/styles/fonts";
import { ArrowRightIcon, AtSignIcon, KeyRoundIcon } from "lucide-react";

/**
 * @returns Login form button component
 */
function LoginButton() {
	return (
		<Button className="mt-4 w-full">
			Log in <ArrowRightIcon className="ml-auto size-5 text-gray-50" />
		</Button>
	);
}

/**
 * @returns Login form component
 */
export default function LoginForm() {
	return (
		<form className="space-y-3">
			<div className="flex-1 rounded-lg bg-gray-50 px-6 pb-4 pt-8">
				<h1 className={`${inter.className} mb-3 text-2xl text-black`}>
					Please log in to continue.
				</h1>
				<div className="w-full">
					<div>
						<label
							className="mb-3 mt-5 block text-xs font-medium text-gray-900"
							htmlFor="email"
						>
							Email
						</label>
						<div className="relative">
							<input
								className="peer block w-full rounded-md border border-gray-200 py-[9px] pl-10 text-sm text-gray-500 outline-2 placeholder:text-gray-500"
								id="email"
								type="email"
								name="email"
								placeholder="Enter your email address"
								required
							/>
							<AtSignIcon className="pointer-events-none absolute left-3 top-1/2 size-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
						</div>
					</div>
					<div className="mt-4">
						<label
							className="mb-3 mt-5 block text-xs font-medium text-gray-900"
							htmlFor="password"
						>
							Password
						</label>
						<div className="relative">
							<input
								className="peer block w-full rounded-md border border-gray-200 py-[9px] pl-10 text-sm text-gray-500 outline-2 placeholder:text-gray-500"
								id="password"
								type="password"
								name="password"
								placeholder="Enter password"
								required
								minLength={6}
							/>
							<KeyRoundIcon className="pointer-events-none absolute left-3 top-1/2 size-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900" />
						</div>
					</div>
				</div>
				<LoginButton />
				<div className="flex h-8 items-end space-x-1">
					{/* Add form errors here */}
				</div>
			</div>
		</form>
	);
}
