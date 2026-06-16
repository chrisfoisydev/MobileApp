import 'package:flutter/material.dart';

enum AccountKind { checking, savings, creditCard, loan }

class Account {
  const Account({
    required this.nickname,
    required this.officialName,
    required this.last4,
    required this.kind,
    required this.availableBalance,
    required this.postedBalance,
    required this.pendingTotal,
    this.routingNumber = '325081403',
    this.balanceLabel,
    this.creditInfo,
    this.buckets = const [],
  });

  final String nickname;
  final String officialName;
  final String last4;
  final AccountKind kind;
  final double availableBalance;
  final double postedBalance;
  final double pendingTotal;
  final String routingNumber;

  /// Optional caption shown under the balance on the summary screen,
  /// e.g. "Current Balance" for credit cards.
  final String? balanceLabel;

  /// Present for credit-card accounts; drives the credit card detail view.
  final CreditCardInfo? creditInfo;

  /// Savings goals/jars shown on the Savings Buckets tab.
  final List<SavingsBucket> buckets;

  String get displayName => '$nickname ...$last4';
  String get maskedNumber => '********$last4';

  String get typeLabel => switch (kind) {
        AccountKind.checking => 'Checking',
        AccountKind.savings => 'Savings',
        AccountKind.creditCard => 'Credit Card',
        AccountKind.loan => 'Loan',
      };
}

/// A savings bucket/jar. A non-null [goal] makes it a goal (purple); a null
/// [goal] is a "just saving up" jar (blue).
class SavingsBucket {
  const SavingsBucket({
    required this.name,
    required this.saved,
    this.goal,
    this.daysLeft,
    this.autoTransfer = false,
    this.monthlyContribution,
    this.featured = false,
  });

  final String name;
  final double saved;
  final double? goal;
  final String? daysLeft;
  final bool autoTransfer;
  final double? monthlyContribution;

  /// Renders as the large progress card at the top of the list.
  final bool featured;

  bool get isGoal => goal != null;

  /// Fraction saved toward [goal] (0..1); 0 when there is no goal.
  double get progress =>
      goal == null || goal == 0 ? 0 : (saved / goal!).clamp(0, 1);
}

/// Credit-card-specific payment terms and limits.
class CreditCardInfo {
  const CreditCardInfo({
    required this.lastPayment,
    required this.amountPastDue,
    required this.nextPaymentDue,
    required this.minimumPaymentDue,
    required this.autopay,
    required this.interestRate,
    required this.ytdInterest,
    required this.availableCredit,
    required this.creditLimit,
  });

  final double lastPayment;
  final double amountPastDue;
  final String nextPaymentDue;
  final double minimumPaymentDue;
  final double autopay;
  final String interestRate;
  final double ytdInterest;
  final double availableCredit;
  final double creditLimit;
}

class BankTransaction {
  const BankTransaction({
    required this.title,
    required this.method,
    required this.dateLabel,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.category,
    required this.transactionId,
    required this.createdDate,
    required this.postedDate,
    this.runningBalance,
    this.addressLines = const [],
  });

  final String title;
  final String method;
  final String dateLabel;
  final double amount;
  final double? runningBalance;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String category;
  final String transactionId;
  final String createdDate;
  final String postedDate;
  final List<String> addressLines;
}

class TransactionGroup {
  const TransactionGroup(this.label, this.transactions);

  final String label;
  final List<BankTransaction> transactions;
}
