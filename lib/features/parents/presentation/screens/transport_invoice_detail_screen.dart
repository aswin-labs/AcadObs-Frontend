import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';
import 'package:acadobs/features/parents/presentation/provider/transport_payment_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_transport_payment_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

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
    if (widget.invoice.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TransportPaymentProvider>()
            .fetchTransportInvoiceById(widget.invoice.id!);
      });
    }
  }

  bool _showFab(String? status) {
    const actionableStatuses = {'pending', 'partially_paid', 'overdue'};
    return actionableStatuses.contains(status?.toLowerCase() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransportPaymentProvider>(
      builder: (context, provider, _) {
        final activeInvoice =
            (provider.selectedInvoice != null &&
                    provider.selectedInvoice?.id == widget.invoice.id)
                ? provider.selectedInvoice!
                : widget.invoice;

        final statusStyle = getPaymentStatusStyle(
          activeInvoice.status ?? "pending",
        );

        final routes = activeInvoice.stop?.routes ?? [];

        return Scaffold(
          appBar: const CommonAppBar(
            title: "Transport Invoice Details",
            isBackButton: true,
          ),
          body: SingleChildScrollView(
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
                        "₹ ${activeInvoice.amount ?? "0.00"}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activeInvoice.stop?.stopName != null
                            ? "Stop: ${activeInvoice.stop!.stopName!}"
                            : "Transport Fee",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (activeInvoice.term != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          activeInvoice.term!,
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
                          color: Colors.white.withValues(alpha: 0.85),
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
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Invoice Information Card
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
                        icon: LucideIcons.bus,
                        title: "Stop Name",
                        value: activeInvoice.stop?.stopName ?? "N/A",
                        statusStyle: statusStyle,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.calendarClock,
                        title: "Term",
                        value: activeInvoice.term ?? "N/A",
                        statusStyle: statusStyle,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.indianRupee,
                        title: "Total Amount",
                        value: "₹${activeInvoice.amount ?? "0.00"}",
                        statusStyle: statusStyle,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.calendar,
                        title: "Due Date",
                        value: activeInvoice.dueDate != null
                            ? DateFormatter.formatDateTime(activeInvoice.dueDate!)
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

                // Assigned Routes Card (if routes exist from single invoice detail API)
                if (routes.isNotEmpty) ...[
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.route,
                              size: 20,
                              color: Color(0xFF00AEF0),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Assigned Routes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: routes.length,
                          separatorBuilder: (_, __) =>
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1),
                              ),
                          itemBuilder: (context, index) {
                            final route = routes[index];
                            final isPickup =
                                (route.type?.toUpperCase() ?? "") == "PICKUP";

                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isPickup
                                            ? Colors.blue
                                            : Colors.orange)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isPickup
                                        ? LucideIcons.arrowUpRight
                                        : LucideIcons.arrowDownRight,
                                    color: isPickup
                                        ? Colors.blue.shade700
                                        : Colors.orange.shade800,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capitalizeEachWord(
                                          route.routeName ?? "Route",
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
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
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              route.type ?? "ROUTE",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          if (route.stopRoute?.priority != null) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              "Priority: ${route.stopRoute!.priority}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
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
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _showFab(activeInvoice.status)
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: CommonButton(
                    onPressed: () {
                      final invoiceToPass = activeInvoice.studentId != null
                          ? activeInvoice
                          : activeInvoice.copyWith(
                              studentId: widget.invoice.studentId ??
                                  context.read<TransportPaymentProvider>().currentStudentId,
                            );
                      showCreateTransportPaymentBottomSheet(
                        context: context,
                        invoice: invoiceToPass,
                      );
                    },
                    widget: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.uploadCloud, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Upload File",
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required PaymentStatusStyle statusStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusStyle.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: statusStyle.iconColor,
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
              const SizedBox(height: 4),
              Text(
                value,
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
