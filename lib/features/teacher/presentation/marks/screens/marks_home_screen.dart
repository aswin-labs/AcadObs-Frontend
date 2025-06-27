import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';

class MarksHomeScreen extends StatefulWidget {
  const MarksHomeScreen({super.key});

  @override
  State<MarksHomeScreen> createState() => _MarksHomeScreenState();
}

class _MarksHomeScreenState extends State<MarksHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Marks"),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: context.paddingHorizontal,
            sliver: SliverToBoxAdapter(
              child: SizedBox(height: Responsive.height * 2),
            ),
          ),

          SliverPadding(
            padding: context.paddingHorizontal,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ItemCard(
                  title: "title",
                  description: "description",
                  onTap: () {},
                ),
                childCount: 2,
              ),
            ),
          ),

          SliverPadding(
            padding: context.paddingHorizontal,
            sliver: SliverToBoxAdapter(
              child: SizedBox(height: Responsive.height * 4),
            ),
          ),
        ],
      ),
    );
  }
}