# UniLink - Campus Lost & Found 🎓

UniLink is a modern, high-performance Flutter application designed to bridge the gap between students who have lost their belongings and those who have found them. Built with a focus on **community honesty**, **security**, and **real-time connectivity**, UniLink ensures that lost items find their way home efficiently.

---

## ✨ Features

- **Real-time Item Tracking**: Instant global updates when new items are reported as lost or found. No manual refreshing required.
- **Market-Level UI/UX**: A clean, professional Indigo & Emerald theme featuring smooth transitions, Material 3 components, and a mobile-first responsive design.
- **Interactive Handover Workflow**: 
  - **Finders** can send direct "Found it" claims with location messages to owners.
  - **Owners** can securely verify and mark items as "Resolved" once returned.
- **Gamified Karma System**: Earn **+10 Karma Points** for every successful item return. Build a reputation as a helpful community member.
- **Rich User Profiles**: Mandatory university profile setup (SIC, Year, College) to ensure all interactions happen between verified campus members.
- **Smart Notifications**: Instant alerts for matches, new claims, and Karma rewards.
- **Detailed Item Views**: Collapsible headers, time-ago timestamps, and integrated reporter information.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (3.x - Channel stable)
- **State Management**: [Riverpod](https://riverpod.dev/) (Reactive, predictable, and highly scalable state)
- **Backend**: [Firebase](https://firebase.google.com/)
  - **Cloud Firestore**: Real-time NoSQL database with reactive Streams.
  - **Firebase Authentication**: Secure Email/Password authentication.
  - **Firebase Storage**: Hosting for item images.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing with deep-link support)
- **UI Components**: Material 3 with a customized professional theme.

---

## 📱 Cross-Platform & Real-Time Sync

UniLink is designed to work seamlessly across the entire campus ecosystem:
- **True Cross-Platform**: A single codebase powers **iOS**, **Android**, and **Web**, ensuring a uniform experience regardless of the device.
- **Instant Synchronization**: Using Firestore Streams, actions performed by one user (like reporting a found item) are visible to all other users globally in under 100ms.
- **Native Permissions**: Configured with internet and network client permissions for robust performance on Android and macOS/Web environments.

---

## 📈 System Logic

### The "Finder-Owner" Loop
1. **Report**: An owner posts a "Lost" item.
2. **Claim**: A finder sees the item, clicks "I Found This," and sends a meeting location message.
3. **Notify**: The owner receives a "Match" alert instantly.
4. **Resolve**: Upon meeting, the owner marks the item as "Resolved."
5. **Reward**: The system automatically updates the claim status and awards the finder **Karma Points**.

### Safety First
We recommend all item exchanges happen in designated **Campus Safety Zones** such as the Library Reception, Main Canteen, or Campus Security Office.

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
    - Enable **Firestore**, **Authentication**, and **Storage**.
    - Deploy the provided `firestore.rules` for basic security.
4.  **Run the App**:
    ```bash
    flutter run
    ```

---
Built with ❤️ for the Campus Community.
