import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../my_widget/my_colors.dart';
import '../my_widget/my_routes.dart';

class OnboardingStep {
  final String imagePath;
  final String title;

  OnboardingStep({required this.imagePath, required this.title});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      imagePath: "assets/onboarding/Onboarding 1.svg",
      title: "Buy Ticket with\nEase",
    ),
    OnboardingStep(
      imagePath: "assets/onboarding/Onboarding 2.svg",
      title: "Quick & Easy\nCheck-In",
    ),
    OnboardingStep(
      imagePath: "assets/onboarding/Onboarding 3.svg",
      title: "Discover Events\nTailored for you",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyColors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/onboarding/Background.svg",
              fit: BoxFit.fill,
              width: screenSize.width,
              height: screenSize.height,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset("assets/Logo.svg", height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _finishOnboarding,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: MyColors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _steps.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SvgPicture.asset(
                                _steps[index].imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Divider(thickness: 2, color: MyColors.black),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _steps[index].title,
                                  style: TextStyle(
                                    color: MyColors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _steps.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            height: 8,
                            width: _currentIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? MyColors.black
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == _steps.length - 1) {
                            _finishOnboarding();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _currentIndex == _steps.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            color: MyColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
