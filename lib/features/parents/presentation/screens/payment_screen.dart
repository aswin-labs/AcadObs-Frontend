import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/transport_payment_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/payment_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final int studentId;
  const PaymentScreen({super.key, required this.studentId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  late final PaymentProvider _paymentProvider;
  late final TransportPaymentProvider _transportProvider;
  int _tabCount = 2;
  bool _isInitialLoading = true;

  final ScrollController _invoiceScrollController = ScrollController();
  final ScrollController _paymentScrollController = ScrollController();
  final ScrollController _transportScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _paymentProvider = context.read<PaymentProvider>();
    _transportProvider = context.read<TransportPaymentProvider>();

    _invoiceScrollController.addListener(_invoiceScrollListener);
    _paymentScrollController.addListener(_paymentScrollListener);
    _transportScrollController.addListener(_transportScrollListener);

    _transportProvider.addListener(_onTransportProviderChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await Future.wait([
          _paymentProvider.fetchInvoices(
            studentId: widget.studentId,
            forceRefresh: true,
          ),
          _paymentProvider.fetchPayments(
            studentId: widget.studentId,
            forceRefresh: true,
          ),
          _transportProvider.fetchTransportInvoices(
            studentId: widget.studentId,
            forceRefresh: true,
          ),
        ]);
      } catch (e) {
        log("Error during initial payment screen fetch: $e");
      } finally {
        if (mounted) {
          final hasTransport = _transportProvider.isAvailable;
          setState(() {
            _tabCount = hasTransport ? 3 : 2;
            _tabController = TabController(length: _tabCount, vsync: this);
            _isInitialLoading = false;
          });
        }
      }
    });
  }

  void _onTransportProviderChanged() {
    if (_isInitialLoading) return;
    final newCount = _transportProvider.isAvailable ? 3 : 2;
    if (_tabCount != newCount && mounted) {
      setState(() {
        final oldIndex = _tabController?.index ?? 0;
        _tabController?.dispose();
        _tabCount = newCount;
        _tabController = TabController(
          length: _tabCount,
          vsync: this,
          initialIndex: oldIndex < _tabCount ? oldIndex : 0,
        );
      });
    }
  }

  void _invoiceScrollListener() {
    if (!_invoiceScrollController.hasClients) return;
    final position = _invoiceScrollController.position;
    if (position.maxScrollExtent <= 0) return;

    final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_paymentProvider.isLoadingForInvoice &&
        _paymentProvider.hasMoreInvoice) {
      _paymentProvider.fetchInvoices(
        loadMore: true,
        studentId: widget.studentId,
      );
    }
  }

  void _paymentScrollListener() {
    if (!_paymentScrollController.hasClients) return;
    final position = _paymentScrollController.position;
    if (position.maxScrollExtent <= 0) return;

    final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_paymentProvider.isLoadingForPayments &&
        _paymentProvider.hasMore) {
      _paymentProvider.fetchPayments(
        loadMore: true,
        studentId: widget.studentId,
      );
    }
  }

  void _transportScrollListener() {
    if (!_transportScrollController.hasClients) return;
    final position = _transportScrollController.position;
    if (position.maxScrollExtent <= 0) return;

    final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_transportProvider.isLoading &&
        _transportProvider.hasMore) {
      _transportProvider.fetchTransportInvoices(
        loadMore: true,
        studentId: widget.studentId,
      );
    }
  }

  @override
  void dispose() {
    _transportProvider.removeListener(_onTransportProviderChanged);
    _tabController?.dispose();
    _invoiceScrollController.dispose();
    _paymentScrollController.dispose();
    _transportScrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshInvoices() async {
    await context.read<PaymentProvider>().fetchInvoices(
      studentId: widget.studentId,
      forceRefresh: true,
    );
  }

  Future<void> _refreshPayments() async {
    await context.read<PaymentProvider>().fetchPayments(
      studentId: widget.studentId,
      forceRefresh: true,
    );
  }

  Future<void> _refreshTransportInvoices() async {
    await context.read<TransportPaymentProvider>().fetchTransportInvoices(
      studentId: widget.studentId,
      forceRefresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading || _tabController == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const CommonAppBar(
          title: "Payments & Invoices",
          isBackButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: commonShimmerList(),
              ),
            ],
          ),
        ),
      );
    }

    final hasTransport = _tabCount == 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonAppBar(
        title: "Payments & Invoices",
        isBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withAlpha(60),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  letterSpacing: 0.1,
                ),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  const Tab(text: "Invoices"),
                  if (hasTransport) const Tab(text: "Transport"),
                  const Tab(text: "Payments"),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _InvoiceTab(
                  studentId: widget.studentId,
                  scrollController: _invoiceScrollController,
                  onRefresh: _refreshInvoices,
                ),

                if (hasTransport)
                  _TransportInvoiceTab(
                    studentId: widget.studentId,
                    scrollController: _transportScrollController,
                    onRefresh: _refreshTransportInvoices,
                  ),
                _PaymentTab(
                  studentId: widget.studentId,
                  scrollController: _paymentScrollController,
                  onRefresh: _refreshPayments,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceTab extends StatelessWidget {
  final int studentId;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _InvoiceTab({
    required this.studentId,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                children: [
                  Consumer<PaymentProvider>(
                    builder: (context, provider, _) {
                      if ((provider.isLoadingForInvoice ||
                              !provider.isFetchedInvoiceOnce) &&
                          provider.invoices.isEmpty) {
                        return commonShimmerList();
                      }

                      if (provider.invoices.isEmpty) {
                        return emptyScreen(
                          message: "No invoices found",
                          heightMultiplier: 16,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = provider.invoices[index];

                          return PaymentCard.invoice(
                            invoice: invoice,
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.invoiceDetailScreen,
                                extra: invoice,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  Consumer<PaymentProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoadingForInvoice &&
                              provider.hasMoreInvoice
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTab extends StatelessWidget {
  final int studentId;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _PaymentTab({
    required this.studentId,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                children: [
                  Consumer<PaymentProvider>(
                    builder: (context, provider, _) {
                      if ((provider.isLoadingForPayments ||
                              !provider.isFetchedOnce) &&
                          provider.payments.isEmpty) {
                        return commonShimmerList();
                      }

                      if (provider.payments.isEmpty) {
                        return emptyScreen(
                          message: "No payments found",
                          heightMultiplier: 16,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.payments.length,
                        itemBuilder: (context, index) {
                          final payment = provider.payments[index];

                          return PaymentCard.payment(
                            payment: payment,
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.paymentDetailScreen,
                                extra: payment,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  Consumer<PaymentProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoadingForPayments && provider.hasMore
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportInvoiceTab extends StatelessWidget {
  final int studentId;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _TransportInvoiceTab({
    required this.studentId,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                children: [
                  Consumer<TransportPaymentProvider>(
                    builder: (context, provider, _) {
                      if ((provider.isLoading || !provider.isFetchedOnce) &&
                          provider.transportInvoices.isEmpty) {
                        return commonShimmerList();
                      }

                      if (provider.transportInvoices.isEmpty) {
                        return emptyScreen(
                          message: "No transport invoices found",
                          heightMultiplier: 16,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.transportInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = provider.transportInvoices[index];

                          return PaymentCard.transport(
                            invoice: invoice,
                            onTap: () {
                              final invoiceWithStudent =
                                  invoice.studentId != null
                                      ? invoice
                                      : invoice.copyWith(studentId: studentId);
                              context.pushNamed(
                                RouteConstants.transportInvoiceDetailScreen,
                                extra: invoiceWithStudent,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  Consumer<TransportPaymentProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoading && provider.hasMore
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
