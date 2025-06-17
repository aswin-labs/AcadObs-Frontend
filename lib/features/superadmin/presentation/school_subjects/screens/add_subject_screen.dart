import 'package:acadobs/presentation/providers/dropdown_provider.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/presentation/widgets/common_appbar.dart';
import 'package:acadobs/presentation/widgets/common_button.dart';
import 'package:acadobs/presentation/widgets/custom_dropdown.dart';
import 'package:acadobs/presentation/widgets/custom_textfield.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/controller/school_subjects_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _subjectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DropdownProvider>().clearSelectedItem('classRange');
    });
  }

  @override
  void dispose() {
    _subjectNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Add Subject", isBackButton: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.title),
                  label: "Subject Name*",
                  controller: _subjectNameController,
                  validator:
                      (value) => FormValidator.validateNotEmpty(
                        value,
                        fieldName: "Name",
                      ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomDropdown(
                  dropdownKey: 'classRange',
                  label: "Class Range",
                  icon: Icons.school,
                  items: ["1-4", "5-7", "8-10", "11-12", "other"],
                ),
        
                SizedBox(height: Responsive.height * 2),
                // Add button
                Padding(
                  padding: EdgeInsets.only(bottom: Responsive.height * 4),
                  child: Consumer<SchoolSubjectsController>(
                    builder: (context, superAdminController, child) {
                      return CommonButton(
                        onPressed: () {
                          final classRange = context
                              .read<DropdownProvider>()
                              .getSelectedItem('classRange');
                          if (_formKey.currentState?.validate() ?? false) {
                            context
                                .read<SchoolSubjectsController>()
                                .addNewSubject(
                                  context,
                                  subjectName: _subjectNameController.text,
                                  classRange: classRange,
                                );
                          }
                        },
                        widget:
                            superAdminController.isLoadingTwo
                                ? ButtonLoading()
                                : Text('Add'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
