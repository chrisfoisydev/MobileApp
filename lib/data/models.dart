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

  String get displayName => '$nickname ...$last4';
  String get maskedNumber => '********$last4';

  String get typeLabel => switch (kind) {
        AccountKind.checking => 'Checking',
        AccountKind.savings => 'Savings',
        AccountKind.creditCard => 'Credit Card',
        AccountKind.loan => 'Loan',
      };
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
