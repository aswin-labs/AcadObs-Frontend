import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeworkHomeScreen extends StatefulWidget {
  const HomeworkHomeScreen({super.key});

  @override
  State<HomeworkHomeScreen> createState() => _HomeworkHomeScreenState();
}

class _HomeworkHomeScreenState extends State<HomeworkHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Homeworks", isBackButton: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(children: []),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(LucideIcons.plus, weight: 1, color: Colors.grey),
        ),
      ),
    );
  }
}
