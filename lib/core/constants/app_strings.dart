/// Centralized user-facing strings for the KaamHub application.
/// Ensures maintainability and simplifies future localization into Urdu.
class AppStrings {
  AppStrings._();

  // App Identity
  static const String appName = 'KaamHub';
  static const String appTagline = 'Verified Local Service Experts';
  static const String appSubtitle =
      'Connect with trusted plumbers, electricians, masons & more.';

  // Roles
  static const String roleCustomer = 'Customer';
  static const String roleWorker = 'Service Worker';
  static const String roleAdmin = 'Administrator';

  // Role Selection
  static const String welcomeTitle = 'Welcome to KaamHub';
  static const String selectRolePrompt = 'Choose your role to get started:';
  static const String customerRoleDescription =
      'Find, compare, and book verified local service workers.';
  static const String workerRoleDescription =
      'Receive job requests, manage bookings, and grow your work.';
  static const String adminRoleDescription =
      'Manage applications, inspect worker verifications, and supervise bookings.';

  // Five MVP Service Categories
  static const String catPlumber = 'Plumber';
  static const String catPlumberDesc =
      'Tap repair, geyser, water tank, drainage';

  static const String catElectrician = 'Electrician';
  static const String catElectricianDesc =
      'Wiring, switches, fans, lights, UPS/inverter';

  static const String catMistri = 'Mistri / Mason';
  static const String catMistriDesc = 'Tiles, plaster, small masonry repairs';

  static const String catCarWasher = 'Car Washer';
  static const String catCarWasherDesc =
      'Home wash, interior & exterior cleaning';

  static const String catMechanic = 'Mechanic';
  static const String catMechanicDesc =
      'Oil change, battery, troubleshooting & repairs';

  // Common UI Actions
  static const String continueText = 'Continue';
  static const String cancel = 'Cancel';
  static const String retry = 'Try Again';
  static const String search = 'Search services or workers...';
  static const String viewDetails = 'View Details';
  static const String bookNow = 'Book Service';
  static const String apply = 'Apply';
  static const String refresh = 'Refresh';

  // Status Strings
  static const String statusPending = 'Pending Review';
  static const String statusApproved = 'Verified & Approved';
  static const String statusRejected = 'Rejected';
  static const String statusAccepted = 'Accepted';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  // Common Feedback
  static const String loading = 'Loading, please wait...';
  static const String noDataFound = 'No records found';
  static const String genericError = 'Something went wrong. Please try again.';
}
