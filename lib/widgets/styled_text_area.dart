import 'package:flutter/material.dart';

class StyledTextArea extends StatefulWidget {
  final Widget? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final int? maxLines;
  const StyledTextArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.errorText,
    this.maxLines,
  });

  @override
  State<StyledTextArea> createState() => _StyledTextAreaState();
}

class _StyledTextAreaState extends State<StyledTextArea> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.multiline,
      maxLines: widget.maxLines,
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
