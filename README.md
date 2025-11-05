# UniLink - Lost and Found App

UniLink is a Flutter application designed to help university students manage and track lost and found items within their campus community. The app provides a platform for students to report lost items, post found items, and facilitate the return of lost belongings.

## Features

### Authentication
- User registration and login with email/password
- Profile management with student details
- Secure authentication using Firebase Auth

### Lost & Found Management
- Report lost items with details and images
- Post found items to help locate owners
- Real-time updates using Firebase Firestore
- Tab-based navigation between lost and found items
- Pull-to-refresh for latest updates

### Profile Management
- View and edit personal information
- Student details including:
  - Student ID (SIC)
  - Year of study
  - Semester
  - College information

### Navigation
- Bottom navigation bar for easy access to:
  - Home (Lost & Found items)
  - Notifications (Coming soon)
  - Profile

## Technical Stack

- **Frontend**: Flutter
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Storage (for images)
- **Theme**: Material Design with custom theme support

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase account
- Android Studio/VS Code

### Setup

1. Clone the repository:
```bash
git clone [repository-url]
cd unilink
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
- Create a new Firebase project
- Add Android/iOS apps in Firebase console
- Download and add configuration files
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user.dart
│   └── lost_found_item.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   └── ...
├── providers/
│   ├── auth_provider.dart
│   └── lost_found_provider.dart
├── navigation/
│   └── app_router.dart
└── theme/
    └── app_theme.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who participate in this project
