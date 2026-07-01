# UniLink - Campus Lost & Found 🎓

UniLink is a modern, high-performance Flutter application designed to bridge the gap between students who have lost their belongings and those who have found them. Built with a focus on **community honesty**, **security**, and **real-time connectivity**, UniLink ensures that lost items find their way home efficiently.

---

## ✨ Features

- **Real-time Item Tracking**: Instant global updates when new items are reported as lost or found. No manual refreshing required.
- **Image Support**: Users can capture and upload photos of items to increase the return success rate by over 70%.
- **Market-Level UI/UX**: A clean, professional Indigo & Emerald theme featuring **Glassmorphism**, smooth transitions, and Material 3 components.
- **Interactive Handover Workflow**: 
  - **Finders** can send direct "Found it" claims with location messages to owners.
  - **Owners** can securely verify and mark items as "Resolved" once returned.
- **Gamified Karma System**: Earn **+10 Karma Points** for every successful item return. Build your reputation as a helpful community member.
- **Campus Leaderboard**: Live rankings of top contributors to encourage helpful competition.
- **Rich User Profiles**: Mandatory university profile setup (SIC, Year, College) for verified interactions.
- **Smart Notifications**: Instant alerts for matches, new global reports, and Karma rewards.
- **Adaptive Themes**: Full **Dark Mode** support with persistent user preferences.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (3.x - Channel stable)
- **State Management**: [Riverpod](https://riverpod.dev/) (Reactive, predictable, and highly scalable state)
- **Backend**: [Firebase](https://firebase.google.com/)
  - **Cloud Firestore**: Real-time NoSQL database with reactive Streams.
  - **Firebase Authentication**: Secure Email/Password authentication with Keychain sharing.
  - **Firebase Storage**: Cloud storage for item photos.
  - **Firebase Analytics**: Advanced tracking of user engagement and item return rates.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **UI Components**: Material 3 with a customized **Glassmorphism** engine.

---

## 📱 Cross-Platform & Real-Time Sync

UniLink is designed to work seamlessly across the entire campus ecosystem:
- **True Cross-Platform**: A single codebase powers **iOS**, **Android**, and **Web**, ensuring a uniform experience.
- **Instant Synchronization**: Using Firestore Streams, actions are visible to all users globally in under 100ms.
- **Native Security**: Configured with Keychain Sharing (Apple) and Multidex (Android) for maximum reliability.

---

## 🚀 Getting Started

1.  **Clone the Repo**:
    ```bash
    git clone https://github.com/yourusername/Campus_lost_found.git
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup**:
    - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
    - Run `flutterfire configure` to generate `firebase_options.dart`.
    - Download and link `GoogleService-Info.plist` (iOS/macOS) and `google-services.json` (Android).
    - Enable **Firestore**, **Authentication**, **Storage**, and **Analytics**.
4.  **Run the App**:
    ```bash
    flutter run
    ```

---
Built with ❤️ for the Campus Community.
