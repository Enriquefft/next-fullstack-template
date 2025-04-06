import { ArrowRightIcon, AtSignIcon, KeyRoundIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { inter } from "@/styles/fonts";

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
			<div className="flex-1 rounded-lg bg-gray-50 px-6 pt-8 pb-4">
				<h1 className={`${inter.className} mb-3 text-2xl text-black`}>
					Please log in to continue.
				</h1>
				<div className="w-full">
					<div>
						<label
							className="mt-5 mb-3 block font-medium text-gray-900 text-xs"
							htmlFor="email"
						>
							Email
						</label>
						<div className="relative">
							<input
								className="peer block w-full rounded-md border border-gray-200 py-[9px] pl-10 text-gray-500 text-sm outline-2 placeholder:text-gray-500"
								id="email"
								type="email"
								name="email"
								placeholder="Enter your email address"
								required={true}
							/>
							<AtSignIcon className="-translate-y-1/2 pointer-events-none absolute top-1/2 left-3 size-[18px] text-gray-500 peer-focus:text-gray-900" />
						</div>
					</div>
					<div className="mt-4">
						<label
							className="mt-5 mb-3 block font-medium text-gray-900 text-xs"
							htmlFor="password"
						>
							Password
						</label>
						<div className="relative">
							<input
								className="peer block w-full rounded-md border border-gray-200 py-[9px] pl-10 text-gray-500 text-sm outline-2 placeholder:text-gray-500"
								id="password"
								type="password"
								name="password"
								placeholder="Enter password"
								required={true}
								minLength={6}
							/>
							<KeyRoundIcon className="-translate-y-1/2 pointer-events-none absolute top-1/2 left-3 size-[18px] text-gray-500 peer-focus:text-gray-900" />
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
