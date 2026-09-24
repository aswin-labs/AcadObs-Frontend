import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_payment_bottomsheet.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_transport_payment_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentDetailScreen extends StatefulWidget {
  final Payment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch latest payment details by ID
    if (widget.payment.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PaymentProvider>().fetchPaymentById(widget.payment.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        // Use fetched payment details if matching ID, otherwise fall back to widget.payment
        final activePayment =
            (provider.selectedPayment != null &&
                    provider.selectedPayment?.id == widget.payment.id)
                ? provider.selectedPayment!
                : widget.payment;

        final paymentStatusStyle = getPaymentStatusStyle(
          activePayment.paymentStatus ?? "",
        );

        final isDonation = activePayment.paymentCategory == "donation";

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: CommonAppBar(
            title: "Payment Details",
            isBackButton: true,
            actions: [
              // -------------------------------------------------------------
              // IDENTIFIABLE EDIT ACTION LOGIC:
              // 1. General Invoice:
              //    If transportInvoice is null (and invoiceStudent is present)
              //    and status is pending -> Open General Payment BottomSheet
              // -------------------------------------------------------------
              if (activePayment.paymentStatus == "pending" &&
                  !isDonation &&
                  activePayment.transportInvoice == null &&
                  activePayment.invoiceStudent != null)
                TextButton.icon(
                  key: const ValueKey('edit_invoice_payment_btn'),
                  onPressed: () {
                    // Ensure studentId is available on invoice
                    final invoice =
                        activePayment.invoiceStudent!.studentId != null
                            ? activePayment.invoiceStudent!
                            : activePayment.invoiceStudent!.copyWith(
                              studentId:
                                  activePayment.studentId ??
                                  activePayment.student?.id,
                            );

                    showCreatePaymentBottomSheet(
                      context: context,
                      invoice: invoice,
                      transactionId: activePayment.transactionId,
                      forEdit: true,
                      paymentId: activePayment.id,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                ),

              // -------------------------------------------------------------
              // 2. Transport Invoice:
              //    If invoiceStudent is null (and transportInvoice is present)
              //    and status is pending -> Open Transport Payment BottomSheet
              // -------------------------------------------------------------
              if (activePayment.paymentStatus == "pending" &&
                  !isDonation &&
                  activePayment.invoiceStudent == null &&
                  activePayment.transportInvoice != null)
                TextButton.icon(
                  key: const ValueKey('edit_transport_payment_btn'),
                  onPressed: () {
                    // Ensure studentId is available on transport invoice
                    final transportInv =
                        activePayment.transportInvoice!.studentId != null
                            ? activePayment.transportInvoice!
                            : activePayment.transportInvoice!.copyWith(
                              studentId:
                                  activePayment.studentId ??
                                  activePayment.student?.id,
                            );

                    showCreateTransportPaymentBottomSheet(
                      context: context,
                      invoice: transportInv,
                      transactionId: activePayment.transactionId,
                      forEdit: true,
                      paymentId: activePayment.id,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (widget.payment.id != null) {
                await context.read<PaymentProvider>().fetchPaymentById(
                  widget.payment.id!,
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Loading progress bar indicator when refreshing in background
                  if (provider.isLoadingPaymentDetails)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: LinearProgressIndicator(minHeight: 3),
                      ),
                    ),

                  // Student info card (if returned in API response)
                  if (activePayment.student != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFF1F5F9),
                            backgroundImage:
                                activePayment.student?.image?.isNotEmpty == true
                                    ? CachedNetworkImageProvider(
                                      activePayment.student!.image!,
                                    )
                                    : null,
                            child:
                                activePayment.student?.image?.isNotEmpty != true
                                    ? const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF64748B),
                                      size: 24,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activePayment.student?.fullName ?? "Student",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                if (activePayment.student?.regNo?.isNotEmpty ==
                                    true)
                                  Text(
                                    "Reg No: ${activePayment.student!.regNo}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Payment summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: paymentStatusStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(190),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDonation
                                ? Icons.volunteer_activism_outlined
                                : (activePayment.invoiceStudent == null &&
                                        activePayment.transportInvoice != null
                                    ? Icons.directions_bus_outlined
                                    : Icons.payments_outlined),
                            color: paymentStatusStyle.iconColor,
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "₹ ${activePayment.amount ?? "0.00"}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isDonation
                              ? "Donation"
                              : (activePayment.invoiceStudent == null &&
                                      activePayment.transportInvoice != null
                                  ? (activePayment
                                              .transportInvoice
                                              ?.stop
                                              ?.stopName !=
                                          null
                                      ? "${activePayment.transportInvoice?.term ?? 'Transport'} - ${activePayment.transportInvoice!.stop!.stopName}"
                                      : (activePayment.transportInvoice?.term ??
                                          'Transport Fee'))
                                  : capitalizeEachWord(
                                    activePayment
                                            .invoiceStudent
                                            ?.invoice
                                            ?.title ??
                                        activePayment.paymentCategory ??
                                        "Payment",
                                  )),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            paymentStatusStyle.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: paymentStatusStyle.iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Invoice / Transport specific details section
                  if (!isDonation &&
                      (activePayment.transportInvoice != null ||
                          activePayment.invoiceStudent != null)) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                activePayment.invoiceStudent == null &&
                                        activePayment.transportInvoice != null
                                    ? Icons.directions_bus_outlined
                                    : Icons.receipt_long_outlined,
                                size: 18,
                                color: const Color(0xFF0F172A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                activePayment.invoiceStudent == null &&
                                        activePayment.transportInvoice != null
                                    ? "Transport Invoice Details"
                                    : "Invoice Details",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // If Transport Invoice
                          if (activePayment.invoiceStudent == null &&
                              activePayment.transportInvoice != null) ...[
                            _detailRow(
                              icon: Icons.directions_bus_outlined,
                              label: "Bus Stop",
                              value:
                                  activePayment
                                      .transportInvoice
                                      ?.stop
                                      ?.stopName ??
                                  "N/A",
                            ),
                            const Divider(height: 24),
                            _detailRow(
                              icon: Icons.schedule_outlined,
                              label: "Term",
                              value:
                                  activePayment.transportInvoice?.term ?? "N/A",
                            ),
                            const Divider(height: 24),
                            _detailRow(
                              icon: Icons.account_balance_wallet_outlined,
                              label: "Transport Fee",
                              value:
                                  "₹ ${activePayment.transportInvoice?.stop?.charge ?? activePayment.transportInvoice?.amount ?? "0.00"}",
                            ),
                            if (activePayment.transportInvoice?.dueDate != null) ...[
                              const Divider(height: 24),
                              _detailRow(
                                icon: Icons.event_outlined,
                                label: "Due Date",
                                value: DateFormatter.formatDateTime(
                                  activePayment.transportInvoice!.dueDate!,
                                ),
                              ),
                            ],
                          ] else if (activePayment.transportInvoice == null &&
                              activePayment.invoiceStudent != null) ...[
                            // If General Invoice
                            _detailRow(
                              icon: Icons.receipt_long_outlined,
                              label: "Invoice",
                              value:
                                  activePayment
                                      .invoiceStudent
                                      ?.invoice
                                      ?.title ??
                                  "N/A",
                            ),
                            const Divider(height: 24),
                            _detailRow(
                              icon: Icons.account_balance_wallet_outlined,
                              label: "Invoice Amount",
                              value:
                                  "₹ ${activePayment.invoiceStudent?.invoice?.amount ?? "0.00"}",
                            ),
                            if (activePayment
                                    .invoiceStudent
                                    ?.invoice
                                    ?.dueDate !=
                                null) ...[
                              const Divider(height: 24),
                              _detailRow(
                                icon: Icons.event_outlined,
                                label: "Due Date",
                                value: DateFormatter.formatDateTime(
                                  activePayment
                                      .invoiceStudent!
                                      .invoice!
                                      .dueDate!,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Payment information section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          icon: Icons.category_outlined,
                          label: "Category",
                          value: capitalizeEachWord(
                            (activePayment.paymentCategory ?? "N/A").replaceAll(
                              "_",
                              " ",
                            ),
                          ),
                        ),

                        const Divider(height: 28),

                        _detailRow(
                          icon: Icons.calendar_today_outlined,
                          label: "Payment Date",
                          value:
                              activePayment.paymentDate != null
                                  ? DateFormatter.formatDateTime(
                                    activePayment.paymentDate!,
                                  )
                                  : "N/A",
                        ),

                        const Divider(height: 28),

                        _detailRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: "Payment Method",
                          value: capitalizeEachWord(
                            (activePayment.paymentMethod ?? "N/A").replaceAll(
                              "_",
                              " ",
                            ),
                          ),
                        ),

                        const Divider(height: 28),

                        _detailRow(
                          icon: Icons.tag_outlined,
                          label: "Transaction ID",
                          value:
                              activePayment.transactionId?.isNotEmpty == true
                                  ? activePayment.transactionId!
                                  : "N/A",
                        ),

                        if (activePayment.remarks != null &&
                            activePayment.remarks.toString().isNotEmpty) ...[
                          const Divider(height: 28),
                          _detailRow(
                            icon: Icons.notes_outlined,
                            label: "Remarks",
                            value: activePayment.remarks.toString(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Payment attachment
                  if (activePayment.paymentAttachment?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    DownloadFileCard(
                      fileName: activePayment.paymentAttachment!,
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),

        const SizedBox(width: 12),

        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
