import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_payment_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceStudent invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.invoice.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PaymentProvider>().fetchStudentInvoiceById(
          widget.invoice.id!,
        );
      });
    }
  }

  bool _showFab(String? status) {
    const actionableStatuses = {'pending', 'partially_paid', 'overdue'};
    return actionableStatuses.contains(status?.toLowerCase() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final activeInvoice =
            (provider.selectedInvoice != null &&
                    provider.selectedInvoice?.id == widget.invoice.id)
                ? provider.selectedInvoice!
                : widget.invoice;

        final statusStyle = getPaymentStatusStyle(
          activeInvoice.status ?? "pending",
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: const CommonAppBar(
            title: "Invoice Details",
            isBackButton: true,
          ),
          body: Column(
            children: [
              if (provider.isLoadingDetails)
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00AEF0)),
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          color: statusStyle.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "₹ ${activeInvoice.invoice?.amount ?? "0.00"}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              capitalizeEachWord(
                                activeInvoice.invoice?.title
                                            ?.trim()
                                            .isNotEmpty ==
                                        true
                                    ? activeInvoice.invoice!.title!
                                    : "School Fee",
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (activeInvoice.invoice?.category != null &&
                                activeInvoice.invoice!.category!
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                capitalizeEachWord(
                                  activeInvoice.invoice!.category!,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(220),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusStyle.icon,
                                    size: 14,
                                    color: statusStyle.iconColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusStyle.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: statusStyle.iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // If partially paid or amounts are present, show payment progress & breakdown
                            if (activeInvoice.pendingAmount != null ||
                                activeInvoice.totalAmountPaid != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(245),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Amount Paid
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    LucideIcons.checkCircle2,
                                                    size: 14,
                                                    color: Color(0xFF16A34A),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "Paid Amount",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "₹ ${activeInvoice.formattedTotalPaid ?? "0.00"}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF16A34A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 34,
                                          width: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(width: 16),
                                        // Remaining Balance
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    LucideIcons.clock,
                                                    size: 14,
                                                    color: Color(0xFFEA580C),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "Remaining",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "₹ ${activeInvoice.formattedPendingAmount ?? "0.00"}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFEA580C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (activeInvoice.totalAmountNum != null &&
                                        activeInvoice.totalAmountNum! > 0 &&
                                        activeInvoice.totalAmountPaid !=
                                            null) ...[
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: (activeInvoice
                                                      .totalAmountPaid! /
                                                  activeInvoice.totalAmountNum!)
                                              .clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF16A34A)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Information Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: LucideIcons.receiptText,
                              title: "Invoice Title",
                              value: activeInvoice.invoice?.title ?? "N/A",
                              statusStyle: statusStyle,
                            ),
                            if (activeInvoice.student?.fullName != null &&
                                activeInvoice.student!.fullName!
                                    .trim()
                                    .isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.user,
                                title: "Student Name",
                                value: capitalizeEachWord(
                                  activeInvoice.student!.fullName!,
                                ),
                                statusStyle: statusStyle,
                              ),
                            ],
                            if (activeInvoice.invoice?.category != null &&
                                activeInvoice.invoice!.category!
                                    .trim()
                                    .isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.tags,
                                title: "Category",
                                value: capitalizeEachWord(
                                  activeInvoice.invoice!.category!,
                                ),
                                statusStyle: statusStyle,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.indianRupee,
                              title: "Total Amount",
                              value:
                                  "₹${activeInvoice.invoice?.amount ?? "0.00"}",
                              statusStyle: statusStyle,
                            ),
                            if (activeInvoice.totalAmountPaid != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.badgeCheck,
                                title: "Amount Paid",
                                value:
                                    "₹${activeInvoice.formattedTotalPaid ?? "0.00"}",
                                iconColor: const Color(0xFF16A34A),
                                iconBgColor: const Color(0xFFDCFCE7),
                                valueColor: const Color(0xFF16A34A),
                              ),
                            ],
                            if (activeInvoice.pendingAmount != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.hourglass,
                                title: "Remaining Balance",
                                value:
                                    "₹${activeInvoice.formattedPendingAmount ?? "0.00"}",
                                iconColor: const Color(0xFFEA580C),
                                iconBgColor: const Color(0xFFFFEDD5),
                                valueColor: const Color(0xFFEA580C),
                              ),
                            ],
                            if (activeInvoice.invoice?.description != null &&
                                activeInvoice.invoice!.description!
                                    .trim()
                                    .isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                icon: LucideIcons.fileText,
                                title: "Description",
                                value: activeInvoice.invoice!.description!,
                                statusStyle: statusStyle,
                                maxLines: 4,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.calendar,
                              title: "Due Date",
                              value:
                                  activeInvoice.invoice?.dueDate != null
                                      ? DateFormatter.formatDateTime(
                                        activeInvoice.invoice!.dueDate!,
                                      )
                                      : "N/A",
                              statusStyle: statusStyle,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              icon: LucideIcons.info,
                              title: "Payment Status",
                              value: statusStyle.label,
                              statusStyle: statusStyle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton:
              _showFab(activeInvoice.status)
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CommonButton(
                      onPressed: () {
                        showCreatePaymentBottomSheet(
                          context: context,
                          invoice: activeInvoice,
                        );
                      },
                      widget: const Text(
                        "Pay Now / Upload Receipt",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    PaymentStatusStyle? statusStyle,
    Color? iconColor,
    Color? iconBgColor,
    Color? valueColor,
    int maxLines = 2,
  }) {
    final effectiveIconColor =
        iconColor ?? statusStyle?.iconColor ?? const Color(0xFF00AEF0);
    final effectiveBgColor =
        iconBgColor ?? statusStyle?.backgroundColor ?? const Color(0xFFE0F2FE);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: effectiveIconColor, size: 20),
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
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
