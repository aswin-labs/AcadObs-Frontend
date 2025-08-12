import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddAchievementsScreen extends StatelessWidget {
  const AddAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    return Scaffold(
      appBar: CommonAppBar(title: "Add Achievements", isBackButton: true),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Achievement Details:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomTextfield(
                    iconData: Icon(LucideIcons.fileText),
                    controller: titleController,
                    hintText: 'Title',
                    label: "Title",
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomDropdown(
                    dropdownKey: 'category',
                    label: "Category",
                    icon: LucideIcons.clock,
                    items: AppConstants.achievementCategories,
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomDropdown(
                    dropdownKey: 'level',
                    label: "Level",
                    icon: LucideIcons.receipt,
                    items: AppConstants.achievementLevels,
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Text(
                    "Add Students:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 2),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
