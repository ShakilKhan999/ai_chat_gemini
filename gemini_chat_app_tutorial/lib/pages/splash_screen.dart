// lib/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => HomePage());
    });

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            color: Color(0xFFFFFFFF),
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Your Personal \nAI Chat Bot',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
