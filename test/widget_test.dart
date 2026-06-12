import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/data/mock_data.dart';
import 'package:mobile_app/screens/account_detail_screen.dart';
import 'package:mobile_app/screens/account_summary_screen.dart';
import 'package:mobile_app/screens/sign_in_screen.dart';
import 'package:mobile_app/screens/welcome_screen.dart';

void main() {
  // Screens are pumped directly (without AppTheme) so tests don't depend on
  // google_fonts runtime fetching.
  testWidgets('welcome screen navigates to sign in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Member Sign In'), findsOneWidget);
  });

  testWidgets('sign in leads to the account summary', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Good Afternoon'), findsOneWidget);
    expect(find.text('Joint Checking ...4567'), findsOneWidget);
  });

  testWidgets('account summary opens the account view tabs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountSummaryScreen()));
    await tester.tap(find.text('Joint Checking ...4567'));
    await tester.pumpAndSettle();
    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);

    await tester.tap(find.text('Manage Card'));
    await tester.pumpAndSettle();
    expect(find.text('LEE M. CARDHOLDER'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Account Details'), findsOneWidget);
  });

  testWidgets('transaction tile opens transaction details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AccountDetailScreen(account: jointChecking)),
    );
    await tester.tap(find.text('Starbucks'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction description'), findsOneWidget);
    expect(find.text('6789012345'), findsOneWidget);
  });
}
