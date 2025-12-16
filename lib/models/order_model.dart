import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double rate;
  final double amount;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      rate: (map['rate'] ?? 0.0).toDouble(),
      amount: (map['amount'] ?? 0.0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String partyId;
  final String partyName;
  final DateTime date;
  final double totalAmount;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.date,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyId': partyId,
      'partyName': partyName,
      'date': Timestamp.fromDate(date),
      'totalAmount': totalAmount,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      partyId: map['partyId'] ?? '',
      partyName: map['partyName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      items: List<OrderItem>.from(
        (map['items'] as List<dynamic>).map<OrderItem>(
          (x) => OrderItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
