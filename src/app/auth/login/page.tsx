"use client";
import { signIn } from "next-auth/react";

/**
 * @returns Login page component
 */
export default function SignIn() {
  const handleGoogleSignIn = async () => {
    await signIn("google", { callbackUrl: "/" });
  };

  return (
    <>
      <button onClick={handleGoogleSignIn}>Continue with Google</button>
    </>
  );
}
