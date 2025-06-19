class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://api.smartcheck.com/v1';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String coursesEndpoint = '/courses';
  static const String attendanceEndpoint = '/attendance';
  static const String faceRecognitionEndpoint = '/face-recognition';
  static const String geofenceEndpoint = '/geofence';
  static const String disputeEndpoint = '/disputes';
  static const String notificationsEndpoint = '/notifications';
  static const String profileEndpoint = '/profile';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  
  // Navigation Routes
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String courseDetailsRoute = '/course-details';
  static const String attendanceRoute = '/attendance';
  static const String faceRecognitionRoute = '/face-recognition';
  static const String geofenceRoute = '/geofence';
  static const String disputeRoute = '/dispute';
  static const String notificationsRoute = '/notifications';
  static const String profileRoute = '/profile';
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String generalErrorMessage = 'Something went wrong. Please try again later.';
  static const String faceRecognitionErrorMessage = 'Face recognition failed. Please try again.';
  static const String geofenceErrorMessage = 'You are not in the required location.';
}
