import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "B|E|C|U" wordmark. [outlined] renders the white-outline variant
/// used on the debit card; the default is the solid red lockup.
class BecuLogo extends StatelessWidget {
  const BecuLogo({super.key, this.height = 40, this.outlined = false});

  final double height;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final letterStyle = TextStyle(
      color: Colors.white,
      fontSize: height * 0.5,
      fontWeight: FontWeight.w800,
      height: 1,
    );
    final divider = Container(
      width: 1.5,
      height: height * 0.5,
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: height * 0.14),
    );
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.22),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.becuRed,
        borderRadius: BorderRadius.circular(height * 0.1),
        border: outlined ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('B', style: letterStyle),
          divider,
          Text('E', style: letterStyle),
          divider,
          Text('C', style: letterStyle),
          divider,
          Text('U', style: letterStyle),
        ],
      ),
    );
  }
}

/// Small red square "B" badge shown next to account names.
class BecuBadge extends StatelessWidget {
  const BecuBadge({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.becuRed,
        borderRadius: BorderRadius.circular(size * 0.17),
      ),
      child: Text(
        'B',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.58,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
