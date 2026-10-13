# KaamHub --- Antigravity Implementation Guide

## 1. Purpose and Instructions for the Coding Agent

Build **KaamHub**, a local-services marketplace mobile application. The
app connects customers with verified service workers such as plumbers,
electricians, masons, car washers, and mechanics.

Use this document as the project brief and implementation plan. Work
incrementally, inspect the existing repository before changing files,
and preserve working code. Do not generate the entire application in one
unreviewed step.

### Required working method

1.  Inspect the repository and report the existing framework, folder
    structure, and current implementation.
2.  If a Flutter project already exists, reuse it. Do not recreate or
    overwrite it without a clear reason.
3.  Before each major stage, state the files you plan to create or
    modify and why.
4.  Implement one stage at a time, then run formatting, static analysis,
    and available tests.
5.  Fix errors introduced by the current stage before proceeding.
6.  Do not claim a feature works unless it has been implemented and
    checked.
7.  Use clear, beginner-friendly comments only where they explain
    non-obvious logic.
8.  Keep secrets, API keys, service-account files, and private
    credentials out of source control.
9.  If a required Firebase project, API key, or external credential is
    missing, build the safe integration structure and clearly tell the
    developer what manual setup is required. Never fabricate
    credentials.
10. Ask for clarification only when a decision blocks implementation.
    Otherwise use the defaults specified below and document assumptions.

## 2. Product Overview

**Product name:** KaamHub\
**Product type:** Local services marketplace\
**Primary goal:** Help customers find, compare, and book verified local
workers, while helping workers receive more job requests.

### User roles

-   **Customer:** searches services, views worker profiles, requests
    bookings, communicates about a job, and leaves a review after
    completion.
-   **Worker:** creates a profile, submits verification documents, sets
    service areas and rates, and accepts or rejects booking requests.
-   **Admin:** reviews worker applications, manages
    users/services/bookings, and handles complaints and suspicious
    reviews.

Role-based access must be enforced in the backend/security rules, not
only by hiding UI controls.

## 3. MVP Scope --- Build These First

Launch the first version in one city with these five service
categories: 1. Plumber --- tap repair, geyser, water tank, drainage. 2.
Electrician --- wiring, switches, fans, lights, UPS/inverter. 3.
Mistri/Mason --- tiles, plaster, small repairs. 4. Car washer --- home
wash, interior cleaning. 5. Mechanic --- oil change, battery, small
repairs.

### Customer features

-   Phone-number sign-in with OTP using Firebase Authentication.
-   Browse the five service categories and their subcategories.
-   View a list of workers and filter by service, area, rating, price,
    and availability where data exists.
-   View worker profile: name, service, experience, service area, rates,
    verification status, work photos, and reviews.
-   Submit booking request with service, subcategory, date/time,
    address/area, and job description.
-   View booking status: pending, accepted, on the way, completed, or
    rejected/cancelled as appropriate.
-   View booking history and book the same worker again.
-   Leave a rating/review only after a booking is completed.
-   Submit a complaint/report linked to a booking.
-   Basic in-app chat only if it can be implemented safely within the
    available Firebase setup. Do not expose private phone numbers in
    public worker listings.

### Worker features

-   Register and create a profile with name, service category,
    experience, area, and rates.
-   Upload CNIC/identity verification document, reference information,
    and past-work photos.
-   New worker profiles remain **pending** until an admin approves them.
-   Approved workers can accept or reject booking requests.
-   Workers can update availability and rates.
-   Workers can view booking history, ratings, and a basic
    earnings/booking record. Do not implement real wallet transfers in
    the MVP.

### Admin features

-   Protected admin access.
-   View pending worker applications and submitted documents.
-   Approve or reject worker profiles and record the decision.
-   Manage customers, workers, bookings, service categories, and
    subcategories.
-   Review complaints and flag suspicious reviews.
-   Basic dashboard counts: total bookings, pending applications,
    active/approved workers, and top-rated workers where sufficient data
    exists.

### Explicitly defer to later phases

