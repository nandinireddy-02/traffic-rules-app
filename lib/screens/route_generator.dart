import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'grade_aware_home_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const GradeAwareHomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for \'${settings.name}\'')),
          ),
        );
    }
  }
}
