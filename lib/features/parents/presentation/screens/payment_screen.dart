import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
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
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PaymentProvider _paymentProvider;

  final ScrollController _invoiceScrollController = ScrollController();
  final ScrollController _paymentScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _paymentProvider = context.read<PaymentProvider>();

    _tabController = TabController(length: 2, vsync: this);

    _paymentProvider.fetchInvoices(
      studentId: widget.studentId,
      forceRefresh: true,
    );
    _paymentProvider.fetchPayments(
      studentId: widget.studentId,
      forceRefresh: true,
    );

    _invoiceScrollController.addListener(_invoiceScrollListener);
    _paymentScrollController.addListener(_paymentScrollListener);
  }

  void _invoiceScrollListener() {
    final isNearBottom =
        _invoiceScrollController.position.pixels >=
        _invoiceScrollController.position.maxScrollExtent - 200;

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
    final isNearBottom =
        _paymentScrollController.position.pixels >=
        _paymentScrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_paymentProvider.isLoadingForPayments &&
        _paymentProvider.hasMore) {
      _paymentProvider.fetchPayments(
        loadMore: true,
        studentId: widget.studentId,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invoiceScrollController.dispose();
    _paymentScrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Payments & Invoices", isBackButton: true),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 211, 206, 206),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent, // Removes the black line
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: const [Tab(text: "Invoices"), Tab(text: "Payments")],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                children: [
                  Consumer<PaymentProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingForInvoice &&
                          provider.invoices.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
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

                          final statusStyle = getPaymentStatusStyle(
                            invoice.status ?? "",
                          );

                          return ItemCard(
                            icon: Icons.receipt_long,
                            title: invoice.invoice?.title ?? "",
                            description: "₹${invoice.invoice?.amount ?? ""}",
                            status: statusStyle.label,
                            backgroundColor: statusStyle.backgroundColor,
                            iconColor: statusStyle.iconColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                children: [
                  Consumer<PaymentProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingForPayments && provider.payments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
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

                          final statusStyle = getPaymentStatusStyle(
                            payment.paymentStatus ?? "",
                          );

                          return ItemCard(
                            icon: Icons.payment,
                            title: payment.paymentType ?? "",
                            description: "₹${payment.amount}",
                            status: statusStyle.label,
                            backgroundColor: statusStyle.backgroundColor,
                            iconColor: statusStyle.iconColor,
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
