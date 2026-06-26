import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/data/mock_data.dart';
import 'package:mobile_app/screens/account_detail_screen.dart';
import 'package:mobile_app/screens/account_summary_screen.dart';
import 'package:mobile_app/screens/credit_card_detail_screen.dart';
import 'package:mobile_app/screens/make_payment_screen.dart';
import 'package:mobile_app/screens/more_screen.dart';
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

    // The transfer tile sits in the second section; scroll it into view.
    final transferTile = find.text('Transfer Between Accounts');
    await tester.scrollUntilVisible(transferTile, 120,
        scrollable: find.byType(Scrollable).first);
    expect(transferTile, findsOneWidget);

    // From Move Money, the transfer tile opens the transfer flow.
    await tester.tap(transferTile);
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

  testWidgets('confirming a transfer shows the success screen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TransferScreen(
        initialStep: 4,
        initialToAccount: checkingAndSavings[2],
        initialFromAccount: jointChecking,
        initialAmountCents: 7500,
        initialSelectedDay: 14,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    // Fixed pumps (the success Lottie plays a one-shot animation).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Success!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Sending On'), findsOneWidget);
    expect(find.textContaining('Your transfer is scheduled'), findsOneWidget);
  });

  testWidgets('credit card Make A Payment opens the payment flow',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreditCardDetailScreen(account: visaCreditCard),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Make A Payment'));
    await tester.pumpAndSettle();

    // Lands on the From step with the card already chosen as the payee.
    expect(find.text('Where is the money from?'), findsOneWidget);
    expect(find.textContaining('Credit Card'), findsWidgets);
  });

  testWidgets('Make a Payment picks a card, source, and preset amount',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MakePaymentScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Where is the money going?'), findsOneWidget);
    // The credit card payee shows a minimum-payment reminder.
    expect(find.text('Credit Card ...2903'), findsOneWidget);
    expect(find.textContaining('Minimum payment of'), findsOneWidget);

    await tester.tap(find.text('Credit Card ...2903'));
    await tester.pumpAndSettle();
    expect(find.text('Where is the money from?'), findsOneWidget);

    await tester.tap(find.text('Joint Checking ...4567'));
    await tester.pumpAndSettle();

    // Amount step exposes the preset payment options.
    expect(find.textContaining('How much would you like to pay'),
        findsOneWidget);
    expect(find.text('Statement Balance'), findsOneWidget);
    expect(find.text('Minimum Payment'), findsOneWidget);
    expect(find.text('Current Balance'), findsOneWidget);

    await tester.tap(find.text('Current Balance'));
    await tester.pumpAndSettle();

    final continueBtn = find.text('Continue');
    await tester.scrollUntilVisible(continueBtn, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Date step shows the payment-due reminder.
    expect(find.textContaining('When do you want to pay'), findsOneWidget);
    expect(find.textContaining('Payment Due'), findsOneWidget);
  });

  testWidgets('confirming a payment shows the success screen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MakePaymentScreen(
        initialStep: 4,
        initialToAccount: visaCreditCard,
        initialFromAccount: jointChecking,
        initialOption: 0,
        initialSelectedDay: 14,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Success!'), findsOneWidget);
    expect(find.textContaining('Your payment is scheduled'), findsOneWidget);
  });

  testWidgets('More tab shows the secondary services menu',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Statements & Documents'), findsOneWidget);
    expect(find.text('Manage Cards'), findsOneWidget);

    final theme = find.text('Theme');
    await tester.scrollUntilVisible(theme, 150,
        scrollable: find.byType(Scrollable).first);
    expect(theme, findsOneWidget);
    expect(find.text('Personalization'), findsOneWidget);
  });

  testWidgets('More footer Accounts tab returns to the summary',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/accounts',
      routes: {'/accounts': (_) => const AccountSummaryScreen()},
    ));
    await tester.pumpAndSettle();

    // Footer -> More, then footer -> Accounts should land back on the
    // summary (not the login).
    await tester.tap(find.text('MORE'));
    await tester.pumpAndSettle();
    expect(find.text('Statements & Documents'), findsOneWidget);

    await tester.tap(find.text('ACCOUNTS'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Good Afternoon'), findsOneWidget);
  });

  testWidgets('More -> Manage Cards opens the cards hub', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage Cards'));
    await tester.pumpAndSettle();

    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Credit Card ****9009'), findsOneWidget);
    expect(find.text('Needs to be activated'), findsOneWidget);
  });
}
