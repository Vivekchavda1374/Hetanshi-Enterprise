import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/party_model.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/auth_manager.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/utils/toast_utils.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';

class CreateOrderScreen extends StatefulWidget {
  final Product? initialProduct;
  const CreateOrderScreen({super.key, this.initialProduct});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _firestoreService = FirestoreService();

  Party? _selectedParty;
  List<OrderItem> _orderItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _orderItems.add(OrderItem(
        productId: widget.initialProduct!.id,
        productName: widget.initialProduct!.name,
        quantity: 1,
        rate: widget.initialProduct!.salesRate,
        amount: widget.initialProduct!.salesRate,
      ));
    }
  }

  // For product selection dialog
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _rateController = TextEditingController();

  void _showAddProductSheet(List<Product> products) {
    _selectedProduct = null;
    _quantityController.text = '1';
    _rateController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Transparent to show rounded corners nicely
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Item',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Product>(
                    decoration: InputDecoration(
                      labelText: 'Select Product',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    items: products.map((product) {
                      final isOutOfStock = product.stock <= 0;
                      return DropdownMenuItem(
                        value: isOutOfStock
                            ? null
                            : product, // Disable selection if needed or handle logic
                        enabled: !isOutOfStock,
                        child: Text(
                          '${product.name} ${isOutOfStock ? '(Out of Stock)' : '(Stock: ${product.stock})'}',
                          style: TextStyle(
                            color: isOutOfStock ? Colors.grey : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setSheetState(() {
                        _selectedProduct = value;
                        if (value != null) {
                          _rateController.text = value.salesRate.toString();
                          // Reset quantity validation if needed
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Select Product' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _rateController,
                          decoration: InputDecoration(
                            labelText: 'Rate',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedProduct != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Item Total:"),
                          Text(
                            '₹${(double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_rateController.text) ?? 0)}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.successGreen,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedProduct == null
                          ? null
                          : () {
                              final qty =
                                  int.tryParse(_quantityController.text) ?? 1;
                              final rate =
                                  double.tryParse(_rateController.text) ?? 0.0;

                              if (_selectedProduct != null &&
                                  qty > _selectedProduct!.stock) {
                                ToastUtils.showError(context,
                                    'Only ${_selectedProduct!.stock} items available');
                                return;
                              }

                              if (qty > 0 && rate >= 0) {
                                setState(() {
                                  _orderItems.add(OrderItem(
                                    productId: _selectedProduct!.id,
                                    productName: _selectedProduct!.name,
                                    quantity: qty,
                                    rate: rate,
                                    amount: qty * rate,
                                  ));
                                });
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add to Order',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      },
    );
  }

  double get _totalAmount {
    return _orderItems.fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> _saveOrder() async {
    final isUser = AuthManager.instance.isUser;

    if (_orderItems.isEmpty) {
      ToastUtils.showError(context, 'Please add items');
      return;
    }

    if (!isUser && _selectedParty == null) {
      ToastUtils.showError(context, 'Please select a party');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = isUser ? AuthManager.instance.currentUser!.id : '';

      // If User, use their details as Party. If Admin, use selected Party.
      final String finalPartyId = isUser ? userId : _selectedParty!.id;
      final String finalPartyName = isUser
          ? (AuthManager.instance.currentUser?.name ?? 'User')
          : _selectedParty!.name;

      final order = OrderModel(
        id: '', // Generated by Firestore
        userId: userId,
        partyId: finalPartyId,
        partyName: finalPartyName,
        date: DateTime.now(),
        totalAmount: _totalAmount,
        items: _orderItems,
      );

      await _firestoreService.addOrder(order);

      // --- Inventory Update ---
      // Deduct stock for each item
      for (final item in _orderItems) {
        // We use a try-catch here to ensure one failure doesn't stop others,
        // though ideally all should succeed.
        try {
          await _firestoreService.updateProductStock(
              item.productId, item.quantity);
        } catch (e) {
          debugPrint("Failed to update stock for ${item.productName}: $e");
        }
      }

      // --- Notifications ---
      // 1. Notify Admin
      await _firestoreService.addNotification(
        'New Order Received',
        'Order from $finalPartyName of ₹${_totalAmount.toStringAsFixed(0)}',
        targetUserId: 'admin',
      );

      // 2. Notify User (if it's a User)
      if (isUser && userId.isNotEmpty) {
        await _firestoreService.addNotification(
          'Order Successful',
          'Your order of ₹${_totalAmount.toStringAsFixed(0)} has been placed successfully.',
          targetUserId: userId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ToastUtils.showSuccess(context, 'Order created successfully');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('New Order'),
        // Standard AppBar to keep back functionality clear
      ),
      body: ModernBackground(
        child: StreamBuilder<List<Party>>(
            stream: _firestoreService.getParties(),
            builder: (context, partySnapshot) {
              final parties = partySnapshot.data ?? [];

              return StreamBuilder<List<Product>>(
                stream: _firestoreService.getProducts(),
                builder: (context, productSnapshot) {
                  final products = productSnapshot.data ?? [];

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Party Selection Card
                              if (AuthManager.instance.isUser)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Ordering For",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              color: AppColors.primaryBlue),
                                          const SizedBox(width: 12),
                                          Text(
                                            AuthManager.instance.currentUser
                                                    ?.name ??
                                                'User',
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: Offset(0, 4))
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Party Details",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.textPrimary)),
                                          const SizedBox(height: 12),
                                          DropdownButtonFormField<Party>(
                                            decoration: InputDecoration(
                                              labelText: 'Select Party',
                                              prefixIcon: const Icon(
                                                  Icons.person_outline),
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none),
                                            ),
                                            items: parties.map((party) {
                                              return DropdownMenuItem(
                                                value: party,
                                                child: Text(party.name),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedParty = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),

                              // Items Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Items',
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary)),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _showAddProductSheet(products),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Item'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.secondaryTeal,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (_orderItems.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.shopping_cart_outlined,
                                          size: 40, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text('No items added',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _orderItems.length,
                                  separatorBuilder: (ctx, i) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = _orderItems[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2))
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primaryBlue
                                              .withOpacity(0.1),
                                          child: Text('${index + 1}',
                                              style: const TextStyle(
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        title: Text(item.productName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${item.quantity} x ₹${item.rate}',
                                            style: TextStyle(
                                                color:
                                                    AppColors.textSecondary)),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                '₹${item.amount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppColors
                                                        .successGreen)),
                                            const SizedBox(width: 8),
                                            IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: AppColors.errorRed,
                                                    size: 20),
                                                onPressed: () {
                                                  setState(() {
                                                    _orderItems.removeAt(index);
                                                  });
                                                }),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              // Space for floating button
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Sheet for Total and Save
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, -5))
                          ],
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Amount',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: AppColors.textSecondary)),
                                  Text('₹${_totalAmount.toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ||
                                          _orderItems.isEmpty ||
                                          (!AuthManager.instance.isUser &&
                                              _selectedParty == null)
                                      ? null
                                      : _saveOrder,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : Text('Create Order',
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}
