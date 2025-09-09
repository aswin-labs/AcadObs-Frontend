// import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/widgets/create_leave_request_bottomsheet.dart';

import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final int studentId;
  final bool forParent;
  const PaymentScreen({
    super.key,
    required this.studentId,
    required this.forParent,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final PaymentProvider _paymentProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _paymentProvider = context.read<PaymentProvider>();
    _paymentProvider.fetchPayments(studentId: widget.studentId);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_paymentProvider.isLoading &&
        _paymentProvider.hasMore) {
      _paymentProvider.fetchPayments(
        loadMore: true,
        studentId: widget.studentId,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 55,
                ),
                child: Column(
                  children: [
                    // Text('hello'),
                    Consumer<PaymentProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.payments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: commonShimmerList(),
                          );
                        }
                        if (provider.payments.isEmpty) {
                          return emptyScreen(
                            message: "No payments  Found",
                            heightMultiplier: 16,
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.payments.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final payment = provider.payments[index];
                            return ItemCard(
                              icon: Icons.payment,
                              title: payment.paymentType ?? "",
                              description: "₹${payment.amount}",
                              onTap: () {},
                            );
                          },
                        );
                      },
                    ),
                    Consumer<StudentLeaveRequestProvider>(
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
        onRefresh: () async {
          await context
              .read<StudentLeaveRequestProvider>()
              .fetchAllStudentLeaveRequests(studentId: widget.studentId);
        },
      ),

      floatingActionButton: CommonFloatingButton(
        onPressed:
            () => showCreateLeaveRequesBottomSheet(
              context,
              fromTeacherScreen: false,
              studentId: widget.studentId,
            ),
      ),
    );
  }
}
