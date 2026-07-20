# UniLink - Detailed Feature Documentation 🚀

UniLink is designed to be the ultimate digital companion for a campus environment. This document provides an in-depth explanation of the features, workflows, and logic that power the application.

---

## 🔐 1. Authentication & Verified Profiles
UniLink ensures a safe community by requiring every user to be authenticated and identified.

-   **Animated Splash Screen**: A premium entry experience with scaling and opacity animations that smoothly transition based on the user's authentication state.
-   **Dual-Identity System**: Students can choose how they appear to the community:
    -   **Custom Photo Upload**: Capture and upload a real profile picture.
    -   **Premium Avatar Library**: Select from a curated list of high-quality SVG avatars (DiceBear) for privacy.
-   **Mandatory Profiling**: Upon first login, users must complete their profile with SIC, Year, and College details.
-   **High-End Logout Experience**: A dedicated glassmorphism-based logout action at the bottom of the profile screen, featuring a dual-confirmation glassy dialog to prevent accidental sign-outs.
-   **Reactive Session Management**: Uses **GoRouter Refresh Streams** to instantly redirect users based on their login state.

## 📦 2. Lost & Found Management
The core engine of the app allows for real-time reporting and tracking of items.

-   **Dual-Category Reporting**: A unified interface to report both **Lost** items (you're looking for something) and **Found** items (you have something).
-   **Optimized Image Storage**: Users can capture and upload photos of items. Images are automatically compressed (down to 50% quality/800px width) for maximum performance and organized into separate database sections (`lost_images/` and `found_images/`).
-   **Smart Item Cards**: Displays visual type badges, relative timestamps, and specific location tagging.

## 🤝 3. The Handover Workflow (Finder-Owner Loop)
This is the most critical feature, enabling secure interaction between two strangers.

-   **"I Found This" Interaction**: When a user sees a 'Lost' item they have found, they can initiate a claim.
-   **Direct Messaging**: Finders can send a short, secure message (e.g., "I've left your keys at the main gate security") directly to the owner.
-   **One-Click Resolution**: Once the item is safely returned, the owner marks it as **Resolved**, which removes the item from the public feed and triggers rewards.

## 🌟 4. Gamified Karma Rewards
To encourage an honest and helpful campus culture, UniLink features a reputation system.

-   **Karma Points**: Users earn **+10 Karma Points** for every item they successfully help return.
-   **Campus Leaderboard**: A live ranking of top contributors. High-karma users are highlighted with Gold, Silver, and Bronze badges to encourage healthy competition.
-   **Automatic Rewarding**: The points are awarded automatically by the system the moment an owner confirms they received their item.

## 📢 5. Campus-Wide Alert System
UniLink acts as a digital megaphone for the entire university.

-   **Global Broadcasts**: When a new item is reported, a **Global Notification** is sent to every student currently using the app.
-   **Smart UI State**: Notifications use specialized icons (📢 for global, 🤝 for matches) and track read/unread states.
-   **Dark Mode Support**: Full theme customization with a toggle on the profile page, persisted locally.

## 📱 6. Technical Cross-Functionality
Built on a cutting-edge technical stack to ensure performance across the board.

-   **Multi-Platform Deployment**: A single codebase powering native **iOS**, **Android**, **macOS**, and a **Live Web App** hosted on **Vercel** with optimized GoRouter rewrites.
-   **No-Refresh Sync**: Powered by **Firestore Streams**, the UI updates instantly (<100ms lag).
-   **In-Memory Optimization**: Uses intelligent sorting logic to bypass database index requirements during high-velocity development.

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
