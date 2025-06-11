import 'package:acadobs/core/controller/dropdown_provider.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/widgets/common_appbar.dart';
import 'package:acadobs/core/widgets/common_button.dart';
import 'package:acadobs/core/widgets/custom_dropdown.dart';
import 'package:acadobs/core/widgets/custom_textfield.dart';
import 'package:acadobs/features/superadmin/data/models/school_subject_model.dart';
import 'package:acadobs/features/superadmin/school_subjects/controller/school_subjects_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSubjectScreen extends StatefulWidget {
  final SchoolSubject subject;
  const EditSubjectScreen({super.key, required this.subject});

  @override
  State<EditSubjectScreen> createState() => _EditSubjectScreenState();
}

class _EditSubjectScreenState extends State<EditSubjectScreen> {
  final TextEditingController _editedSubjectNameController =
      TextEditingController();
  final TextEditingController _editedSubjectDescriptionController =
      TextEditingController();
  late DropdownProvider dropdownProvider;

  @override
  void initState() {
    super.initState();
    dropdownProvider = Provider.of<DropdownProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.setSelectedItem('classRange', widget.subject.classRange);
    });
    _editedSubjectNameController.text = capitalizeEachWord(
      widget.subject.subjectName,
    );
    _editedSubjectDescriptionController.text = capitalizeEachWord(
      widget.subject.classRange,
    );
  }

  @override
  void dispose() {
    _editedSubjectNameController.dispose();
    _editedSubjectDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit Subject", isBackButton: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.height * 2),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Subject:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.edit),
                hintText: 'Enter Subject Name',
                controller: _editedSubjectNameController,
              ),
              SizedBox(height: Responsive.height * 2),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Class Range:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomDropdown(
                dropdownKey: 'classRange',
                label: "Class Range",
                icon: Icons.school,
                items: ["1-4", "5-7", "8-10", "11-12", "other"],
              ),
              SizedBox(height: Responsive.height * 4),
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.height * 4),
                child: Consumer<SchoolSubjectsController>(
                  builder: (context, value, child) {
                    return CommonButton(
                      onPressed: () {
                        final selectedClassRange = dropdownProvider
                            .getSelectedItem('classRange');
                        context.read<SchoolSubjectsController>().editSubject(
                          context,
                          subjectId: widget.subject.id,
                          subjectName: _editedSubjectNameController.text,
                          classRange: selectedClassRange,
                        );
                      },
                      widget:
                          value.isLoadingTwo
                              ? ButtonLoading()
                              : Text('Update Subject'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
