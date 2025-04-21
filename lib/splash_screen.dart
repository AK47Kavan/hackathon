import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hackathon/main_page.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomePage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ), // Replace with your actual home page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F9FC), Color(0xFFE1F5FA)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation (can replace with Image.asset if needed)
            Lottie.asset(
              'assets/jsons/Animation.json',
              width: 280,
              height: 230,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 24),

            // App Name
            const Text(
              'RadarVitals',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A7AB0),
              ),
            ),

            const SizedBox(height: 12),

            // Tagline
            const Text(
              'Monitoring health with precision',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5A7D8A),
              ),
            ),

            const SizedBox(height: 24),

            // Decorative Bar
            Container(
              width: 120,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A7AB0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy HomePage for navigation (Replace this with your actual home screen)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Welcome to RadarVitals!")));
  }
}