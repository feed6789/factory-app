import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool allowDecimal;

  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.allowDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        labelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
