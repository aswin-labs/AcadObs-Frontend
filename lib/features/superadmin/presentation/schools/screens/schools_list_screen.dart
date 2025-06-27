import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media/media_end_points.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
import 'package:acadobs/shared/widgets/custom_tile_widget.dart';
import 'package:acadobs/features/superadmin/presentation/schools/provider/school_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SchoolsListScreen extends StatefulWidget {
  const SchoolsListScreen({super.key});

  @override
  State<SchoolsListScreen> createState() => _SchoolsListScreenState();
}

class _SchoolsListScreenState extends State<SchoolsListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schoolController = Provider.of<SchoolProvider>(
        context,
        listen: false,
      );
      schoolController.getAllSchools();
    });
  }

  void _scrollListener() {
    final schoolController = Provider.of<SchoolProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      schoolController.getAllSchools(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolProvider>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: CommonAppBar(title: 'Schools List'),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CustomButtonContainer(
                  color: Colors.black,
                  isCenterText: true,
                  text: 'Add School',
                  icon: Icons.add,
                  ontap: () {
                    context.pushNamed(RouteConstants.addSchool, extra: false);
                  },
                ),
                const SizedBox(height: 16),
                if (controller.isLoading)
                  Expanded(child: commonShimmerList(height: 80))
                else if (controller.schools.isEmpty)
                  Expanded(child: emptyScreen(message: "No Schools Found"))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          controller.schools.length +
                          (controller.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < controller.schools.length) {
                          final school = controller.schools[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: CustomTileWidget(
                              isImageIcon: true,
                              imageUrl:
                                  BaseUrls.media +
                                  MediaEndpoints.schoolLogos +
                                  school.logo.toString(),
                              name: school.name,
                              subtitle: school.email,
                              onTap: () {},
                              onDelete:
                                  () => showConfirmationDialog(
                                    context: context,
                                    title: "Delete School?",
                                    content:
                                        "Are you sure you want to delete this school?",
                                    onConfirm: () {
                                      controller.deleteSchool(
                                        context,
                                        schoolId: school.id,
                                      );
                                    },
                                  ),
                              onEdit:
                                  () => context.pushNamed(
                                    RouteConstants.editSchool,
                                    extra: school,
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
