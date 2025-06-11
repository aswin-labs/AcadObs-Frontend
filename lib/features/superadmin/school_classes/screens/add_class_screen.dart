import 'package:acadobs/core/controller/dropdown_provider.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/widgets/common_appbar.dart';
import 'package:acadobs/core/widgets/common_button.dart';
import 'package:acadobs/core/widgets/custom_dropdown.dart';
import 'package:acadobs/core/widgets/custom_textfield.dart';
import 'package:acadobs/features/superadmin/school_classes/controller/school_classes_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DropdownProvider>().clearSelectedItem('division');
    });
  }

  @override
  void dispose() {
    _yearController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Add Class", isBackButton: true),
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
                  iconData: Icon(Icons.calendar_today),
                  label: "Year*",
                  controller: _yearController,
                  validator:
                      (value) => FormValidator.validateNotEmpty(
                        value,
                        fieldName: "Year",
                      ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.class_),
                  label: "Class Name*",
                  controller: _classNameController,
                  validator:
                      (value) => FormValidator.validateNotEmpty(
                        value,
                        fieldName: "Class Name",
                      ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomDropdown(
                  dropdownKey: 'division',
                  label: "Division*",
                  icon: Icons.school,
                  items: ["A", "B", "C", "D", "E"], // divisions list
                ),
                SizedBox(height: Responsive.height * 2),
                Padding(
                  padding: EdgeInsets.only(bottom: Responsive.height * 4),
                  child: Consumer<SchoolClassController>(
                    builder: (context, controller, child) {
                      return CommonButton(
                        onPressed: () {
                          final division = context
                              .read<DropdownProvider>()
                              .getSelectedItem('division');
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<SchoolClassController>().addClass(
                              context,
                              year: _yearController.text.trim(),
                              classname: _classNameController.text.trim(),
                              division: division,
                            );
                          }
                        },
                        widget:
                            controller.isLoadingTwo
                                ? ButtonLoading()
                                : const Text('Add'),
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
