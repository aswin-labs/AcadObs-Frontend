import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/transport_payment_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UnpaidInvoicesTickerSection extends StatelessWidget {
  const UnpaidInvoicesTickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PaymentProvider, TransportPaymentProvider>(
      builder: (context, paymentProvider, transportProvider, _) {
        final unpaidSchoolInvoices = paymentProvider.unpaidInvoices;
        final unpaidTransportInvoices =
            transportProvider.unpaidTransportInvoices;

        final hasSchoolInvoices = unpaidSchoolInvoices.isNotEmpty;
        final hasTransportInvoices = unpaidTransportInvoices.isNotEmpty;

        if (!hasSchoolInvoices && !hasTransportInvoices) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unpaid School Fees Ticker
              if (hasSchoolInvoices) ...[
                _buildSchoolInvoicesTicker(
                  context,
                  paymentProvider,
                  unpaidSchoolInvoices,
                ),
              ],

              // Spacing if both are present
              if (hasSchoolInvoices && hasTransportInvoices) ...[
                const SizedBox(height: 8),
              ],

              // Unpaid Transport Invoices Ticker
              if (hasTransportInvoices) ...[
                _buildTransportInvoicesTicker(
                  context,
                  transportProvider,
                  unpaidTransportInvoices,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// School Fee Dues Ticker Bar
  Widget _buildSchoolInvoicesTicker(
    BuildContext context,
    PaymentProvider provider,
    List<InvoiceStudent> invoices,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDBA74).withAlpha(180),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              // Left fixed badge
              InkWell(
                onTap: () {
                  if (invoices.isNotEmpty) {
                    context.pushNamed(
                      RouteConstants.invoiceDetailScreen,
                      extra: invoices.first,
                    );
                  }
                },
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.bell_fill,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "FEES (${provider.unpaidInvoicesCount})",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Subtle vertical divider line
              Container(
                width: 1,
                height: double.infinity,
                color: const Color(0xFFFDBA74).withAlpha(120),
              ),

              // Right moving text marquee track
              Expanded(
                child: _MarqueeSchoolInvoiceTrack(
                  invoices: invoices,
                  onInvoiceTap: (invoice) {
                    context.pushNamed(
                      RouteConstants.invoiceDetailScreen,
                      extra: invoice,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Transport Fee Dues Ticker Bar
  Widget _buildTransportInvoicesTicker(
    BuildContext context,
    TransportPaymentProvider provider,
    List<TransportInvoice> invoices,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F9FF), Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0284C7).withAlpha(140),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withAlpha(16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              // Left fixed transport badge
              InkWell(
                onTap: () {
                  if (invoices.isNotEmpty) {
                    context.pushNamed(
                      RouteConstants.transportInvoiceDetailScreen,
                      extra: invoices.first,
                    );
                  }
                },
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF00AEF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.bus,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "TRANSPORT (${provider.unpaidTransportInvoicesCount})",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Subtle vertical divider line
              Container(
                width: 1,
                height: double.infinity,
                color: const Color(0xFF7DD3FC).withAlpha(120),
              ),

              // Right moving text marquee track
              Expanded(
                child: _MarqueeTransportInvoiceTrack(
                  invoices: invoices,
                  onInvoiceTap: (invoice) {
                    context.pushNamed(
                      RouteConstants.transportInvoiceDetailScreen,
                      extra: invoice,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marquee track for School Invoices
class _MarqueeSchoolInvoiceTrack extends StatefulWidget {
  final List<InvoiceStudent> invoices;
  final ValueChanged<InvoiceStudent> onInvoiceTap;

  const _MarqueeSchoolInvoiceTrack({
    required this.invoices,
    required this.onInvoiceTap,
  });

  @override
  State<_MarqueeSchoolInvoiceTrack> createState() =>
      _MarqueeSchoolInvoiceTrackState();
}

class _MarqueeSchoolInvoiceTrackState extends State<_MarqueeSchoolInvoiceTrack>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  AnimationController? _animController;
  bool _isUserHolding = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimation();
    });
  }

  void _initializeAnimation() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    _animController?.dispose();

    // Comfortable reading speed (~26-28 pixels per second) so parents can easily read invoices
    final durationSeconds = (maxExtent / 26.0).clamp(8.0, 600.0);

    _animController =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: (durationSeconds * 1000).toInt()),
          )
          ..addListener(_onTick)
          ..repeat();
  }

  void _onTick() {
    if (_isUserHolding || !mounted || !_scrollController.hasClients) return;
    if (_animController == null) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    _scrollController.jumpTo(_animController!.value * maxExtent);
  }

  @override
  void didUpdateWidget(covariant _MarqueeSchoolInvoiceTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoices.length != widget.invoices.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAnimation();
      });
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('d MMM').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = [
      ...widget.invoices,
      ...widget.invoices,
      ...widget.invoices,
    ];

    return Listener(
      onPointerDown: (_) {
        if (!_isUserHolding) {
          setState(() {
            _isUserHolding = true;
          });
        }
      },
      onPointerUp: (_) {
        if (_isUserHolding) {
          setState(() {
            _isUserHolding = false;
          });
        }
      },
      onPointerCancel: (_) {
        if (_isUserHolding) {
          setState(() {
            _isUserHolding = false;
          });
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const SizedBox(width: 8),
            ...displayItems.map((invoice) {
              final studentName = invoice.student?.fullName ?? 'Student';
              final title =
                  invoice.invoice?.title?.trim().isNotEmpty == true
                      ? invoice.invoice!.title!.trim()
                      : 'Fee';
              final rawAmount = invoice.invoice?.amount ?? '0';
              final formattedAmount =
                  rawAmount.startsWith('₹') ? rawAmount : '₹$rawAmount';
              final dueDateStr = _formatDueDate(invoice.invoice?.dueDate);

              final isOverdue =
                  invoice.status?.toLowerCase() == 'overdue' ||
                  (invoice.invoice?.dueDate != null &&
                      invoice.invoice!.dueDate!.isBefore(DateTime.now()));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onInvoiceTap(invoice),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(210),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFED7AA),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedAmount,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                          if (dueDateStr.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              isOverdue
                                  ? "Overdue $dueDateStr"
                                  : "Due $dueDateStr",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    isOverdue
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFFC2410C),
                              ),
                            ),
                          ],
                          const SizedBox(width: 5),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 11,
                            color: Color(0xFFEA580C),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/// Marquee track for Transport Invoices
class _MarqueeTransportInvoiceTrack extends StatefulWidget {
  final List<TransportInvoice> invoices;
  final ValueChanged<TransportInvoice> onInvoiceTap;

  const _MarqueeTransportInvoiceTrack({
    required this.invoices,
    required this.onInvoiceTap,
  });

  @override
  State<_MarqueeTransportInvoiceTrack> createState() =>
      _MarqueeTransportInvoiceTrackState();
}

class _MarqueeTransportInvoiceTrackState
    extends State<_MarqueeTransportInvoiceTrack>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  AnimationController? _animController;
  bool _isUserHolding = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimation();
    });
  }

  void _initializeAnimation() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    _animController?.dispose();

    // Smooth readable speed (~30 pixels per second)
    final durationSeconds = (maxExtent / 30.0).clamp(8.0, 600.0);

    _animController =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: (durationSeconds * 1000).toInt()),
          )
          ..addListener(_onTick)
          ..repeat();
  }

  void _onTick() {
    if (_isUserHolding || !mounted || !_scrollController.hasClients) return;
    if (_animController == null) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    _scrollController.jumpTo(_animController!.value * maxExtent);
  }

  @override
  void didUpdateWidget(covariant _MarqueeTransportInvoiceTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoices.length != widget.invoices.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAnimation();
      });
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('d MMM').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = [
      ...widget.invoices,
      ...widget.invoices,
      ...widget.invoices,
    ];

    return Listener(
      onPointerDown: (_) {
        if (!_isUserHolding) {
          setState(() {
            _isUserHolding = true;
          });
        }
      },
      onPointerUp: (_) {
        if (_isUserHolding) {
          setState(() {
            _isUserHolding = false;
          });
        }
      },
      onPointerCancel: (_) {
        if (_isUserHolding) {
          setState(() {
            _isUserHolding = false;
          });
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const SizedBox(width: 8),
            ...displayItems.map((invoice) {
              final studentName = invoice.student?.fullName ?? 'Student';
              final termStr =
                  invoice.term?.trim().isNotEmpty == true
                      ? invoice.term!.trim()
                      : 'Bus Fee';
              final rawAmount = invoice.amount ?? '0';
              final formattedAmount =
                  rawAmount.startsWith('₹') ? rawAmount : '₹$rawAmount';
              final dueDateStr = _formatDueDate(invoice.dueDate);

              final isOverdue =
                  invoice.status?.toLowerCase() == 'overdue' ||
                  (invoice.dueDate != null &&
                      invoice.dueDate!.isBefore(DateTime.now()));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onInvoiceTap(invoice),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(210),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFBAE6FD),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            termStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedAmount,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          if (dueDateStr.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              isOverdue
                                  ? "Overdue $dueDateStr"
                                  : "Due $dueDateStr",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    isOverdue
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                          const SizedBox(width: 5),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 11,
                            color: Color(0xFF0284C7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
