# Project Overview

**Last Updated**: [Date]

## Project Vision

**Problem Statement**: [What problem does this project solve?]

**Target Users**: [Who is the primary audience?]

**Value Proposition**: [Why should users care? What makes this unique?]

## Success Metrics

Define measurable goals for v1:

- [ ] **User Acquisition**: [Target number of users, signups, etc.]
- [ ] **Engagement**: [DAU/MAU, session length, feature usage, etc.]
- [ ] **Business**: [Revenue, conversion rate, retention, etc.]
- [ ] **Technical**: [Performance benchmarks, uptime, etc.]

## Out of Scope (v1)

Features intentionally excluded from initial release:

- [Feature 1]
- [Feature 2]
- [Feature 3]

## Technical Stack

This template uses:

- **Framework**: Next.js 15 (App Router)
- **Database**: PostgreSQL (Neon) with Drizzle ORM
- **Authentication**: Better Auth
- **Payments**: Polar (configurable)
- **Styling**: Tailwind CSS v4 + shadcn/ui
- **Forms**: TanStack Form with Zod validation
- **Testing**: Happy DOM (unit) + Playwright (E2E)
- **Analytics**: PostHog (optional)

## Implementation Phases

### Phase 1: MVP

**Goal**: [Minimum viable product objectives]

**Features**:
- [Feature 1]
- [Feature 2]
- [Feature 3]

**Timeline**: [If applicable]

### Phase 2: Enhancement

**Goal**: [Post-MVP enhancements]

**Features**:
- [Feature 1]
- [Feature 2]

### Phase 3: Polish

**Goal**: [Refinements and optimizations]

**Features**:
- [Feature 1]
- [Feature 2]

## Template Customization Notes

**For Claude Code**: When running `/implement-prd`, generate TodoWrite tasks based on these requirements.

### Authentication

**Using**: [Select one or multiple]
- [ ] Email/password
- [ ] Google OAuth
- [ ] GitHub OAuth
- [ ] Magic links
- [ ] Other: [Specify]

**Session Strategy**: [Database sessions / JWT]

**Email Verification**: [Required / Optional / Not needed]

**Notes**: [Any auth-specific requirements or constraints]

### Payments

**Payment Provider**: [Polar / Stripe / None]

**Subscription Tiers**: [Yes / No]

**Checkout Flows**: [One-time / Recurring / Both]

**Notes**: [Payment-specific requirements]

### Analytics

**Analytics Provider**: [PostHog / Google Analytics / Mixpanel / None]

**Custom Events to Track**:
- [Event 1]
- [Event 2]
- [Event 3]

**Notes**: [Analytics-specific requirements]

### Messaging

**Messaging Provider**: [Kapso (WhatsApp) / Twilio / None]

**Features Needed**:
- [ ] Send text messages
- [ ] Send template messages
- [ ] Interactive buttons/lists
- [ ] Webhook handling for incoming messages
- [ ] Other: [Specify]

**Notes**: [Messaging-specific requirements]

### Features to Remove from Template

Check items that should be removed:

- [ ] Example `post` schema (if not building blog/CMS)
- [ ] Example home page content
- [ ] PostHog integration (if not using analytics)
- [ ] Polar integration (if not using payments)
- [ ] Google OAuth (if not needed)
- [ ] GitHub OAuth (if not needed)
- [ ] WhatsApp/Kapso integration (if not using messaging)
- [ ] ProductCard component (if not e-commerce)
- [ ] Other: [Specify]

### Additional Dependencies Needed

List packages not in template that need to be installed:

- [Package name] - [Purpose]
- [Package name] - [Purpose]

### Brand Guidelines

**Colors**: [Primary, secondary, accent colors if specified]

**Fonts**: [Font families if different from template]

**Dark Mode**: [Required / Optional / Not needed]

**Notes**: [Reference to brand guidelines doc if exists]

## Notes

[Any additional context, constraints, or important information for implementation]
