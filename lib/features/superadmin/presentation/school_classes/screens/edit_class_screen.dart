import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/superadmin/data/models/classes_model.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/provider/school_classes_provider.dart';
import 'package:acadobs/presentation/providers/dropdown_provider.dart';
import 'package:acadobs/presentation/widgets/common_appbar.dart';
import 'package:acadobs/presentation/widgets/common_button.dart';
import 'package:acadobs/presentation/widgets/custom_dropdown.dart';
import 'package:acadobs/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditClassScreen extends StatefulWidget {
  final SchoolClass schoolClass;
  const EditClassScreen({super.key, required this.schoolClass});

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final TextEditingController _editedStdController = TextEditingController();
  final TextEditingController _editedClassNameController =
      TextEditingController();
  late DropdownProvider dropdownProvider;

  @override
  void initState() {
    super.initState();
    dropdownProvider = Provider.of<DropdownProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.setSelectedItem(
        'division',
        widget.schoolClass.division ?? "",
      );
    });

    _editedStdController.text = widget.schoolClass.year.toString();
    _editedClassNameController.text = capitalizeEachWord(
      widget.schoolClass.classname,
    );
  }

  @override
  void dispose() {
    _editedStdController.dispose();
    _editedClassNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit Class", isBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.height * 2),

              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Standard:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.calendar_today),
                hintText: 'Enter Std',
                controller: _editedStdController,
              ),
              SizedBox(height: Responsive.height * 2),

              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Division:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomDropdown(
                dropdownKey: 'division',
                label: "Division",
                icon: Icons.school,
                items: ["A", "B", "C", "D", "E"],
              ),
              SizedBox(height: Responsive.height * 2),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Class Name:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.class_),
                hintText: 'Enter Class Name',
                controller: _editedClassNameController,
              ),
              SizedBox(height: Responsive.height * 2),
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.height * 4),
                child: Consumer<SchoolClassProvider>(
                  builder: (context, controller, child) {
                    return CommonButton(
                      onPressed: () {
                        final selectedDivision = dropdownProvider
                            .getSelectedItem('division');
                        context.read<SchoolClassProvider>().editClass(
                          context,
                          classId: widget.schoolClass.id,
                          year: _editedStdController.text.trim(),
                          classname: _editedClassNameController.text.trim(),
                          division: selectedDivision,
                        );
                      },
                      widget:
                          controller.isLoadingTwo
                              ? ButtonLoading()
                              : const Text('Update'),
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
