import 'package:flutter/material.dart';
class EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
        Text("No Data Found", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}