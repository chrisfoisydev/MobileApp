import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import 'account_summary_screen.dart';

/// 1.0 CIAM sign in: the login.becu.org web sheet with username/password,
/// recovery links and footer, framed by a slim faux browser bar.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;

  void _signIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AccountSummaryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _BrowserBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: BecuLogo(height: 40),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Member Sign In',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 40 / 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _FieldLabel('Username'),
                          const SizedBox(height: 8),
                          TextField(decoration: _fieldDecoration()),
                          const SizedBox(height: 24),
                          const _FieldLabel('Password'),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: _obscurePassword,
                            decoration: _fieldDecoration().copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _LinkText('Forgot Username?'),
                          const SizedBox(height: 8),
                          const _LinkText('Forgot Password?'),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: border(AppColors.fieldBorder, 1),
      focusedBorder: border(AppColors.teal, 2),
    );
  }
}

class _BrowserBar extends StatelessWidget {
  const _BrowserBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(color: AppColors.browserBlue, fontSize: 16),
              ),
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 14, color: Color(0xFF202124)),
              SizedBox(width: 4),
              Text(
                'login.becu.org',
                style: TextStyle(color: Color(0xFF202124), fontSize: 16),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.refresh, size: 20, color: AppColors.browserBlue),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {this.fontSize = 16});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.teal,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '© 2025 BECU. All rights reserved.',
            style: TextStyle(color: AppColors.support, fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _LinkText('About us', fontSize: 14),
              SizedBox(width: 16),
              _LinkText('Terms and Legal', fontSize: 14),
              SizedBox(width: 16),
              _LinkText('Privacy policy', fontSize: 14),
            ],
          ),
        ],
      ),
    );
  }
}
