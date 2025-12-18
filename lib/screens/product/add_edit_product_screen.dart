import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/models/product_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:hetanshi_enterprise/utils/toast_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/services/notification_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _mrpController;
  late TextEditingController _salesRateController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;

  // Image handling
  XFile? _selectedImage;
  String _currentImageUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _mrpController =
        TextEditingController(text: widget.product?.mrp.toString() ?? '');
    _salesRateController =
        TextEditingController(text: widget.product?.salesRate.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.product?.category ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '0');
    _currentImageUrl = widget.product?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mrpController.dispose();
    _salesRateController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) ToastUtils.showError(context, 'Error picking image: $e');
    }
  }

  Future<String> _convertImageToBase64() async {
    if (_selectedImage == null) return _currentImageUrl;

    try {
      final Uint8List imageBytes = await _selectedImage!.readAsBytes();
      final String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      throw Exception('Image conversion failed: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Convert image to Base64 if selected
      String finalImageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _convertImageToBase64();
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        mrp: double.parse(_mrpController.text.trim()),
        salesRate: double.parse(_salesRateController.text.trim()),
        imageUrl: finalImageUrl,
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
      );

      if (widget.product == null) {
        await _firestoreService.addProduct(product);
      } else {
        await _firestoreService.updateProduct(product);
      }

      if (mounted) {
        // Send Notification
        if (widget.product == null) {
          // Only for new products
          await NotificationService().sendNotificationToAll(
            'New Product Alert! 🚀',
            '${_nameController.text.trim()} has been added to the inventory.',
          );
        }

        Navigator.pop(context);
        ToastUtils.showSuccess(context, 'Product saved successfully');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _firestoreService.addCategory(controller.text.trim());
                setState(() {
                  _categoryController.text = controller.text.trim();
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ToastUtils.showSuccess(context, 'Category added');
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        // Or use AppColors.primaryBlue if desired, but consistent list header used white/blue mix.
        // Let's stick to simple AppBar for detail/edit screens to not overcomplicate deep auth stack
        // OR better: styled AppBar to match theme.
      ),
      body: ModernBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card Container for Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Image Picker Section
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGrey,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  width: 2),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4))
                              ],
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(_selectedImage!.path)
                                          : FileImage(
                                                  File(_selectedImage!.path))
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : (_currentImageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: _currentImageUrl
                                                  .startsWith('http')
                                              ? NetworkImage(_currentImageUrl)
                                              : MemoryImage(base64Decode(
                                                      _currentImageUrl))
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: (_selectedImage == null &&
                                    _currentImageUrl.isEmpty)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded,
                                          size: 40,
                                          color: AppColors.primaryBlue
                                              .withOpacity(0.5)),
                                      const SizedBox(height: 8),
                                      Text('Add Photo',
                                          style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Web Image Preview (optional, kept for safety)
                      if (_selectedImage != null && kIsWeb)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text("New image selected",
                              style: TextStyle(
                                  color: AppColors.successGreen, fontSize: 12)),
                        ),

                      const SizedBox(height: 32),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: const Icon(Icons.inventory_2_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      StreamBuilder<List<String>>(
                        stream: _firestoreService.getCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator(minHeight: 2);
                          }
                          final categories = snapshot.data ?? [];

                          return Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: categories
                                          .contains(_categoryController.text)
                                      ? _categoryController.text
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    prefixIcon:
                                        const Icon(Icons.category_outlined),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none),
                                  ),
                                  items: categories
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(
                                          () => _categoryController.text = val);
                                    }
                                  },
                                  validator: (value) => value == null &&
                                          _categoryController.text.isEmpty
                                      ? 'Select Category'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: _showAddCategoryDialog,
                                  icon: const Icon(Icons.add,
                                      color: AppColors.primaryBlue),
                                  tooltip: 'Add Category',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // MRP and Rate
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mrpController,
                              decoration: InputDecoration(
                                labelText: 'MRP',
                                prefixIcon:
                                    const Icon(Icons.price_change_outlined),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Enter MRP';
                                final val = double.tryParse(value);
                                if (val == null || val < 0)
                                  return 'Invalid MRP';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _salesRateController,
                              decoration: InputDecoration(
                                labelText: 'Sales Rate',
                                prefixIcon: const Icon(Icons.currency_rupee),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Enter Rate';
                                final val = double.tryParse(value);
                                if (val == null || val < 0)
                                  return 'Invalid Rate';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stock Field
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Stock Quantity',
                          prefixIcon: const Icon(Icons.inventory_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter Stock';
                          final val = int.tryParse(value);
                          if (val == null || val < 0) return 'Invalid Stock';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  widget.product == null
                                      ? 'Save Product'
                                      : 'Update Product',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
