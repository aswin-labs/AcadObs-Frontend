import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/achievements/models/achievement_model.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementEditScreen extends StatefulWidget {
  final AchievementModel achievement;
  const AchievementEditScreen({super.key, required this.achievement});

  @override
  State<AchievementEditScreen> createState() => _AchievementEditScreenState();
}

class _AchievementEditScreenState extends State<AchievementEditScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.achievement.title);
    descriptionController = TextEditingController(
      text: widget.achievement.description,
    );
    // dateController.text = DateFormat(
    //   'yyyy-MM-dd',
    // ).format(widget.homework.dueDate ?? DateTime.now());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void buttonAction(BuildContext context) {
    context.read<AchievementProvider>().editAchievement(
      context: context,
      title: titleController.text,
      description: descriptionController.text,
      achievementId: widget.achievement.id ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacer = SizedBox(height: Responsive.height * 2);

    return Scaffold(
      appBar: CommonAppBar(title: 'Edit achievement', isBackButton: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Details:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  spacer,

                  CustomTextfield(
                    label: "title",
                    iconData: Icon(Icons.title),
                    controller: titleController,
                    validator: FormValidator.validateNotEmpty,
                  ),
                  spacer,
                  CustomTextfield(
                    label: 'description',
                    iconData: Icon(Icons.description),
                    controller: descriptionController,
                    validator: FormValidator.validateNotEmpty,
                  ),
                  spacer,
                  SizedBox(
                    height: Responsive.height * 6,
                    width: Responsive.width * 35,
                    child: Consumer<AchievementProvider>(
                      builder: (context, provier, _) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(2),
                          ),
                          onPressed: () {
                            buttonAction(context);
                          },
                          child:
                              context.watch<AchievementProvider>().isLoadingSecondary
                                  ? ButtonLoading()
                                  : Text("Save"),
                        );
                      },
                    ),
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