Do not build these unless the project owner asks: -
JazzCash/Easypaisa/card payments and automated commission collection. -
Worker wallet deductions or payouts. - Warranty workflows. - Live GPS
tracking. - WhatsApp Business API booking. - Multi-city expansion. -
Premium listings/subscriptions. - Complex analytics or microservices.

## 4. Suggested Technology

-   **Mobile application:** Flutter with Dart.
-   **Authentication:** Firebase Authentication (phone OTP where
    configured).
-   **Database:** Cloud Firestore.
-   **Document and work-photo storage:** Firebase Storage.
-   **Push notifications:** Firebase Cloud Messaging, later phase unless
    needed for the MVP.
-   **Admin panel:** Prefer a role-protected Flutter Web panel if the
    existing project is Flutter-only; otherwise discuss before
    introducing a second frontend.
-   **Maps:** Google Maps API only when location/map requirements are
    confirmed and API access is configured.

Use stable, mutually compatible package versions. Check the existing
`pubspec.yaml` before adding or upgrading dependencies.

## 5. Architecture and Code Quality

Keep the project organized and maintainable. Adapt to the existing
repository rather than forcing a new structure. A reasonable structure
is:

``` text
lib/
  main.dart
  app/
    app.dart
    routes.dart
    theme.dart
  core/
    constants/
    errors/
    utils/
    widgets/
  models/
  services/
    auth_service.dart
    worker_service.dart
    booking_service.dart
    review_service.dart
    storage_service.dart
  features/
    auth/
    customer/
    worker/
    admin/
    bookings/
    reviews/
    complaints/
```

Guidelines: - Keep UI widgets separate from Firebase/database logic. -
Use typed models and explicit serialization/deserialization. - Use
reusable buttons, text fields, loading indicators, empty states, and
error states. - Validate all user inputs and show understandable error
messages. - Handle loading, success, empty, offline/error, and
permission-denied states. - Use named constants instead of scattering
duplicate strings. - Avoid giant single-file implementations. - Do not
add packages without explaining why they are needed. - Run
`dart format .` and `flutter analyze` after meaningful changes. - Add
unit/widget tests for core logic when practical.

## 6. Data Model Proposal

Confirm and document the exact fields before implementing database
writes. Suggested Firestore collections:

### `users/{userId}`

-   `uid`
-   `name`
-   `phoneNumber`
-   `role` (`customer`, `worker`, or `admin`)
-   `createdAt`
-   `isActive`

Never let a user promote their own role to `admin`. Admin privileges
must be assigned through a trusted, controlled process.

### `workers/{workerId}`

-   `userId`
-   `displayName`
-   `serviceCategoryIds`
-   `subCategoryIds`
-   `experienceYears`
-   `serviceAreas`
-   `rateDescription` or structured rate fields
-   `availability`
-   `verificationStatus` (`pending`, `approved`, `rejected`)
-   `verificationDocumentPaths`
-   `workPhotoPaths`
-   `averageRating`
-   `reviewCount`
-   `createdAt`
-   `updatedAt`

Do not expose identity-document paths or sensitive identity information
to ordinary customers. Keep verification documents private and restrict
access.

### `services/{serviceId}`

-   `name`
-   `description`
-   `subCategories`
-   `isActive`
-   `sortOrder`

### `bookings/{bookingId}`

-   `customerId`
-   `workerId`
-   `serviceId`
-   `subCategoryId`
-   `requestedDateTime`
-   `serviceAddress` or area details
-   `jobDescription`
-   `status`
-   `createdAt`
-   `updatedAt`
-   `completedAt` (when completed)

Use a controlled status transition. For example, a worker may accept or
reject a pending booking; only authorized participants/admins can update
relevant fields. Do not allow clients to arbitrarily set a booking to
completed.

### `reviews/{reviewId}`

-   `bookingId`
-   `customerId`
-   `workerId`
-   `rating` (validate within the chosen rating scale)
-   `comment`
-   `createdAt`
-   `moderationStatus` if needed

Enforce one review per eligible completed booking. Validate eligibility
in trusted logic/security rules as far as the selected architecture
allows.

### `complaints/{complaintId}`

-   `bookingId`
-   `reportedBy`
-   `againstUserId`
-   `reason`
-   `description`
-   `status` (`open`, `inReview`, `resolved`, `rejected`)
-   `createdAt`
-   `updatedAt`

