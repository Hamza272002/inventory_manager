import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int quantity;
  const StockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusText;

    if (quantity == 0) {
      badgeColor = Colors.red;
      statusText = 'Out of Stock';
    } else if (quantity < 10) {
      badgeColor = Colors.orange;
      statusText = 'Low Stock';
    } else {
      badgeColor = Colors.green;
      statusText = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border.all(color: badgeColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}