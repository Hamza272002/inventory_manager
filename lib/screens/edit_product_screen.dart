import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _descController; // الحقل الجديد

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.product.quantity.toString());
    _priceController = TextEditingController(text: widget.product.price.toString());
    _descController = TextEditingController(text: widget.product.description); // تهيئة الوصف
  }

  // تنظيف الذاكرة
  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    // إرسال البيانات الثلاثة للـ Provider
    await context.read<ProductProvider>().updateProduct(
          widget.product.id,
          _descController.text, // القيمة الجديدة
          int.parse(_qtyController.text),
          double.parse(_priceController.text),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView( // أضفنا سكرول لتجنب مشكلة الكيبورد
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Editing: ${widget.product.name}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // حقل الوصف الجديد
            TextField(
              controller: _descController,
              maxLines: 3, // جعل الحقل يتسع لـ 3 أسطر
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}