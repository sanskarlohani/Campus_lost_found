import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/navigation/router_refresh.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:unilink/screens/home_screen.dart';
import 'package:unilink/screens/item_detail_screen.dart';
import 'package:unilink/screens/login_screen.dart';
import 'package:unilink/screens/notifications_screen.dart';
import 'package:unilink/screens/profile_screen.dart';
import 'package:unilink/screens/report_item_screen.dart';
import 'package:unilink/screens/signup_screen.dart';

GoRouter createRouter() => GoRouter(
  // Re-run redirects when auth state changes
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  initialLocation: Routes.login,
  redirect: (BuildContext context, GoRouterState state) {
    final isAuth = FirebaseAuth.instance.currentUser != null;
    final isLoginRoute = state.matchedLocation == Routes.login;
    final isSignupRoute = state.matchedLocation == Routes.signup;

    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuth && !isLoginRoute && !isSignupRoute) {
      return Routes.login;
    }

    // If authenticated and trying to access login/signup, redirect to home
    if (isAuth && (isLoginRoute || isSignupRoute)) {
      return Routes.home;
    }

    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => const SignupScreen(),
    ),

    // Main navigation routes
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Item related routes
    GoRoute(
      path: Routes.report,
      builder: (context, state) => const ReportItemScreen(),
    ),
    GoRoute(
      path: '${Routes.itemDetails}/:id',
      builder: (context, state) => ItemDetailScreen(
        itemId: state.pathParameters['id'] ?? '',
      ),
    ),

    // Tab routes (these should typically be accessed through HomeScreen tabs)
    GoRoute(
      path: Routes.lost,
      redirect: (context, state) => Routes.home,
    ),
    GoRoute(
      path: Routes.found,
      redirect: (context, state) => Routes.home,
    ),
  ],
);