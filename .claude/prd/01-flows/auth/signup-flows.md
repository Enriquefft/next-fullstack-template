# User Signup Flows

**Related PRD Files**:
- Data Models: `02-data-models.md` → User, Session, Verification tables
- API Design: `03-api-design.md` → `signUp()`, `verifyEmail()` actions
- UI Components: `04-ui-components.md` → SignUpForm component, /signup page

**Contents**:
1. [Email/Password Signup - Happy Path](#flow-1-emailpassword-signup-happy-path)
2. [Email/Password Signup - Email Already Exists](#flow-2-emailpassword-signup-error-email-already-exists)
3. [Email/Password Signup - Invalid Email](#flow-3-emailpassword-signup-error-invalid-email)
4. [Email/Password Signup - Weak Password](#flow-4-emailpassword-signup-error-weak-password)
5. [Email Verification - Success](#flow-5-email-verification-success)
6. [Email Verification - Expired Token](#flow-6-email-verification-error-expired-token)

---

## Flow 1: Email/Password Signup (Happy Path)

**User Goal**: As a new user, I want to create an account with email and password so that I can access the platform

**Preconditions**:
- User is not authenticated
- Email address is not already registered
- User has valid email address and strong password

**Steps**:
1. User navigates to `/signup`
2. System displays signup form with email and password fields
3. User enters valid email address (e.g., `user@example.com`)
4. User enters strong password (min 8 characters, with uppercase, lowercase, number)
5. User clicks "Sign Up" button
6. System validates input (email format, password strength)
7. System hashes password using bcrypt
8. System creates user record in database with `emailVerified: false`
9. System creates session for user
10. System generates email verification token
11. System sends verification email to user's address
12. User redirected to `/verify-email` page
13. User sees message "Check your email to verify your account"

**Expected DB State**:
- User table: New record created with fields:
  - `id`: Generated UUID
  - `email`: User's email address
  - `name`: null (can be set later in profile)
  - `emailVerified`: false
  - `image`: null
  - `createdAt`: Current timestamp
- Session table: New session created with:
  - `sessionToken`: Generated token
  - `userId`: Links to new user
  - `expires`: 30 days from now
- Verification table: Token record created with:
  - `identifier`: User's email
  - `token`: Generated verification token
  - `expires`: 24 hours from now

**UI State**:
- User redirected to `/verify-email`
- Page shows verification pending message
- Email sent indicator displayed
- Session cookie set in browser

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "user can sign up with email and password"

---

## Flow 2: Email/Password Signup (Error: Email Already Exists)

**User Goal**: Same as Flow 1

**Preconditions**:
- User is not authenticated
- Email address is already registered in database

**Steps**:
1. User navigates to `/signup`
2. System displays signup form
3. User enters email that already exists in database
4. User enters valid password
5. User clicks "Sign Up" button
6. System validates input
7. System checks if email exists in database
8. System detects duplicate email
9. User sees error message "This email is already registered"
10. User remains on `/signup` page
11. Form fields retain values (except password cleared for security)

**Expected DB State**:
- No changes to database
- No new user created
- No session created

**UI State**:
- Error message displayed below email field: "This email is already registered"
- Email field keeps its value
- Password field cleared
- "Sign Up" button remains enabled
- Suggestion shown: "Try logging in instead" with link to `/login`

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "shows error when email already exists"

---

## Flow 3: Email/Password Signup (Error: Invalid Email)

**User Goal**: Same as Flow 1

**Preconditions**:
- User is not authenticated
- User enters invalid email format

**Steps**:
1. User navigates to `/signup`
2. System displays signup form
3. User enters invalid email (e.g., `notanemail`, `user@`, `@example.com`)
4. User enters valid password
5. User clicks "Sign Up" button
6. System validates input with Zod schema
7. System detects invalid email format
8. User sees error message "Please enter a valid email address"
9. User remains on `/signup` page

**Expected DB State**:
- No changes to database

**UI State**:
- Error message displayed below email field: "Please enter a valid email address"
- Email field highlighted with error styling (red border)
- Focus returned to email field
- Password field value retained

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "shows error for invalid email format"

---

## Flow 4: Email/Password Signup (Error: Weak Password)

**User Goal**: Same as Flow 1

**Preconditions**:
- User is not authenticated
- User enters password that doesn't meet strength requirements

**Steps**:
1. User navigates to `/signup`
2. System displays signup form with password requirements hint
3. User enters valid email
4. User enters weak password (e.g., `abc123`, `password`)
5. User clicks "Sign Up" button
6. System validates password against requirements:
   - Minimum 8 characters
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number
7. System detects weak password
8. User sees error message "Password must be at least 8 characters with uppercase, lowercase, and numbers"
9. User remains on `/signup` page

**Expected DB State**:
- No changes to database

**UI State**:
- Error message displayed below password field with specific requirements
- Password field highlighted with error styling
- Password strength indicator shows "weak"
- Helpful hint displayed with requirements checklist

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "shows error for weak password"

---

## Flow 5: Email Verification (Success)

**User Goal**: As a user who just signed up, I want to verify my email address so that I can access all platform features

**Preconditions**:
- User has signed up and received verification email
- Verification token is valid and not expired
- User is on `/verify-email` page or clicks link from email

**Steps**:
1. User checks email inbox
2. User receives email with subject "Verify your email address"
3. User clicks verification link (e.g., `/verify-email?token=abc123xyz`)
4. System receives request with token parameter
5. System validates token exists in database
6. System checks token has not expired (within 24 hours)
7. System finds user by token identifier (email)
8. System updates user record: `emailVerified: true`
9. System deletes verification token from database
10. User redirected to `/dashboard` or `/` (home)
11. User sees success message "Email verified successfully!"

**Expected DB State**:
- User table: `emailVerified` updated to `true`
- Verification table: Token record deleted
- Session remains active

**UI State**:
- User redirected to dashboard
- Success toast displayed: "Email verified successfully!"
- User can now access all authenticated features
- Email verification banner (if any) removed

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "user can verify email with valid token"

---

## Flow 6: Email Verification (Error: Expired Token)

**User Goal**: Same as Flow 5

**Preconditions**:
- User has signed up more than 24 hours ago
- Verification token has expired
- User clicks verification link from old email

**Steps**:
1. User clicks verification link with expired token
2. System receives request with token parameter
3. System looks up token in database
4. System checks token expiration date
5. System detects token is expired
6. User redirected to `/verify-email` with error state
7. User sees error message "Verification link expired"
8. System displays "Resend verification email" button

**Expected DB State**:
- No changes to user record
- Expired token may be deleted from database

**UI State**:
- Error message displayed: "This verification link has expired"
- "Resend verification email" button shown
- User can click to request new verification email
- Help text: "Verification links expire after 24 hours"

**E2E Test Mapping**: `e2e/tests/auth.spec.ts` → "shows error for expired verification token"

---

## Additional Flows (Future)

Potential flows to add based on requirements:

- **Flow 7**: Social OAuth Signup (Google) - Happy Path
- **Flow 8**: Resend Verification Email
- **Flow 9**: Signup with Invite Code
- **Flow 10**: Account Already Verified Edge Case

## Notes

- Password hashing must use bcrypt with minimum 10 salt rounds
- Email verification tokens should be cryptographically secure (use `crypto.randomBytes`)
- Session tokens should be httpOnly cookies for security
- Rate limiting should prevent signup spam (e.g., max 5 attempts per IP per hour)
- Consider implementing CAPTCHA for production to prevent bot signups
