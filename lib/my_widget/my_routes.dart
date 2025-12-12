import 'package:flutter/material.dart';
import 'package:ticket_at/presintaion/main_screen.dart';
import 'package:ticket_at/presintaion/login_screen.dart';
import 'package:ticket_at/presintaion/signup_screen.dart';
import 'package:ticket_at/presintaion/splash_screen.dart';
import '../presintaion/create event/create_event_screen.dart';
import '../presintaion/onboarding_screen.dart';


class AppRoutes {

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String createEvent = '/create_event';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
     login: (context) => const LoginScreen(),
    signup: (context) =>  const SignUpScreen(),
    createEvent: (context) =>  const CreateEventPage(),
    main: (context) =>  const MainScreen(),
  };
}