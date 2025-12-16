import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hetanshi_enterprise/models/party_model.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _products => _db.collection('products');
  CollectionReference get _parties => _db.collection('parties');
  CollectionReference get _orders => _db.collection('orders');
  CollectionReference get _categories => _db.collection('categories');

  // --- Products ---
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addProduct(Product product) {
    return _products.add(product.toMap());
  }

  Future<void> updateProduct(Product product) {
    return _products.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) {
    return _products.doc(id).delete();
  }

  // --- Parties ---
  Stream<List<Party>> getParties() {
    return _parties.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Party.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addParty(Party party) {
    return _parties.add(party.toMap());
  }

  Future<void> updateParty(Party party) {
    return _parties.doc(party.id).update(party.toMap());
  }

  Future<void> deleteParty(String id) {
    return _parties.doc(id).delete();
  }

  // --- Orders ---
  Stream<List<OrderModel>> getOrders() {
    return _orders.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Stream<List<OrderModel>> getOrdersByParty(String partyId) {
    return _orders
        .where('partyId', isEqualTo: partyId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addOrder(OrderModel order) {
    return _orders.add(order.toMap());
  }

  // --- Categories ---
  Stream<List<String>> getCategories() {
    return _categories.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> addCategory(String name) async {
    // Check if exists first to avoid duplicates (optional but good)
    final query = await _categories.where('name', isEqualTo: name).get();
    if (query.docs.isEmpty) {
      await _categories.add({'name': name});
    }
  }

  // --- Analytics ---
  Stream<int> getProductCount() {
    return _products.snapshots().map((s) => s.size);
  }

  Stream<int> getPartyCount() {
    return _parties.snapshots().map((s) => s.size);
  }

  Stream<int> getOrderCount() {
    return _orders.snapshots().map((s) => s.size);
  }
}
