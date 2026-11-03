import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/transport_payment_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_transport_payment_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportInvoiceDetailScreen extends StatefulWidget {
  final TransportInvoice invoice;
  const TransportInvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<TransportInvoiceDetailScreen> createState() =>
      _TransportInvoiceDetailScreenState();
}

class _TransportInvoiceDetailScreenState
    extends State<TransportInvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.invoice.id != null) {
        context.read<TransportPaymentProvider>().fetchTransportInvoiceById(
          widget.invoice.id!,
        );
      }
      final parentProvider = context.read<ParentProvider>();
      if (parentProvider.schoolDetails == null) {
        parentProvider.fetchSchoolDetailsForParent();
      }
    });
  }

  bool _isPayable(String? status) {
    const actionable = {'pending', 'partially_paid', 'overdue'};
    return actionable.contains(status?.toLowerCase() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransportPaymentProvider, ParentProvider>(
      builder: (context, provider, parentProvider, _) {
        final activeInvoice =
            (provider.selectedInvoice != null &&
                    provider.selectedInvoice?.id == widget.invoice.id)
                ? provider.selectedInvoice!
                : widget.invoice;

        final statusStyle = getPaymentStatusStyle(
          activeInvoice.status ?? "pending",
        );

        final routes = activeInvoice.stop?.routes ?? [];

        final schoolDetails = _getEffectiveSchoolDetails(
          parentProvider.schoolDetails,
        );
        final upiId = schoolDetails?['upi_id']?.toString().trim();
        final upiName =
            (schoolDetails?['upi_name'] ?? schoolDetails?['name'])
                ?.toString()
                .trim();
        final hasUpi = upiId != null && upiId.isNotEmpty;
        final showUpiCard = _isPayable(activeInvoice.status) && hasUpi;

        final payableAmount =
            (activeInvoice.pendingAmount != null &&
                    activeInvoice.pendingAmount! > 0)
                ? activeInvoice.pendingAmount!
                : (activeInvoice.totalAmountNum ?? 0.0);
        final formattedPayableAmount =
            payableAmount % 1 == 0
                ? payableAmount.toInt().toString()
                : payableAmount.toStringAsFixed(2);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CommonAppBar(
            title: "Transport Invoice Details",
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Hero Invoice Header Card
                      _buildHeroInvoiceCard(
                        invoice: activeInvoice,
                        statusStyle: statusStyle,
                      ),

                      // 2. School UPI Payment Card (Shown only if payable & UPI is configured)
                      if (showUpiCard) ...[
                        const SizedBox(height: 16),
                        _buildUpiPaymentCard(
                          context: context,
                          upiId: upiId,
                          upiName: upiName,
                          amount: formattedPayableAmount,
                          invoice: activeInvoice,
                        ),
                      ] else if (_isPayable(activeInvoice.status)) ...[
                        const SizedBox(height: 16),
                        _buildScreenshotNoticeBanner(
                          context: context,
                          invoice: activeInvoice,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // 3. Information Details Card
                      _buildInformationCard(
                        invoice: activeInvoice,
                        statusStyle: statusStyle,
                      ),

                      // 4. Assigned Routes Card (if routes exist)
                      if (routes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildAssignedRoutesCard(routes: routes),
                      ],

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
              _isPayable(activeInvoice.status)
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CommonButton(
                      backgroundColor: Colors.black,
                      onPressed: () {
                        final invoiceToPass =
                            activeInvoice.studentId != null
                                ? activeInvoice
                                : activeInvoice.copyWith(
                                  studentId:
                                      widget.invoice.studentId ??
                                      context
                                          .read<TransportPaymentProvider>()
                                          .currentStudentId,
                                );
                        showCreateTransportPaymentBottomSheet(
                          context: context,
                          invoice: invoiceToPass,
                        );
                      },
                      widget: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.receiptText,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Upload Receipt",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  /// 1. Hero Invoice Card: clean white with refined typography, status pill, and financial progress
  Widget _buildHeroInvoiceCard({
    required TransportInvoice invoice,
    required PaymentStatusStyle statusStyle,
  }) {
    final hasBreakdown =
        invoice.pendingAmount != null || invoice.totalAmountPaid != null;

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
          // Top Row: Term Tag + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (invoice.term != null && invoice.term!.trim().isNotEmpty)
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
                    invoice.term!,
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

          // Total Amount & Stop Name
          Text(
            "₹ ${invoice.amount ?? "0.00"}",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            invoice.stop?.stopName != null
                ? "Stop: ${invoice.stop!.stopName!}"
                : "Transport Fee",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),

          // Partial Payment Breakdown if present
          if (hasBreakdown) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                // Paid Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Paid",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${invoice.formattedTotalPaid ?? "0.00"}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 16),
                // Remaining Balance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEA580C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Remaining",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${invoice.formattedPendingAmount ?? "0.00"}",
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
            if (invoice.totalAmountNum != null &&
                invoice.totalAmountNum! > 0 &&
                invoice.totalAmountPaid != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (invoice.totalAmountPaid! / invoice.totalAmountNum!)
                      .clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 2. School UPI Payment Card
  Widget _buildUpiPaymentCard({
    required BuildContext context,
    required String upiId,
    required String? upiName,
    required String amount,
    required TransportInvoice invoice,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Icon + Title + Direct Pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AEF0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.wallet,
                  color: Color(0xFF00AEF0),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pay via UPI",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "GPay, PhonePe, Paytm, BHIM & more",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "DIRECT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Payee & UPI ID Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Payee Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.building,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Payee Name",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            upiName ?? "School Administration",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                // UPI ID with Copy
                Row(
                  children: [
                    const Icon(
                      LucideIcons.atSign,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "UPI ID",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          SelectableText(
                            upiId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _copyToClipboard(context, upiId, "UPI ID"),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00AEF0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: Color(0xFF00AEF0),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Copy",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00AEF0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Amount to Pay Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payable Amount:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                "₹ $amount",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Pay via UPI & Scan QR
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEF0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      () => _handleUpiPayment(
                        context: context,
                        upiId: upiId,
                        upiName: upiName,
                        amount: amount,
                        note:
                            "Transport Fee - ${invoice.stop?.stopName ?? 'Invoice #${invoice.id ?? ''}'}",
                      ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text(
                    "Pay with UPI",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final upiUri = _buildUpiUri(
                      upiId: upiId,
                      upiName: upiName,
                      amount: amount,
                      note:
                          "Transport Fee - ${invoice.stop?.stopName ?? 'Invoice #${invoice.id ?? ''}'}",
                    );
                    _showUpiQrDialog(
                      context: context,
                      upiUri: upiUri,
                      upiId: upiId,
                      upiName: upiName,
                      amount: amount,
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text(
                    "QR Code",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Prominent Screenshot & Receipt Upload Notice
          _buildScreenshotNoticeBanner(
            context: context,
            invoice: invoice,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotNoticeBanner({
    required BuildContext context,
    required TransportInvoice invoice,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final invoiceToPass =
            invoice.studentId != null
                ? invoice
                : invoice.copyWith(
                  studentId:
                      widget.invoice.studentId ??
                      context.read<TransportPaymentProvider>().currentStudentId,
                );
        showCreateTransportPaymentBottomSheet(
          context: context,
          invoice: invoiceToPass,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.camera,
                size: 18,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Important: Upload Payment Screenshot",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFB45309),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: "After completing your payment, take a ",
                        ),
                        TextSpan(
                          text: "screenshot of the confirmation",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF78350F),
                          ),
                        ),
                        TextSpan(
                          text: " and tap ",
                        ),
                        TextSpan(
                          text: "'Upload Receipt'",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF78350F),
                          ),
                        ),
                        TextSpan(
                          text: " below.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Information Details Card
  Widget _buildInformationCard({
    required TransportInvoice invoice,
    required PaymentStatusStyle statusStyle,
  }) {
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
            "Transport Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: LucideIcons.bus,
            title: "Stop Name",
            value: invoice.stop?.stopName ?? "N/A",
          ),
          if (invoice.term != null && invoice.term!.trim().isNotEmpty) ...[
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.calendarClock,
              title: "Term",
              value: invoice.term!,
            ),
          ],
          const _CardDivider(),
          _buildInfoRow(
            icon: LucideIcons.indianRupee,
            title: "Total Amount",
            value: "₹ ${invoice.amount ?? "0.00"}",
            valueColor: const Color(0xFF0F172A),
          ),
          if (invoice.totalAmountPaid != null) ...[
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.checkCircle2,
              title: "Amount Paid",
              value: "₹ ${invoice.formattedTotalPaid ?? "0.00"}",
              iconColor: const Color(0xFF16A34A),
              iconBgColor: const Color(0xFFDCFCE7),
              valueColor: const Color(0xFF16A34A),
            ),
          ],
          if (invoice.pendingAmount != null) ...[
            const _CardDivider(),
            _buildInfoRow(
              icon: LucideIcons.hourglass,
              title: "Remaining Balance",
              value: "₹ ${invoice.formattedPendingAmount ?? "0.00"}",
              iconColor: const Color(0xFFEA580C),
              iconBgColor: const Color(0xFFFFEDD5),
              valueColor: const Color(0xFFEA580C),
            ),
          ],
          const _CardDivider(),
          _buildInfoRow(
            icon: LucideIcons.calendar,
            title: "Due Date",
            value:
                invoice.dueDate != null
                    ? DateFormatter.formatDateTime(invoice.dueDate!)
                    : "N/A",
          ),
          const _CardDivider(),
          _buildInfoRow(
            icon: LucideIcons.info,
            title: "Payment Status",
            value: statusStyle.label,
            iconColor: statusStyle.iconColor,
            iconBgColor: statusStyle.backgroundColor,
            valueColor: statusStyle.iconColor,
          ),
        ],
      ),
    );
  }

  /// 4. Assigned Routes Card
  Widget _buildAssignedRoutesCard({required List<TransportRoute> routes}) {
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
          const Row(
            children: [
              Icon(LucideIcons.route, size: 18, color: Color(0xFF00AEF0)),
              SizedBox(width: 8),
              Text(
                "Assigned Routes",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: routes.length,
            separatorBuilder:
                (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            itemBuilder: (context, index) {
              final route = routes[index];
              final isPickup = (route.type?.toUpperCase() ?? "") == "PICKUP";

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isPickup
                              ? const Color(0xFF00AEF0).withValues(alpha: 0.1)
                              : const Color(0xFFEA580C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPickup
                          ? LucideIcons.arrowUpRight
                          : LucideIcons.arrowDownRight,
                      color:
                          isPickup
                              ? const Color(0xFF00AEF0)
                              : const Color(0xFFEA580C),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capitalizeEachWord(route.routeName ?? "Route"),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                route.type ?? "ROUTE",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            if (route.stopRoute?.priority != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                "Priority: ${route.stopRoute!.priority}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
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

  Map<String, dynamic>? _getEffectiveSchoolDetails(
    Map<String, dynamic>? details,
  ) {
    if (details == null) return null;
    if (details.containsKey('school') && details['school'] is Map) {
      return Map<String, dynamic>.from(details['school'] as Map);
    }
    return details;
  }

  Uri _buildUpiUri({
    required String upiId,
    required String? upiName,
    required String amount,
    required String? note,
    String scheme = 'upi',
    String host = 'pay',
    String path = '',
  }) {
    return Uri(
      scheme: scheme,
      host: host,
      path: path.isEmpty ? null : path,
      queryParameters: {
        'pa': upiId,
        if (upiName != null && upiName.isNotEmpty) 'pn': upiName,
        'am': amount,
        'cu': 'INR',
        if (note != null && note.isNotEmpty) 'tn': note,
      },
    );
  }

  Future<void> _handleUpiPayment({
    required BuildContext context,
    required String upiId,
    required String? upiName,
    required String amount,
    required String? note,
  }) async {
    final upiUri = _buildUpiUri(
      upiId: upiId,
      upiName: upiName,
      amount: amount,
      note: note,
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _showIosUpiAppPicker(
        context: context,
        upiUri: upiUri,
        upiId: upiId,
        upiName: upiName,
        amount: amount,
        note: note,
      );
      return;
    }

    bool launched = false;
    try {
      launched = await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: kIsWeb ? '_self' : null,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      _showUpiQrDialog(
        context: context,
        upiUri: upiUri,
        upiId: upiId,
        upiName: upiName,
        amount: amount,
      );
    }
  }

  Future<void> _launchSpecificUpiApp({
    required BuildContext context,
    required Uri appUri,
    required Uri fallbackUpiUri,
    required String upiId,
    required String? upiName,
    required String amount,
  }) async {
    bool launched = false;
    try {
      launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: kIsWeb ? '_self' : null,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      _showUpiQrDialog(
        context: context,
        upiUri: fallbackUpiUri,
        upiId: upiId,
        upiName: upiName,
        amount: amount,
      );
    }
  }

  void _showIosUpiAppPicker({
    required BuildContext context,
    required Uri upiUri,
    required String upiId,
    required String? upiName,
    required String amount,
    required String? note,
  }) {
    final apps = [
      (
        name: 'Google Pay (GPay)',
        subtitle: 'Open in Google Pay',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF1A73E8),
        bgColor: const Color(0xFFE8F0FE),
        uri: _buildUpiUri(
          upiId: upiId,
          upiName: upiName,
          amount: amount,
          note: note,
          scheme: 'tez',
          host: 'upi',
          path: '/pay',
        ),
      ),
      (
        name: 'PhonePe',
        subtitle: 'Open in PhonePe',
        icon: Icons.currency_rupee_rounded,
        color: const Color(0xFF5F259F),
        bgColor: const Color(0xFFF3E8FF),
        uri: _buildUpiUri(
          upiId: upiId,
          upiName: upiName,
          amount: amount,
          note: note,
          scheme: 'phonepe',
          host: 'pay',
        ),
      ),
      (
        name: 'Paytm',
        subtitle: 'Open in Paytm',
        icon: Icons.payments_rounded,
        color: const Color(0xFF00BAF2),
        bgColor: const Color(0xFFE0F7FA),
        uri: _buildUpiUri(
          upiId: upiId,
          upiName: upiName,
          amount: amount,
          note: note,
          scheme: 'paytmmp',
          host: 'pay',
        ),
      ),
      (
        name: 'BHIM UPI',
        subtitle: 'Open in BHIM app',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFEDD5),
        uri: _buildUpiUri(
          upiId: upiId,
          upiName: upiName,
          amount: amount,
          note: note,
          scheme: 'bhim',
          host: 'pay',
        ),
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select UPI App",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Pay ₹ $amount to ${upiName ?? upiId}",
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      icon: const Icon(Icons.close, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...apps.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _launchSpecificUpiApp(
                          context: context,
                          appUri: app.uri,
                          fallbackUpiUri: upiUri,
                          upiId: upiId,
                          upiName: upiName,
                          amount: amount,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: app.bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                app.icon,
                                color: app.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    app.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showUpiQrDialog(
                      context: context,
                      upiUri: upiUri,
                      upiId: upiId,
                      upiName: upiName,
                      amount: amount,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Color(0xFF0F172A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Scan QR Code / Copy UPI ID",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Works with any UPI app",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              "$label copied to clipboard",
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showUpiQrDialog({
    required BuildContext context,
    required Uri upiUri,
    required String upiId,
    required String? upiName,
    required String amount,
  }) {
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(upiUri.toString())}';

    showDialog(
      context: context,
      builder:
          (dialogCtx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Scan to Pay",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(dialogCtx),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Scan with GPay, PhonePe, Paytm, or any UPI app",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: qrUrl,
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          placeholder:
                              (context, url) => const SizedBox(
                                width: 180,
                                height: 180,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 180,
                                height: 180,
                                color: const Color(0xFFF8FAFC),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Failed to load QR.\nPlease pay using UPI ID below.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Amount to Pay",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            "₹ $amount",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "UPI ID",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                SelectableText(
                                  upiId,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap:
                                () =>
                                    _copyToClipboard(context, upiId, "UPI ID"),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: Color(0xFF00AEF0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            LucideIcons.camera,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Take a screenshot after paying and tap 'Upload Receipt' on the invoice screen.",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text(
                          "Done",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
