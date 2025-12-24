# User Login Flows

**Related PRD Files**:
- Data Models: `02-data-models.md` → User, Session tables
- API Design: `03-api-design.md` → `signIn()`, `signOut()` actions
- UI Components: `04-ui-components.md` → SignInForm component, /login page

**Contents**:
1. [Email/Password Login - Happy Path](#flow-1-emailpassword-login-happy-path)
2. [Email/Password Login - Invalid Credentials](#flow-2-emailpassword-login-error-invalid-credentials)
3. [Email/Password Login - Unverified Email](#flow-3-emailpassword-login-error-unverified-email)
4. [Google OAuth Login - Happy Path](#flow-4-google-oauth-login-happy-path)
5. [Logout - Happy Path](#flow-5-logout-happy-path)

---

## Flow 1: Email/Password Login (Happy Path)

**User Goal**: As a registered user, I want to log in with my email and password so that I can access my account

**Preconditions**:
- User has previously registered an account
- User's email is verified
- User is not currently authenticated
- User has correct email and password

**Steps**:
1. User navigates to `/login`
2. System displays login form with email and password fields
3. User enters registered email address
4. User enters correct password
5. User clicks "Sign In" button
6. System validates input format
7. System looks up user by email in database
8. System compares provided password with hashed password using bcrypt
9. System verifies passwords match
10. System checks `emailVerified` is true
11. System creates new session for user
12. System sets session cookie (httpOnly, secure)
13. User redirected to `/dashboard` or intended destination
14. User sees success message "Welcome back!"

**Expected DB State**:
- Session table: New session created with:
  - `sessionToken`: Generated token
  - `userId`: User's ID
  - `expires`: 30 days from now
- User table: `lastLoginAt` updated to current timestamp (if field exists)

**UI State**:
- User redirected to dashboard or `?redirect` parameter destination
- Success toast: "Welcome back!"
- User now authenticated (can access protected routes)
- Session cookie set with 30-day expiration

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "user can log in with email and password"

---

## Flow 2: Email/Password Login (Error: Invalid Credentials)

**User Goal**: Same as Flow 1

**Preconditions**:
- User is not authenticated
- User enters incorrect email or password

**Steps**:
1. User navigates to `/login`
2. System displays login form
3. User enters email address
4. User enters incorrect password (or non-existent email)
5. User clicks "Sign In" button
6. System validates input format
7. System looks up user by email
8. System either:
   - Finds user but password doesn't match, OR
   - Doesn't find user with that email
9. System returns generic error (for security, don't reveal which)
10. User sees error message "Invalid email or password"
11. User remains on `/login` page
12. Password field is cleared

**Expected DB State**:
- No changes to database
- No session created
- Optional: Failed login attempt counter incremented (for rate limiting)

**UI State**:
- Error message displayed: "Invalid email or password"
- Email field retains value
- Password field cleared
- Focus returned to password field
- "Forgot password?" link highlighted

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "shows error for invalid credentials"

---

## Flow 3: Email/Password Login (Error: Unverified Email)

**User Goal**: Same as Flow 1

**Preconditions**:
- User has registered but not verified email
- User has correct email and password
- User's `emailVerified` is false

**Steps**:
1. User navigates to `/login`
2. System displays login form
3. User enters registered email address
4. User enters correct password
5. User clicks "Sign In" button
6. System validates credentials (password matches)
7. System checks `emailVerified` field
8. System detects email is not verified
9. User redirected to `/verify-email`
10. User sees message "Please verify your email address before logging in"
11. System displays "Resend verification email" button

**Expected DB State**:
- No session created (login blocked)
- User record unchanged

**UI State**:
- User redirected to `/verify-email`
- Warning message: "Please verify your email address before logging in"
- "Resend verification email" button shown
- Helpful text: "Check your inbox for the verification link"

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "redirects to verify-email for unverified users"

---

## Flow 4: Google OAuth Login (Happy Path)

**User Goal**: As a user, I want to log in with my Google account so that I don't have to remember another password

**Preconditions**:
- User has Google account
- User is not currently authenticated
- Google OAuth is configured in `src/auth.ts`

**Steps**:
1. User navigates to `/login`
2. System displays "Continue with Google" button
3. User clicks "Continue with Google"
4. System redirects to Google OAuth consent screen
5. Google displays permission request for email and profile
6. User grants permissions
7. Google redirects back to `/api/auth/callback/google` with auth code
8. System exchanges auth code for Google access token
9. System fetches user's Google profile (email, name, image)
10. System checks if user with this Google email exists:
    - **If exists**: Looks up existing user by email
    - **If new**: Creates new user record
11. System creates/updates account record (provider: "google")
12. System creates session for user
13. System sets session cookie
14. User redirected to `/dashboard`
15. User sees "Welcome!" or "Welcome back!" message

**Expected DB State**:
- User table:
  - If new: New record with email, name, image from Google
  - If existing: `image` updated if different
  - `emailVerified`: true (Google accounts are trusted)
- Account table: Record with:
  - `provider`: "google"
  - `providerAccountId`: Google user ID
  - `userId`: Links to user record
- Session table: New session created

**UI State**:
- User redirected to dashboard
- Success toast displayed
- User authenticated with session
- Profile picture from Google displayed

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "user can log in with Google OAuth"

---

## Flow 5: Logout (Happy Path)

**User Goal**: As an authenticated user, I want to log out so that I can end my session securely

**Preconditions**:
- User is authenticated with active session
- User is on any protected page

**Steps**:
1. User clicks "Logout" button in navigation/menu
2. System receives logout request with session token
3. System looks up session by token
4. System deletes session from database
5. System clears session cookie
6. User redirected to `/` (home page) or `/login`
7. User sees message "Logged out successfully"

**Expected DB State**:
- Session table: User's session deleted
- User record: No changes (user account remains)

**UI State**:
- User redirected to home page or login
- Success message: "Logged out successfully"
- Session cookie cleared from browser
- User no longer has access to protected routes
- Navigation updates to show "Log in" instead of user menu

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "user can log out"

---

## Additional Flows (Future)

Potential flows to add based on requirements:

- **Flow 6**: Password Reset Request
- **Flow 7**: Password Reset with Token
- **Flow 8**: Remember Me (Extended Session)
- **Flow 9**: Session Expiry and Auto-Logout
- **Flow 10**: Multi-device Session Management

## Notes

- Login rate limiting: Max 5 failed attempts per IP per 15 minutes
- Session tokens should be cryptographically random (use `crypto.randomBytes`)
- Sessions should be httpOnly, secure, sameSite cookies
- Consider implementing "Remember me" option for extended sessions (e.g., 90 days)
- Google OAuth requires `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` environment variables
- Failed login attempts should use constant-time comparison to prevent timing attacks
- Consider adding 2FA (Two-Factor Authentication) for enhanced security
