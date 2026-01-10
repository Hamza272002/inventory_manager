import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String) onChanged;
  const CustomTextField({super.key, required this.label, required this.icon, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onChanged: onChanged,
  );
}