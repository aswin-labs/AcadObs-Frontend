import 'package:acadobs/core/controller/file_picker_provider.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/widgets/common_appbar.dart';
import 'package:acadobs/core/widgets/common_button.dart';
import 'package:acadobs/core/widgets/custom_filepicker.dart';
import 'package:acadobs/core/widgets/custom_textfield.dart';
import 'package:acadobs/features/superadmin/data/models/school_model.dart';
import 'package:acadobs/features/superadmin/schools/controller/school_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSchoolScreen extends StatefulWidget {
  final School school;

  const EditSchoolScreen({super.key, required this.school});

  @override
  State<EditSchoolScreen> createState() => _EditSchoolScreenState();
}

class _EditSchoolScreenState extends State<EditSchoolScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late FilePickerProvider filePickerProvider;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.school.name);
    _emailController = TextEditingController(text: widget.school.email);
    _phoneController = TextEditingController(text: widget.school.phone);
    _addressController = TextEditingController(text: widget.school.address);
    filePickerProvider = context.read<FilePickerProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      filePickerProvider.clearFile('logo');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit School", isBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.height * 2),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("School Name:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.school),
                hintText: 'Enter School Name',
                controller: _nameController,
              ),
              SizedBox(height: Responsive.height * 2),

              // Email
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Email:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.email),
                hintText: 'Enter Email',
                controller: _emailController,
              ),
              SizedBox(height: Responsive.height * 2),

              // Phone
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Phone:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.phone),
                hintText: 'Enter Phone Number',
                controller: _phoneController,
              ),
              SizedBox(height: Responsive.height * 2),

              // Address
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("Address:"),
              ),
              SizedBox(height: Responsive.height * 1),
              CustomTextfield(
                iconData: Icon(Icons.location_on),
                hintText: 'Enter Address',
                controller: _addressController,
              ),
              SizedBox(height: Responsive.height * 2),

              CustomFilePicker(label: "Upload Logo:", fieldName: "logo"),
              SizedBox(height: Responsive.height * 4),

              // Update Button
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.height * 4),
                child: Consumer<SchoolController>(
                  builder: (context, controller, child) {
                    return CommonButton(
                      onPressed: () {
                        context.read<SchoolController>().editSchool(
                          context,
                          schoolId: widget.school.id,
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
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
