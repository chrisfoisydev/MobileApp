import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/data/mock_data.dart';
import 'package:mobile_app/screens/account_detail_screen.dart';
import 'package:mobile_app/screens/account_summary_screen.dart';
import 'package:mobile_app/screens/sign_in_screen.dart';
import 'package:mobile_app/screens/transfer_screen.dart';
import 'package:mobile_app/screens/welcome_screen.dart';

void main() {
  // Screens are pumped directly (without AppTheme) so tests don't depend on
  // google_fonts runtime fetching.
  testWidgets('welcome screen navigates to sign in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
    // Fixed pumps instead of pumpAndSettle: the welcome backdrop loops a
    // parallax animation and never settles.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
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
    // Let the cascade-in animation finish so the cards are tappable.
    await tester.pumpAndSettle();
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

  testWidgets('profile menu opens My Profile', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountSummaryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Contact Information'), findsOneWidget);
  });

  testWidgets('a savings account shows Transactions and Details only',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountSummaryScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Joint Savings ...6789'));
    await tester.pumpAndSettle();

    // Savings accounts have no card to manage and no buckets tab.
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Manage Card'), findsNothing);
    expect(find.textContaining('Savings Buckets'), findsNothing);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Account Details'), findsOneWidget);
  });

  testWidgets('tapping a credit card opens the credit card view',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountSummaryScreen()));
    await tester.pumpAndSettle();
    final card = find.text('Credit Card ...2903');
    await tester.scrollUntilVisible(card, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(card);
    await tester.pumpAndSettle();

    // Credit-specific header and CTA, not the checking actions.
    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Make A Payment'), findsOneWidget);
    expect(find.text('Transfer Funds'), findsNothing);
    expect(find.text('Manage Card'), findsNothing);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Details'), findsOneWidget);

    final advance = find.text('Request Cash Advance');
    await tester.scrollUntilVisible(advance, 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Credit Limit'), findsOneWidget);
    expect(advance, findsOneWidget);
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

  testWidgets('Move Money nav and Transfer quick action navigate',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountSummaryScreen()));
    await tester.pumpAndSettle();

    // Bottom nav -> Move Money hub.
    await tester.tap(find.text('MOVE MONEY'));
    await tester.pumpAndSettle();
    expect(find.text('Make a Payment'), findsOneWidget);
    expect(find.text('Transfer Between Accounts'), findsOneWidget);

    // From Move Money, the transfer tile opens the transfer flow.
    await tester.tap(find.text('Transfer Between Accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Where is the money going?'), findsOneWidget);

    // Close back to Move Money.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Transfer Between Accounts'), findsOneWidget);
  });

  testWidgets('Transfer quick action on summary opens the transfer flow',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountSummaryScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Where is the money going?'), findsOneWidget);
  });

  testWidgets('selecting a To account advances to the From step',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TransferScreen()));
    await tester.pumpAndSettle();

    // Pick a destination from the To step.
    await tester.tap(find.text('Joint Savings ...6789'));
    await tester.pumpAndSettle();

    // Now on the From step: title changed, tracker shows the chosen
    // account under "To", and that account is excluded from the From list.
    expect(find.text('Where is the money from?'), findsOneWidget);
    expect(find.text('Joint Savings ...6789'), findsOneWidget); // tracker
    expect(find.text('Joint Checking ...4567'), findsOneWidget);
    expect(find.text('Student Checking ...8901'), findsOneWidget);

    // Back returns to the To step.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Where is the money going?'), findsOneWidget);
  });

  testWidgets('transfer flow continues through amount and date',
      (tester) async {
    // Use a phone-sized surface so the amount keypad has room.
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TransferScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Joint Savings ...6789'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Joint Checking ...4567'));
    await tester.pumpAndSettle();

    // Amount step: keypad is hidden until the amount field is tapped.
    expect(find.textContaining('How much would you like'), findsOneWidget);
    expect(find.text('7'), findsNothing);
    await tester.tap(find.text('0.00'));
    await tester.pumpAndSettle();
    for (final key in ['7', '5', '0', '0']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    expect(find.text('75.00'), findsOneWidget);

    final continueBtn = find.text('Continue');
    await tester.ensureVisible(continueBtn);
    await tester.pumpAndSettle();
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Date step with the calendar; pick a day, then continue to review.
    expect(find.textContaining('When do you want to'), findsOneWidget);
    expect(find.text('June 2026'), findsOneWidget);
    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set Date'));
    await tester.pumpAndSettle();

    // Review step.
    expect(find.textContaining('confirm everything looks good'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(
      find.text('Funds are typically available in 1–2 business days.'),
      findsOneWidget,
    );

    // The Amount edit pencil returns to the Amount step.
    await tester.tap(find.byIcon(Icons.edit_outlined).at(2));
    await tester.pumpAndSettle();
    expect(find.textContaining('How much would you like'), findsOneWidget);
  });
}
