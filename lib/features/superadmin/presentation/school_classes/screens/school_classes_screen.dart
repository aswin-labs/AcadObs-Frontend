import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/provider/school_classes_provider.dart';
import 'package:acadobs/presentation/widgets/common_appbar.dart';
import 'package:acadobs/presentation/widgets/custom_button_container.dart';
import 'package:acadobs/presentation/widgets/custom_tile_widget.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SchoolClassesScreen extends StatefulWidget {
  const SchoolClassesScreen({super.key});

  @override
  State<SchoolClassesScreen> createState() => _SchoolClassesScreenState();
}

class _SchoolClassesScreenState extends State<SchoolClassesScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schoolClassController = Provider.of<SchoolClassProvider>(
        context,
        listen: false,
      );
      schoolClassController.getAllSchoolClasses();
    });
  }

  void _scrollListener() {
    final schoolClassController = Provider.of<SchoolClassProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      schoolClassController.getAllSchoolClasses(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolClassProvider>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: CommonAppBar(title: 'Classes List'),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CustomButtonContainer(
                  color: Colors.black,
                  isCenterText: true,
                  text: 'Add Class',
                  icon: Icons.add,
                  ontap: () {
                    context.pushNamed(RouteConstants.addClass);
                  },
                ),
                const SizedBox(height: 16),
                if (controller.isLoading)
                  Expanded(child: commonShimmerList(height: 80))
                else if (controller.schoolClasses.isEmpty)
                  Expanded(child: emptyScreen(message: "No Classes Found"))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          controller.schoolClasses.length +
                          (controller.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < controller.schoolClasses.length) {
                          final schoolClass = controller.schoolClasses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: CustomTileWidget(
                              name: schoolClass.classname,
                              subtitle: "",
                              onTap: () {
                                // Handle tile tap if needed
                              },
                              onEdit:
                                  () => context.pushNamed(
                                    RouteConstants.editClass,
                                    extra: schoolClass,
                                  ),
                              onDelete:
                                  () => showConfirmationDialog(
                                    context: context,
                                    title: 'Delete Class',
                                    content:
                                        'Are you sure you want to delete this class?',
                                    onConfirm: () {
                                      controller.deleteClass(
                                        context,
                                        classId: schoolClass.id,
                                      );
                                    },
                                  ),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
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