These are proposed schemas, not a claim that they already exist. Adapt
them to the actual codebase and document any changes.

## 7. Security, Privacy, and Trust Requirements

Security is a core product requirement because workers may enter
customers' homes.

-   Configure Firebase Authentication and Firestore/Storage security
    rules before using real users.
-   Apply least-privilege access: customers access their own records and
    relevant bookings; workers access their own profiles and assigned
    booking information; admins have separately controlled permissions.
-   Never rely on client-side role checks alone.
-   Worker verification documents must be private and accessible only to
    the worker who uploaded them and authorized admins.
-   Validate booking participants and allowed status transitions.
-   Prevent unauthorized profile edits, fake review creation, role
    escalation, and access to other users' private data.
-   Only allow reviews for completed bookings associated with the
    reviewing customer.
-   Do not store OTPs, passwords, or secrets in Firestore.
-   Avoid logging phone numbers, CNIC data, document URLs, or other
    sensitive information.
-   Use generic sample data during development. Do not commit real
    CNICs, phone numbers, or customer addresses.
-   Before launch, test rules using Firebase Emulator Suite or another
    suitable rules-testing process.

If a security rule cannot safely enforce a business rule by itself,
explain the limitation and propose a trusted backend/Cloud Function for
a later or required implementation. Do not label the app
production-ready until security has been reviewed.

## 8. Screen List and Navigation

### Shared

-   Splash/loading screen.
-   Sign-in/OTP screen.
-   Role-aware navigation after authentication.
-   Profile/account screen.
-   Reusable loading, error, empty, and confirmation UI.

### Customer

-   Home screen with service categories.
-   Subcategory selection.
-   Worker search/results with filters.
-   Worker profile/details.
-   Create booking form.
-   Booking confirmation/details.
-   My bookings/history with status.
-   Booking chat (only if included in the MVP implementation).
-   Leave review.
-   Create/view complaint.

### Worker

-   Worker onboarding/profile form.
-   Upload verification documents and work photos.
-   Verification status screen: pending/approved/rejected.
-   Worker dashboard.
-   Incoming booking requests.
-   Booking details and accept/reject actions.
-   Availability/rates settings.
-   Reviews and booking/earnings summary.

### Admin

-   Admin sign-in/access guard.
-   Dashboard.
-   Pending worker verification list/details.
-   Approve/reject workflow with reason.
-   User/worker list.
-   Booking management.
-   Service/subcategory management.
-   Complaints and suspicious-review management.

Keep navigation simple and consistent. Do not show worker-only screens
to customers or admin screens to ordinary users.

## 9. UI/UX Requirements

-   Clean, modern, responsive design suitable for Android phones first.
-   Use consistent spacing, typography, colors, and reusable components.
-   Keep forms short and labels clear.
-   Design for users with limited technical experience.
-   Support Urdu/English in a later phase; keep user-facing text
    centralized so localization can be added without rewriting every
    screen.
-   Clearly display worker verification status without implying that the
    platform guarantees perfect safety.
-   Never display fake ratings, reviews, worker counts, or availability.
    Use labeled sample data only in development.
-   Add confirmation for destructive or consequential actions.
-   Show friendly messages for denied permissions, failed uploads,
    network errors, and empty search results.

## 10. Implementation Procedure --- Follow in Order

### Stage 0: Repository audit

-   Inspect all project files and current Git status if available.
-   Identify Flutter/Dart versions, dependencies, current screens, and
    existing Firebase setup.
-   Report what already works and what is missing.
-   Do not overwrite existing work.

**Checkpoint:** A concise audit report and agreed implementation plan.

### Stage 1: App foundation

-   Verify the Flutter app launches.
-   Establish theme, routes/navigation, shared widgets, and folder
    organization.
-   Add a simple placeholder screen for each role only if useful for
    validating navigation.
-   Run formatting and static analysis.

**Checkpoint:** App launches without errors and navigation structure is
clear.

### Stage 2: Authentication and roles

