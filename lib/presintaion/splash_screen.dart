import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../my_widget/my_colors.dart';
import '../my_widget/my_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<SplashStep> _steps = [
    SplashStep(
      titleColor: MyColors.primary,
      backgroundColor: MyColors.white,
      assetPath: 'assets/splash_logo/splash_logo_1.svg',
    ),
    SplashStep(
      titleColor: MyColors.primary,
      backgroundColor: MyColors.secondary,
      assetPath: 'assets/splash_logo/splash_logo_2.svg',
    ),
    SplashStep(
      titleColor: MyColors.white,
      backgroundColor: MyColors.black,
      assetPath: 'assets/splash_logo/splash_logo_3.svg',
    ),
    SplashStep(
      titleColor: MyColors.primary,
      backgroundColor: MyColors.black,
      assetPath: 'assets/splash_logo/splash_logo_4.svg',
    ),
    SplashStep(
      titleColor: MyColors.black,
      backgroundColor: MyColors.primary,
      assetPath: 'assets/splash_logo/splash_logo_5.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_currentIndex < _steps.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        timer.cancel();
        _navigateToOnboarding();
      }
    });
  }

  void _navigateToOnboarding() {
    final user = Supabase.instance.client.auth.currentUser;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
        return;
      }else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        color: _steps[_currentIndex].backgroundColor,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  _steps[_currentIndex].assetPath,
                  key: ValueKey<String>(_steps[_currentIndex].assetPath),
                  width: 100,
                ),
                const SizedBox(width: 20),
                Text(
                  "Ticket At",
                  style: TextStyle(
                    color: _steps[_currentIndex].titleColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashStep {
  final Color backgroundColor;
  final String assetPath;
  final Color titleColor;

  SplashStep({
    required this.backgroundColor,
    required this.assetPath,
    required this.titleColor,
  });
}
