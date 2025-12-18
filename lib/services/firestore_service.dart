import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hetanshi_enterprise/models/party_model.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/models/expense_model.dart';
import 'package:hetanshi_enterprise/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _products => _db.collection('products');
  CollectionReference get _parties => _db.collection('parties');
  CollectionReference get _orders => _db.collection('orders');
  CollectionReference get _categories => _db.collection('categories');
  CollectionReference get _notifications => _db.collection('notifications');
  CollectionReference get _expenses => _db.collection('expenses');
  CollectionReference get _users => _db.collection('users');

  // --- Users ---
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final query = await _users
          .where('email', isEqualTo: email)
          // We don't filter by role 'user' strictly in query, because admin created users might have 'Salesman' or 'User' role.
          // But effectively we are looking for valid credentials.
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final user =
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Check password
        if (user.password == password) {
          return user;
        }
      }
      return null;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  Stream<List<UserModel>> getUsers() {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addUser(UserModel user) {
    return _users.add(user.toMap());
  }

  Future<void> deleteUser(String id) {
    return _users.doc(id).delete();
  }

  // --- Expenses ---
  Stream<List<ExpenseModel>> getExpenses() {
    return _expenses
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addExpense(ExpenseModel expense) {
    return _expenses.add(expense.toMap());
  }

  Future<void> deleteExpense(String id) {
    return _expenses.doc(id).delete();
  }

  Stream<double> getTotalExpenses() {
    return _expenses.snapshots().map((snapshot) {
      return snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['amount'] ?? 0.0);
      });
    });
  }

  // --- Products ---
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addProduct(Product product) {
    return _products.add(product.toMap());
  }

  Future<void> updateProduct(Product product) {
    return _products.doc(product.id).update(product.toMap());
  }

  Future<void> updateProductStock(String productId, int quantityDeducted) {
    final docRef = _products.doc(productId);
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Product does not exist!");
      }
      final newStock = (snapshot.data() as Map<String, dynamic>)['stock'] ?? 0;
      // We allow negative stock for now if admin forces it via other means,
      // but ideally we check before calling this.
      // This strict Transaction ensures atomic updates.
      transaction
          .update(docRef, {'stock': FieldValue.increment(-quantityDeducted)});
    });
  }

  Future<void> deleteProduct(String id) {
    return _products.doc(id).delete();
  }

  // --- Parties ---
  Stream<List<Party>> getParties() {
    return _parties.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Party.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
  Stream<List<OrderModel>> getOrders({String? userId}) {
    Query query = _orders.orderBy('date', descending: true);

    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
          .map((doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addOrder(OrderModel order) {
    return _orders.add(order.toMap());
  }

  Future<void> deleteOrder(String id) {
    return _orders.doc(id).delete();
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

  // --- Notifications ---
  Stream<QuerySnapshot> getNotifications({String? targetUserId}) {
    Query query = _notifications.orderBy('timestamp', descending: true);

    // If targetUserId is provided, filter.
    // 'admin' sees all notifications targeted to 'admin' (and maybe 'all' if we had that).
    // Users see notifications targeted to their ID.
    if (targetUserId != null) {
      if (targetUserId == 'admin') {
        query = query.where('targetUserId', isEqualTo: 'admin');
      } else {
        query = query.where('targetUserId', isEqualTo: targetUserId);
      }
    }

    return query.snapshots();
  }

  Future<void> addNotification(String title, String body,
      {String? targetUserId}) {
    return _notifications.add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'targetUserId':
          targetUserId ?? 'admin', // Default to admin if not specified
    });
  }
}
