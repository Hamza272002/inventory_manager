import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int quantity;

  const StockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (quantity == 0) {
      color = Colors.red;
      text = 'Out of stock';
    } else if (quantity < 5) {
      color = Colors.orange;
      text = 'Low stock';
    } else {
      color = Colors.green;
      text = 'In stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
