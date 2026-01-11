import 'dart:typed_data'; // ضروري للتعامل مع بيانات الصورة على الويب
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  // تغيير نوع المتغير ليدعم الويب والموبايل
  Uint8List? _imageBytes; 
  String? _imageName;
  bool _isSaving = false;

  // ================== دالة اختيار الصورة (المعدلة للويب) ==================
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

    if (image != null) {
      // قراءة الصورة كبايتات بدلاً من ملف
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    }
  }

  // ================== دالة حفظ المنتج ==================
  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<ProductProvider>();
      String imageUrl = '';

      // 1. رفع الصورة كبايتات (تعمل على الويب والموبايل)
      if (_imageBytes != null && _imageName != null) {
        // تأكد أنك قمت بتحديث دالة الرفع في الـ Provider لتقبل Uint8List
        imageUrl = await provider.uploadImageWeb(_imageBytes!, _imageName!);
      }

      // 2. إضافة المنتج
      await provider.addProduct(
        _nameController.text.trim(),
        _descController.text.trim(),
        int.parse(_qtyController.text),
        double.parse(_priceController.text),
        imageUrl, 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼️ عرض الصورة باستخدام Image.memory بدلاً من Image.file
              GestureDetector(
                onTap: _isSaving ? null : _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          // استخدام memory لعرض البايتات (يحل مشكلة الويب)
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text('Tap to add product image', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (\$)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: _isSaving ? null : _saveProduct,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Uploading & Saving...' : 'Save Product'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }
}