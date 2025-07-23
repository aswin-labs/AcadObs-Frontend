import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/homework/homework_model.dart';
import 'package:acadobs/features/teacher/presentation/homework/provider/homework_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_detail_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeworkDetailsScreen extends StatefulWidget {
  final HomeworkModel homework;
  const HomeworkDetailsScreen({super.key, required this.homework});

  @override
  State<HomeworkDetailsScreen> createState() => _HomeworkDetailsScreenState();
}

class _HomeworkDetailsScreenState extends State<HomeworkDetailsScreen> {
  late HomeworkProvider homeworkProvider;
  @override
  void initState() {
    homeworkProvider = context.read<HomeworkProvider>();
    homeworkProvider.fetchSingleHomework(homeworkId: widget.homework.id ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Homework", isBackButton: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemDetailScreenContainer(
                    iconColor: Color(0xFFB14F6F),
                    backgroundColor: Color(0xFFFFCEDE),
                    icon: LucideIcons.clipboardList,
                  ),
                  SizedBox(height: Responsive.height * 3),
                  Text(
                    capitalizeEachWord(widget.homework.title ?? ""),
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Text(
                    widget.homework.description ?? "",
                    style: context.textTheme.bodySmall!.copyWith(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Text(
                    "Due: ${DateFormatter.formatDateString(widget.homework.dueDate.toString())}",

                    style: context.textTheme.bodySmall!.copyWith(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 3),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: Responsive.radius * 6,
                          backgroundColor: const Color(0xffF4F4F4),
                          child: const Icon(
                            Icons.fact_check_outlined,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: Responsive.width * 20),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.homeworkRankingScreen,
                            );
                          },
                          child: Text(
                            'Mark Homework',
                            style: context.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.height * 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
