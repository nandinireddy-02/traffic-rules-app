import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/trafficmate_logo.png',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 32),
            const Text(
              'TrafficMate',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Learn Traffic Rules, Stay Safe!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 48),
            const ElevatedButton(
              onPressed: null, // Replace with actual navigation if needed
              child: Text('Get Started'),
              style: ButtonStyle(
                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 20)),
                backgroundColor: MaterialStatePropertyAll(Colors.green),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
