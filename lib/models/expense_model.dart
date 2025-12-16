import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String description;
  final String category; // e.g. Rent, Salary, Bills

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.description = '',
    this.category = 'General',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'category': category,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
    );
  }
}
