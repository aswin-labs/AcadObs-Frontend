import 'package:acadobs/core/theme/colors/app_colors.dart';
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
import 'package:lucide_flutter/lucide_flutter.dart';
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
          backgroundColor: AppColors.background,
          appBar: CommonAppBar(
            title: "Payment Details",
            isBackButton: true,
            actions: [
              // 1. General Invoice Edit Action
              if (activePayment.paymentStatus == "pending" &&
                  !isDonation &&
                  activePayment.transportInvoice == null &&
                  activePayment.invoiceStudent != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    key: const ValueKey('edit_invoice_payment_btn'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    onPressed: () {
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
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      "Edit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // 2. Transport Invoice Edit Action
              if (activePayment.paymentStatus == "pending" &&
                  !isDonation &&
                  activePayment.invoiceStudent == null &&
                  activePayment.transportInvoice != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    key: const ValueKey('edit_transport_payment_btn'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    onPressed: () {
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
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      "Edit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loading progress bar indicator when refreshing in background
                  if (provider.isLoadingPaymentDetails)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00AEF0),
                          ),
                        ),
                      ),
                    ),

                  // 1. Student info card (if present)
                  if (activePayment.student != null) ...[
                    _buildStudentCard(student: activePayment.student!),
                    const SizedBox(height: 16),
                  ],

                  // 2. Hero Payment Summary Card
                  _buildHeroPaymentCard(
                    payment: activePayment,
                    statusStyle: paymentStatusStyle,
                    isDonation: isDonation,
                  ),

                  // 3. Invoice / Transport Specific Details Section
                  if (!isDonation &&
                      (activePayment.transportInvoice != null ||
                          activePayment.invoiceStudent != null)) ...[
                    const SizedBox(height: 16),
                    _buildInvoiceSpecificCard(payment: activePayment),
                  ],

                  const SizedBox(height: 16),

                  // 4. Payment Information Card
                  _buildPaymentInformationCard(payment: activePayment),

                  // 5. Payment Attachment Card
                  if (activePayment.paymentAttachment?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    DownloadFileCard(
                      fileName: activePayment.paymentAttachment!,
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Student Information Card
  Widget _buildStudentCard({required PaymentStudentInfo student}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage:
                student.image?.isNotEmpty == true
                    ? CachedNetworkImageProvider(student.image!)
                    : null,
            child:
                student.image?.isNotEmpty != true
                    ? const Icon(
                      LucideIcons.user,
                      color: Color(0xFF64748B),
                      size: 20,
                    )
                    : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeEachWord(student.fullName ?? "Student"),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (student.regNo?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    "Reg No: ${student.regNo}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Payment Summary Card
  Widget _buildHeroPaymentCard({
    required Payment payment,
    required PaymentStatusStyle statusStyle,
    required bool isDonation,
  }) {
    final title =
        isDonation
            ? "Donation"
            : (payment.invoiceStudent == null &&
                    payment.transportInvoice != null
                ? (payment.transportInvoice?.stop?.stopName != null
                    ? "${payment.transportInvoice?.term ?? 'Transport'} - ${payment.transportInvoice!.stop!.stopName}"
                    : (payment.transportInvoice?.term ?? 'Transport Fee'))
                : capitalizeEachWord(
                  payment.invoiceStudent?.invoice?.title ??
                      payment.paymentCategory ??
                      "Payment",
                ));

    final categoryLabel =
        isDonation
            ? "Donation"
            : (payment.paymentCategory?.isNotEmpty == true
                ? capitalizeEachWord(
                  payment.paymentCategory!.replaceAll("_", " "),
                )
                : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category tag + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (categoryLabel != null && categoryLabel.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categoryLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusStyle.icon,
                      size: 13,
                      color: statusStyle.iconColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusStyle.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusStyle.iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Amount & Title
          Text(
            "₹ ${payment.amount ?? "0.00"}",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Invoice / Transport Specific Details Card
  Widget _buildInvoiceSpecificCard({required Payment payment}) {
    final isTransport =
        payment.invoiceStudent == null && payment.transportInvoice != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTransport ? "Transport Invoice Details" : "Invoice Details",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          if (isTransport) ...[
            _buildInfoRow(
              icon: LucideIcons.bus,
              title: "Bus Stop",
              value: payment.transportInvoice?.stop?.stopName ?? "N/A",
            ),
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.calendarClock,
              title: "Term",
              value: payment.transportInvoice?.term ?? "N/A",
            ),
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.indianRupee,
              title: "Transport Fee",
              value:
                  "₹ ${payment.transportInvoice?.stop?.charge ?? payment.transportInvoice?.amount ?? "0.00"}",
            ),
            if (payment.transportInvoice?.dueDate != null) ...[
              const _CardDivider(),
              _buildInfoRow(
                icon: LucideIcons.calendar,
                title: "Due Date",
                value: DateFormatter.formatDateTime(
                  payment.transportInvoice!.dueDate!,
                ),
              ),
            ],
          ] else ...[
            _buildInfoRow(
              icon: LucideIcons.receiptText,
              title: "Invoice Title",
              value: payment.invoiceStudent?.invoice?.title ?? "N/A",
            ),
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.indianRupee,
              title: "Invoice Amount",
              value: "₹ ${payment.invoiceStudent?.invoice?.amount ?? "0.00"}",
            ),
            if (payment.invoiceStudent?.invoice?.dueDate != null) ...[
              const _CardDivider(),
              _buildInfoRow(
                icon: LucideIcons.calendar,
                title: "Due Date",
                value: DateFormatter.formatDateTime(
                  payment.invoiceStudent!.invoice!.dueDate!,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Payment Information Card
  Widget _buildPaymentInformationCard({required Payment payment}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Information",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: LucideIcons.tags,
            title: "Category",
            value: capitalizeEachWord(
              (payment.paymentCategory ?? "N/A").replaceAll("_", " "),
            ),
          ),
          const _CardDivider(),
          _buildInfoRow(
            icon: LucideIcons.calendar,
            title: "Payment Date",
            value:
                payment.paymentDate != null
                    ? DateFormatter.formatDateTime(payment.paymentDate!)
                    : "N/A",
          ),
          const _CardDivider(),
          _buildInfoRow(
            icon: LucideIcons.wallet,
            title: "Payment Method",
            value: capitalizeEachWord(
              (payment.paymentMethod ?? "N/A").replaceAll("_", " "),
            ),
          ),
          const _CardDivider(),
          _buildInfoRow(
            icon: LucideIcons.hash,
            title: "Transaction ID",
            value:
                payment.transactionId?.isNotEmpty == true
                    ? payment.transactionId!
                    : "N/A",
          ),
          if (payment.remarks != null &&
              payment.remarks.toString().trim().isNotEmpty) ...[
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.fileText,
              title: "Remarks",
              value: payment.remarks.toString(),
              maxLines: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    Color? iconBgColor,
    Color? valueColor,
    int maxLines = 2,
  }) {
    final effectiveIconColor = iconColor ?? const Color(0xFF475569);
    final effectiveBgColor = iconBgColor ?? const Color(0xFFF1F5F9);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: effectiveIconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
