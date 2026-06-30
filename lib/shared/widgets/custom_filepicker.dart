import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomFilePicker extends StatelessWidget {
  final String label;
  final String fieldName;
  final String? Function(String?)? validator;
  final bool isImagePicker;

  const CustomFilePicker({
    super.key,
    required this.label,
    required this.fieldName,
    this.validator,
    this.isImagePicker = false,
  });

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FilePickerProvider>(context);

    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Consumer<FilePickerProvider>(
              builder: (context, provider, _) {
                final file = provider.getFile(fieldName);

                return GestureDetector(
                  onTap: () async {
                    await fileProvider.pickFile(
                      fieldName,
                      imagesOnly: isImagePicker,
                    );

                    final pickedFile = provider.getFile(fieldName);
                    if (pickedFile != null) {
                      final fileSize = pickedFile.size;

                      if (fileSize > 5 * 1024 * 1024) {
                        if (!context.mounted) return;
                        state.didChange(null);
                        state.validate();
                        // provider.setError(fieldName,"File size must less than 5 mb");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("File size must be less than 5 MB"),
                          ),
                        );
                        // Clear the invalid file
                        fileProvider.clearFile(fieldName);
                        return;
                      }
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${pickedFile.name} selected")),
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No file selected")),
                      );
                    }
                    state.didChange(fileProvider.getFile(fieldName)?.path);
                    state.validate();
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            file?.name ?? "No File selected",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  file != null
                                      ? Colors.black87
                                      : Colors.black54,
                            ),
                          ),
                        ),

                        if (file != null)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          )
                        else
                          const Icon(Icons.upload_file, color: Colors.grey),
                        if (file != null)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              provider.clearFile(fieldName);
                              state.didChange(null);
                              state.validate();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}