-   Configure Firebase only with valid project configuration.
-   Implement sign-in/OTP flow and auth-state handling.
-   Create/read the user profile safely.
-   Add role-aware navigation and admin access guard.
-   Explain any console setup needed from the project owner.

**Checkpoint:** Sign-in states and role routing are tested; users cannot
self-assign admin privileges.

### Stage 3: Services and worker discovery

-   Load the five MVP categories and subcategories from a controlled
    source.
-   Build category selection, worker listing, filtering, and worker
    profile.
-   Display only approved/active worker profiles to customers.
-   Add loading, empty, and error states.

**Checkpoint:** A customer can browse categories and view eligible
worker profiles.

### Stage 4: Worker onboarding and admin verification

-   Build worker profile creation and document/photo upload.
-   Set new profiles to pending by default.
-   Implement the admin review screen and approve/reject actions.
-   Secure document storage and access rules.

**Checkpoint:** Unapproved workers are not publicly discoverable; admin
decisions are recorded.

### Stage 5: Booking workflow

-   Build booking request form and customer booking history.
-   Implement worker accept/reject actions and allowed status
    transitions.
-   Add booking details and participant-specific access.
-   Test invalid transitions and unauthorized access.

**Checkpoint:** A customer can request a booking and the assigned worker
can respond securely.

### Stage 6: Reviews and complaints

-   Allow reviews only after eligible completed bookings.
-   Prevent duplicate reviews for the same booking.
-   Build complaint submission and admin review.
-   Add basic moderation controls.

**Checkpoint:** Reviews and complaints are linked to real app records
and access-controlled.

### Stage 7: Admin dashboard and polish

-   Add basic counts and management lists based on actual data.
-   Improve form validation, responsive layouts, accessibility, and
    error messages.
-   Add tests for important models, validation, and booking state logic.

**Checkpoint:** Main MVP workflows are usable and errors are handled.

### Stage 8: Security and release readiness

-   Review Firestore and Storage rules.
-   Run `dart format .`, `flutter analyze`, and available tests.
-   Test customer, worker, and admin flows with separate test accounts.
-   Check upload permissions, role escalation, booking privacy, review
    eligibility, and empty/offline states.
-   Document setup, environment configuration, known limitations, and
    release steps.

**Checkpoint:** Provide a truthful report of passed/failed checks and
unresolved risks. Do not claim production readiness if security or
required configuration is incomplete.

## 11. Acceptance Criteria for the MVP

The MVP is not complete until all applicable criteria are met:

-   [ ] App builds and launches in the configured development
    environment.
-   [ ] Customer, worker, and admin access paths are separated.
-   [ ] Phone OTP authentication works with valid Firebase
    configuration.
-   [ ] Only approved workers appear in customer search.
-   [ ] Customer can view worker details and submit a booking request.
-   [ ] Worker can accept/reject an assigned pending booking.
-   [ ] Unauthorized users cannot read or modify another user's private
    records.
-   [ ] Worker identity documents are not publicly accessible.
-   [ ] Reviews are restricted to eligible completed bookings.
-   [ ] Complaints can be submitted and reviewed by authorized admins.
-   [ ] Loading, empty, validation, and error states exist for major
    flows.
-   [ ] Formatting, static analysis, and available tests have been run;
    results are reported.
-   [ ] Setup instructions and known limitations are documented.

## 12. Final Deliverables

At the end of each stage, report: 1. What was implemented. 2. Files
created or changed. 3. Commands/checks run and their actual results. 4.
Manual Firebase/API configuration still required. 5. Known bugs,
security concerns, and incomplete features. 6. The exact next step.

At final handoff, include: - Updated Flutter source code. - Setup/run
instructions. - Firebase configuration and security-rule guidance
without exposing secrets. - Test results. - Known limitations and
deferred features.

## 13. Start Here --- First Prompt to Antigravity

Read this guide and inspect the current repository before writing code.
First perform **Stage 0: Repository audit** only. Report the existing
project structure, Flutter/Dart versions if available, current app entry
point, dependencies, Firebase status, current working features, and
blockers. Do not make destructive changes and do not start implementing
later stages until the audit is complete. After the audit, propose a
short, ordered plan for Stage 1 and wait for approval if any major
architectural choice would be difficult to reverse.
