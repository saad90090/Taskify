import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    // Trigger the animation shortly after the screen loads
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Navigate to the welcome screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => WelcomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 2),
          opacity: _opacity,
          child: AnimatedScale(
            duration: Duration(seconds: 2),
            scale: _scale,
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/images/loho.png',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
