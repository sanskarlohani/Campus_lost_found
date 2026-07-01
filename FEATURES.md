# UniLink - Detailed Feature Documentation 🚀

UniLink is designed to be the ultimate digital companion for a campus environment. This document provides an in-depth explanation of the features, workflows, and logic that power the application.

---

## 🔐 1. Authentication & Verified Profiles
UniLink ensures a safe community by requiring every user to be authenticated and identified.

-   **Seamless Onboarding**: Users can sign up with their university email and password.
-   **Mandatory Profiling**: Upon first login, users are prompted to complete their profile with campus-specific details:
    -   **SIC / Student ID**: For official identification.
    -   **Academic Year & Semester**: Helps finders identify which batch an item might belong to.
    -   **College / Department**: Pinpoints the most frequent locations of the user.
-   **Reactive Session Management**: Uses **GoRouter Refresh Streams** to instantly redirect users based on their login state.

## 📦 2. Lost & Found Management
The core engine of the app allows for real-time reporting and tracking of items.

-   **Dual-Category Reporting**: A unified interface to report both **Lost** items (you're looking for something) and **Found** items (you have something).
-   **Optimized Image Storage**: Users can capture and upload photos of items. Images are automatically compressed (down to 50% quality/800px width) for maximum performance and organized into separate database sections (`lost_images/` and `found_images/`) for high scalability.
-   **Smart Item Cards**: Every item displayed includes:
    -   **Visual Type Badges**: Orange for 'LOST', Green for 'FOUND'.
    -   **Relative Timestamps**: Shows exactly how long ago the item was reported (e.g., "5m ago", "2h ago").
    -   **Location Tagging**: Specific campus spots (e.g., "Library 2nd Floor").
-   **Active Filtering**: Separate tabs for Lost and Found items to keep the marketplace organized.

## 🤝 3. The Handover Workflow (Finder-Owner Loop)
This is the most critical feature, enabling secure interaction between two strangers.

-   **"I Found This" Interaction**: When a user sees a 'Lost' item they have found, they can initiate a claim.
-   **Direct Messaging**: Finders can send a short, secure message (e.g., "I've left your keys at the main gate security") directly to the owner.
-   **Owner Verification**: The owner receives a notification and can verify the finder's details before meeting.
-   **One-Click Resolution**: Once the item is safely returned, the owner marks it as **Resolved**, which:
    -   Removes the item from the public feed.
    -   Updates all pending claims in the database.
    -   Triggers the reward system.

## 🌟 4. Gamified Karma Rewards
To encourage an honest and helpful campus culture, UniLink features a reputation system.

-   **Karma Points**: Users earn **+10 Karma Points** for every item they successfully help return.
-   **Campus Leaderboard**: A live ranking of top contributors on the profile screen. High-karma users are highlighted with Gold, Silver, and Bronze badges to encourage healthy competition.
-   **Live Leaderboard Stats**: Each user's profile displays their "Resolved" count and total "Karma," visible to the community to build trust.
-   **Automatic Rewarding**: The points are awarded automatically by the system the moment an owner confirms they received their item.

## 📢 5. Campus-Wide Alert System
UniLink acts as a digital megaphone for the entire university.

-   **Global Broadcasts**: When a new item is reported, a **Global Notification** is sent to every student currently using the app.
-   **Personal Notifications**: Users get high-priority alerts for:
    -   Successful claims on their items.
    -   Karma points earned.
-   **Smart UI State**: Notifications use different icons (📢 for global, 🤝 for matches) and track read/unread states.
-   **Dark Mode Support**: Full theme customization with a toggle on the profile page, persisted locally via SharedPreferences.

## 📱 6. Technical Cross-Functionality
Built on a cutting-edge technical stack to ensure performance across the board.

-   **Multi-Platform**: A single code project that runs natively on **iOS**, **Android**, and **macOS/Web**.
-   **No-Refresh Sync**: Powered by **Firestore Streams**, the UI updates instantly. If a user in the Canteen posts an item, a student in the Hostel sees it in <100ms.
-   **In-Memory Optimization**: Uses intelligent sorting logic to bypass database index requirements, ensuring the app works perfectly even without manual backend configuration.

---

## 🏗️ Architecture Overview

| Layer | Responsibility |
| :--- | :--- |
| **UI (Flutter)** | Responsive Material 3 components and professional theming. |
| **State (Riverpod)** | Reactive providers that sync Auth, Items, and Stats across screens. |
| **Logic (Services)** | Atomic Firestore operations using Batch writes for data integrity. |
| **Database (Firebase)** | Real-time NoSQL storage with strict security rules. |

---
*Built to make campus life just a little bit easier.* 🎓
