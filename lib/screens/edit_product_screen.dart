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
  // إضافة المتحكم الخاص بالاسم
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // تهيئة جميع المتحكمات بالبيانات الحالية للمنتج
    _nameController = TextEditingController(text: widget.product.name);
    _qtyController = TextEditingController(text: widget.product.quantity.toString());
    _priceController = TextEditingController(text: widget.product.price.toString());
    _descController = TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    // تنظيف الذاكرة لجميع المتحكمات
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    // التأكد من أن الحقول ليست فارغة قبل الحفظ (Validation بسيط)
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name')),
      );
      return;
    }

    // إرسال البيانات الأربعة (الاسم، الوصف، الكمية، السعر) للـ Provider
    // ملاحظة: تأكد أنك استبدلت دالة updateProduct في ملف Provider بالكود الذي أرسلته لك سابقاً
    await context.read<ProductProvider>().updateProduct(
          widget.product.id,
          _nameController.text, // الاسم الجديد
          _descController.text, 
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Product Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // 1. حقل تعديل الاسم الجديد
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 2. حقل الوصف
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 3. حقل الكمية
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 4. حقل السعر
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (\$)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            // زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _save,
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}