import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/status_bar.dart';

void main() => runApp(const BecuPrototypeApp());

class BecuPrototypeApp extends StatelessWidget {
  const BecuPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BECU Prototype',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: deviceFrameBuilder,
      home: const WelcomeScreen(),
    );
  }
}
