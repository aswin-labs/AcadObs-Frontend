import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_payment_bottomsheet.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceStudent invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late TextEditingController amountController;
  late TextEditingController paymentDateController;
  late TextEditingController transactionController;
  String? selectedMethod;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.invoice.invoice?.amount ?? "",
    );
    paymentDateController = TextEditingController(
      text:
          widget.invoice.invoice?.createdAt != null
              ? DateFormat(
                'yyyy-MM-dd',
              ).format(widget.invoice.invoice!.createdAt!)
              : "",
    );
    transactionController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DropdownProvider>().setSelectedItem("paymentMethod", "upi");
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    paymentDateController.dispose();
    transactionController.dispose();
    super.dispose();
  }

  bool _showFab() {
    const actionableStatuses = {'pending', 'partially_paid', 'overdue'};
    return actionableStatuses.contains(widget.invoice.status);
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = getPaymentStatusStyle(
      widget.invoice.status ?? "pending",
    );

    return Scaffold(
      appBar: CommonAppBar(title: "Invoice Details", isBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              decoration: BoxDecoration(
                color: statusStyle.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "₹ ${widget.invoice.invoice?.amount ?? ""}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    capitalizeEachWord(widget.invoice.invoice?.title ?? ""),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(190),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusStyle.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusStyle.iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.receipt_long_outlined,
                    title: "Invoice",
                    value: widget.invoice.invoice?.title ?? "N/A",
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),

                  _buildInfoRow(
                    icon: Icons.category_outlined,
                    title: "Category",
                    value: widget.invoice.invoice?.category ?? "N/A",
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),

                  _buildInfoRow(
                    icon: Icons.currency_rupee,
                    title: "Amount",
                    value: "₹${widget.invoice.invoice?.amount ?? "0.00"}",
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  _buildInfoRow(
                    icon: Icons.notes_outlined,
                    title: "Description",
                    value:
                        widget.invoice.invoice?.description ??
                        "No description available",
                    maxLines: 4,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),

                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: "Due Date",
                    value: DateFormatter.formatDateTime(
                      widget.invoice.invoice?.dueDate ?? DateTime.now(),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),

                  _buildInfoRow(
                    icon: Icons.info_outline,
                    title: "Payment Status",
                    value: statusStyle.label,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          _showFab()
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: CommonButton(
                  onPressed: () {
                    showCreatePaymentBottomSheet(
                      context: context,
                      invoice: widget.invoice,
                    );
                  },
                  widget: const Text("Upload File"),
                ),
              )
              : null,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                getPaymentStatusStyle(
                  widget.invoice.status ?? "pending",
                ).backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color:
                getPaymentStatusStyle(
                  widget.invoice.status ?? "pending",
                ).iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
