import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String? hintText;
  final String? label;
  final TextInputType? keyBoardtype;
  final ValueNotifier<bool> isObscure;
  final TextEditingController? controller;
  final bool isPasswordField;
  final Icon? iconData;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final double borderRadius;

  CustomTextfield({
    this.controller,
    super.key,
    this.hintText,
    this.label,
    required this.iconData,
    this.keyBoardtype,
    this.isPasswordField = false,
    this.hintStyle,
    this.textStyle,
    this.errorStyle,
    this.onTap,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.borderRadius = 8.0,
  }) : isObscure = ValueNotifier<bool>(isPasswordField);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: ValueListenableBuilder(
        valueListenable: isObscure,
        builder: (context, value, child) {
          return TextFormField(
            controller: controller,
            style:
                textStyle ??
                Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.black87,
                  fontSize: 14.0,
                ),
            obscureText: isPasswordField ? isObscure.value : false,
            keyboardType: keyBoardtype,
            onChanged: onChanged,
            validator: validator,
            readOnly: onTap != null,
            enabled: enabled,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 15.0,
              ),
              isDense: true,
              prefixIcon: iconData,
              labelText: label,
              hintText: hintText,
              hintStyle:
                  hintStyle ??
                  const TextStyle(fontSize: 14.0, color: Colors.grey),
              errorStyle:
                  errorStyle ??
                  const TextStyle(fontSize: 12.0, color: Colors.red),
              suffixIcon:
                  isPasswordField
                      ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () {
                            isObscure.value = !isObscure.value;
                          },
                          icon:
                              isObscure.value
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                        ),
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }
}
