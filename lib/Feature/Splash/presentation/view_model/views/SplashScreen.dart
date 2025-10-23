import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Splash/presentation/view_model/views/widgets/SplashContent.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashContent(),
    );
  }
}