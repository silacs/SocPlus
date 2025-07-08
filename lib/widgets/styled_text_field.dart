import 'package:flutter/material.dart';

class StyledTextField extends StatefulWidget {
  final Widget? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  const StyledTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved, this.errorText,
  });

  @override
  State<StyledTextField> createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        errorText: widget.errorText,
        hintText: widget.hint,
        label: widget.label,
        border: OutlineInputBorder(),
      ),
      validator: widget.validator,
    );
  }
}
