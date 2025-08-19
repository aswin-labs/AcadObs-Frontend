import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditHomeWorkScreen extends StatefulWidget {
  final HomeworkModel homework;
  const EditHomeWorkScreen({super.key, required this.homework});

  @override
  State<EditHomeWorkScreen> createState() => _EditHomeWorkScreenState();
}

class _EditHomeWorkScreenState extends State<EditHomeWorkScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.homework.title);
    descriptionController = TextEditingController(
      text: widget.homework.description,
    );
    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.homework.dueDate ?? DateTime.now());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void buttonAction(BuildContext context) {
    context.read<HomeworkProvider>().edithomeWork(
      context: context,
      subjectId: widget.homework.subjectId ?? 0,
      title: titleController.text,
      description: descriptionController.text,
      duedate: dateController.text,

      homeworkId: widget.homework.id ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacer = SizedBox(height: Responsive.height * 2);

    return Scaffold(
      appBar: CommonAppBar(title: 'Edit Homework', isBackButton: true),
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
                  CustomDatePicker(
                    label: "Due Date*",
                    dateController: dateController,
                    onDateSelected: (selectedDate) {
                      dateController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(selectedDate);
                    },
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                    validator: (value) {
                      return FormValidator.validateNotEmpty(value);
                    },
                  ),
                  spacer,
                  SizedBox(
                    height: Responsive.height * 6,
                    width: Responsive.width * 35,
                    child: Consumer<HomeworkProvider>(
                      builder: (context, provier, _) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(2),
                          ),
                          onPressed: () {
                            buttonAction(context);
                          },
                          child:
                              context.watch<HomeworkProvider>().isLoadingTwo
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
