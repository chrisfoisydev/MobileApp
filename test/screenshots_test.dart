// Renders every prototype screen to docs/screenshots/*.png.
//
// Skipped during a normal `flutter test` run. To regenerate the images:
//
//   flutter test test/screenshots_test.dart \
//     --dart-define=screenshots=true --update-goldens
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/data/mock_data.dart';
import 'package:mobile_app/screens/account_detail_screen.dart';
import 'package:mobile_app/screens/account_summary_screen.dart';
import 'package:mobile_app/screens/credit_card_detail_screen.dart';
import 'package:mobile_app/screens/move_money_screen.dart';
import 'package:mobile_app/screens/my_profile_screen.dart';
import 'package:mobile_app/screens/sign_in_screen.dart';
import 'package:mobile_app/screens/transaction_detail_screen.dart';
import 'package:mobile_app/screens/transfer_screen.dart';
import 'package:mobile_app/screens/welcome_screen.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/widgets/status_bar.dart';

const _enabled = bool.fromEnvironment('screenshots');

void main() {
  setUpAll(() async {
    // Goldens render text with a placeholder font unless real fonts are
    // loaded; pull Roboto and the icon font from the local Flutter SDK.
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root == null) return;
    final fontsDir = Directory('$root/bin/cache/artifacts/material_fonts');
    if (!fontsDir.existsSync()) return;

    final roboto = FontLoader('Roboto');
    final icons = FontLoader('MaterialIcons');
    for (final file in fontsDir.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      final bytes = Future.value(
        ByteData.sublistView(file.readAsBytesSync()),
      );
      if (name.startsWith('Roboto-')) roboto.addFont(bytes);
      if (name == 'MaterialIcons-Regular.otf') icons.addFont(bytes);
    }
    await roboto.load();
    await icons.load();
  });

  final screens = <String, Widget>{
    'welcome': const WelcomeScreen(),
    'sign_in': const SignInScreen(),
    'account_summary': const AccountSummaryScreen(),
    'account_transactions': AccountDetailScreen(account: jointChecking),
    'account_manage_card':
        AccountDetailScreen(account: jointChecking, initialTab: 1),
    'account_details':
        AccountDetailScreen(account: jointChecking, initialTab: 2),
    'credit_card': const CreditCardDetailScreen(
      account: visaCreditCard,
      initialTab: 1,
    ),
    'my_profile': const MyProfileScreen(),
    'move_money': const MoveMoneyScreen(),
    'transfer': const TransferScreen(),
    'transfer_from': TransferScreen(
      initialStep: 1,
      initialToAccount: checkingAndSavings[2],
    ),
    'transfer_amount': TransferScreen(
      initialStep: 2,
      initialToAccount: checkingAndSavings[2],
      initialFromAccount: jointChecking,
      initialAmountCents: 7500,
      initialKeypadOpen: true,
    ),
    'transfer_date': TransferScreen(
      initialStep: 3,
      initialToAccount: checkingAndSavings[2],
      initialFromAccount: jointChecking,
      initialAmountCents: 7500,
      initialSelectedDay: 14,
      initialNote: 'Adding a little buffer',
    ),
    'transfer_review': TransferScreen(
      initialStep: 4,
      initialToAccount: checkingAndSavings[2],
      initialFromAccount: jointChecking,
      initialAmountCents: 7500,
      initialSelectedDay: 14,
      initialNote: 'Adding a little buffer',
    ),
    'transaction_details': TransactionDetailScreen(
      transaction: pendingTransactions.first,
      account: jointChecking,
    ),
  };

  for (final entry in screens.entries) {
    testWidgets('screenshot ${entry.key}', skip: !_enabled, (tester) async {
      tester.view.physicalSize = const Size(402 * 2, 874 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: deviceFrameBuilder,
        home: entry.value,
      ));
      // Advance past the entrance/cascade animations with stepped pumps;
      // the welcome backdrop loops forever, so pumpAndSettle would hang.
      // flutter_animate starts its controllers on a post-frame callback and
      // only advances on subsequent frames, so step the clock in small
      // increments instead of one big jump (which would freeze it at t=0).
      await tester.pump();
      for (var i = 0; i < 45; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../docs/screenshots/${entry.key}.png'),
      );
    });
  }
}
