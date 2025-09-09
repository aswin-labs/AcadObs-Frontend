import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';

import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';

import 'package:flutter/material.dart';

class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;
  const PaymentDetailScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(payment.paymentType.toString()),
        isBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: const Color(0xFFCEFFD3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.payment, color: Color(0xFF5DD168), size: 150),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    capitalizeEachWord(payment.paymentType.toString()),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "₹${payment.amount}",
                    style: TextStyle(color: Color(0xFF949494)),
                  ),
                ),
                Spacer(),

                Text(
                  DateFormatter.formatDateTime(
                    payment.paymentDate ?? DateTime.now(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
