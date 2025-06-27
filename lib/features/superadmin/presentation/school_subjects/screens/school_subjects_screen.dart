import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
import 'package:acadobs/shared/widgets/custom_tile_widget.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/provider/school_subjects_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SchoolSubjectsScreen extends StatefulWidget {
  const SchoolSubjectsScreen({super.key});

  @override
  State<SchoolSubjectsScreen> createState() => _SchoolSubjectsScreenState();
}

class _SchoolSubjectsScreenState extends State<SchoolSubjectsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schoolSubjectsController = Provider.of<SchoolSubjectsProvider>(
        context,
        listen: false,
      );
      schoolSubjectsController.getAllSchoolSubjects();
    });
  }

  void _scrollListener() {
    final schoolSubjectsController = Provider.of<SchoolSubjectsProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      schoolSubjectsController.getAllSchoolSubjects(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolSubjectsProvider>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: CommonAppBar(title: 'Subjects List'),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CustomButtonContainer(
                  color: Colors.black,
                  isCenterText: true,
                  text: 'Add Subject',
                  icon: Icons.add,
                  ontap: () {
                    context.pushNamed(RouteConstants.addSubject);
                  },
                ),
                const SizedBox(height: 16),
                if (controller.isLoading)
                  Expanded(child: commonShimmerList(height: 80))
                else if (controller.schoolSubjects.isEmpty)
                  Expanded(child: emptyScreen(message: "No Subjects Found"))
                else
                  Expanded(
                    child:
                        ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemCount:
                                  controller.schoolSubjects.length +
                                  (controller.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < controller.schoolSubjects.length) {
                                  final schoolSubject =
                                      controller.schoolSubjects[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: CustomTileWidget(
                                      name: schoolSubject.subjectName,
                                      subtitle: schoolSubject.classRange,
                                      onTap: () {
                                        // Handle tile tap
                                      },
                                      onEdit:
                                          () => context.pushNamed(
                                            RouteConstants.editSubject,
                                            extra: schoolSubject,
                                          ),
                                      onDelete:
                                          () => showConfirmationDialog(
                                            context: context,
                                            title: 'Delete Subject',
                                            content:
                                                'Are you sure you want to delete this subject?',
                                            onConfirm: () {
                                              controller.deleteSubject(
                                                context,
                                                subjectId: schoolSubject.id,
                                              );
                                            },
                                          ),
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              },
                            ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
