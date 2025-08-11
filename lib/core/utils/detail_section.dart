import 'package:flutter/material.dart';

class DetailSection extends StatelessWidget {
  final String? title;
  final Map<String, String> details;
  final EdgeInsets padding;
  final double spacing;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const DetailSection({
    super.key,
    this.title,
    required this.details,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = labelStyle ??
        TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        );

    final defaultValueStyle = valueStyle ??
        TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ...details.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text("${entry.key}:", style: defaultLabelStyle),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(entry.value, style: defaultValueStyle),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
