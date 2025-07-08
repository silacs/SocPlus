import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;

  const PasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.onSaved, this.errorText,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: hidden,
      onChanged: widget.onChanged,
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        isDense: true,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        label: widget.label,
        hintText: widget.hint,
        suffix: IconButton(
          onPressed: () {
            setState(() {
              hidden = !hidden;
            });
          },
          icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
