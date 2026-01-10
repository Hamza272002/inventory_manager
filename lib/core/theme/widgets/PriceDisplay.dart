import 'package:flutter/material.dart';
class PriceDisplay extends StatelessWidget {
  final double price;
  const PriceDisplay({super.key, required this.price});
  @override
  Widget build(BuildContext context) => Text(
    '\$${price.toStringAsFixed(2)}',
    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
  );
}