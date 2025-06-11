import 'package:acadobs/core/controller/file_picker_provider.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/widgets/common_appbar.dart';
import 'package:acadobs/core/widgets/common_button.dart';
import 'package:acadobs/core/widgets/custom_filepicker.dart';
import 'package:acadobs/core/widgets/custom_textfield.dart';
import 'package:acadobs/features/superadmin/schools/controller/school_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSchoolScreen extends StatefulWidget {
  const AddSchoolScreen({super.key});

  @override
  State<AddSchoolScreen> createState() => _AddSchoolScreenState();
}

class _AddSchoolScreenState extends State<AddSchoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  late FilePickerProvider filePickerProvider;

  @override
  void initState() {
    super.initState();
    filePickerProvider = context.read<FilePickerProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      filePickerProvider.clearFile('logo');
    });
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Add School", isBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.width * 4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.height * 2),
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.school),
                  label: "School Name*",
                  controller: _schoolNameController,
                  validator:
                      (value) => FormValidator.validateNotEmpty(
                        value,
                        fieldName: "School Name",
                      ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.email),
                  label: "Email*",
                  controller: _emailController,
                  validator: (value) => FormValidator.validateEmail(value),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.phone),
                  label: "Phone*",
                  controller: _phoneController,
                  validator:
                      (value) => FormValidator.validatePhoneNumber(value),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.location_on),
                  label: "Address*",
                  controller: _addressController,
                  validator:
                      (value) => FormValidator.validateNotEmpty(
                        value,
                        fieldName: "Address",
                      ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomTextfield(
                  iconData: Icon(Icons.lock),
                  label: "Admin Password*",
                  controller: _adminPasswordController,
                  isPasswordField: true,
                  validator:
                      (value) => FormValidator.validateNotEmpty(
                        value,
                        fieldName: "Admin Password",
                      ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomFilePicker(
                  isImagePicker: true,
                  label: "Upload Logo:",
                  fieldName: "logo",
                ),
                SizedBox(height: Responsive.height * 5),
                Padding(
                  padding: EdgeInsets.only(bottom: Responsive.height * 4),
                  child: Consumer<SchoolController>(
                    builder: (context, controller, child) {
                      return CommonButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<SchoolController>().addSchool(
                              context,
                              name: _schoolNameController.text.trim(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                              adminPassword:
                                  _adminPasswordController.text.trim(),
                            );
                          }
                        },
                        widget:
                            controller.isLoadingTwo
                                ? ButtonLoading()
                                : const Text('Create School'),
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
