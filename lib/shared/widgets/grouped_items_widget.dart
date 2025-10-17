import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class GroupedItemsWidget extends StatelessWidget {
  final DateTime? date;
  final int itemCount;
  final Widget widget;
  const GroupedItemsWidget({
    super.key,
    this.date,
    required this.itemCount,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormatter.formatDateTime(date ?? DateTime.now()),
            style: context.textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Responsive.height * 1),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              
              return widget;
            },
          ),
          SizedBox(height: Responsive.height * 2),
        ],
      ),
    );
  }
}
