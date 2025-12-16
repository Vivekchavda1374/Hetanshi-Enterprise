  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:hetanshi_enterprise/models/product_model.dart';
  import 'package:hetanshi_enterprise/services/firestore_service.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/foundation.dart';

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
      _currentImageUrl = widget.product?.imageUrl ?? '';
    }

    @override
    void dispose() {
      _nameController.dispose();
      _mrpController.dispose();
      _salesRateController.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
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
        );

        if (widget.product == null) {
          await _firestoreService.addProduct(product);
        } else {
          await _firestoreService.updateProduct(product);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product saved successfully')),
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
          title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _selectedImage != null
                          ? DecorationImage(
                              // For web, we can't use FileImage directly with path easily across platforms without shenanigans,
                              // but for previewing raw bytes it's complex without Image.memory.
                              // To keep it simple cross-platform:
                              // If web: use NetworkImage (blob) if created? No, use Image.memory for bytes.
                              image: kIsWeb 
                                  ? NetworkImage(_selectedImage!.path) // Accessing path on web blob might work or fail depending on browser
                                  : FileImage(File(_selectedImage!.path)) as ImageProvider, // This branch won't execute on web
                            fit: BoxFit.cover,
                          ) 
                        : (_currentImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: _currentImageUrl.startsWith('http') 
                                    ? NetworkImage(_currentImageUrl)
                                    : MemoryImage(base64Decode(_currentImageUrl)) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: (_selectedImage == null && _currentImageUrl.isEmpty)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('Add Image', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        )
                      : null,
                ),
              ),
              // Helper to show Image.memory on web if needed, but keeping above simple first.
              if (_selectedImage != null && kIsWeb)
                 Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: FutureBuilder<Uint8List>(
                     future: _selectedImage!.readAsBytes(),
                     builder: (context, snapshot) {
                       if (snapshot.hasData) {
                         return Container(
                           width: 120, height: 120,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(12),
                             image: DecorationImage(image: MemoryImage(snapshot.data!), fit: BoxFit.cover),
                           ),
                         );
                       }
                       return const SizedBox();
                     },
                   ),
                 ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', prefixIcon: Icon(Icons.inventory_2_outlined)),
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mrpController,
                      decoration: const InputDecoration(labelText: 'MRP', prefixIcon: Icon(Icons.price_change_outlined)),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter MRP'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salesRateController,
                      decoration: const InputDecoration(labelText: 'Sales Rate', prefixIcon: Icon(Icons.currency_rupee)),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return value == null || value.isEmpty ? 'Enter Rate' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.product == null ? 'Add Product' : 'Update Product',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
