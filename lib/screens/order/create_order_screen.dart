import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/party_model.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/models/order_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _firestoreService = FirestoreService();

  Party? _selectedParty;
  List<OrderItem> _orderItems = [];
  bool _isLoading = false;

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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Item',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Product>(
                    decoration: const InputDecoration(labelText: 'Select Product'),
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(product.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setSheetState(() {
                        _selectedProduct = value;
                        if (value != null) {
                          _rateController.text = value.salesRate.toString();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(labelText: 'Quantity'),
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
                          decoration: const InputDecoration(labelText: 'Rate'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedProduct != null)
                    Text(
                      'Total: ₹${(double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_rateController.text) ?? 0)}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedProduct == null
                          ? null
                          : () {
                              final qty = int.tryParse(_quantityController.text) ?? 1;
                              final rate = double.tryParse(_rateController.text) ?? 0.0;
                              
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
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Add to Order'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double get _totalAmount {
    return _orderItems.fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> _saveOrder() async {
    if (_selectedParty == null || _orderItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final order = OrderModel(
        id: '', // Generated by Firestore
        partyId: _selectedParty!.id,
        partyName: _selectedParty!.name,
        date: DateTime.now(),
        totalAmount: _totalAmount,
        items: _orderItems,
      );

      await _firestoreService.addOrder(order);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('New Order'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Party>>(
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
                            DropdownButtonFormField<Party>(
                              decoration: const InputDecoration(
                                labelText: 'Select Party',
                                prefixIcon: Icon(Icons.person_outline),
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
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Items',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18, fontWeight: FontWeight.w600)),
                                TextButton.icon(
                                  onPressed: () => _showAddProductSheet(products),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Item'),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (_orderItems.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                    child: Text('No items added',
                                        style: TextStyle(color: Colors.grey))),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _orderItems.length,
                                separatorBuilder: (ctx, i) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = _orderItems[index];
                                  return ListTile(
                                    title: Text(item.productName),
                                    subtitle: Text(
                                        '${item.quantity} x ₹${item.rate}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('₹${item.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                            onPressed: () {
                                              setState(() {
                                                _orderItems.removeAt(index);
                                              });
                                            }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Amount',
                                    style: GoogleFonts.poppins(fontSize: 16)),
                                Text('₹${_totalAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1FA2A6))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading || _selectedParty == null || _orderItems.isEmpty
                                        ? null
                                        : _saveOrder,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text('Create Order',
                                        style: GoogleFonts.poppins(
                                            fontSize: 16, fontWeight: FontWeight.w600)),
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
    );
  }
}
