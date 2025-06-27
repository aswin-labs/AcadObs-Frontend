import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomFilePicker extends StatelessWidget {
  final String label;
  final String fieldName;
  final String? Function(String?)? validator; 
  final bool isImagePicker; 

  const CustomFilePicker({super.key, 
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
            GestureDetector(
              onTap: () async {
                await fileProvider.pickFile(fieldName, imagesOnly: isImagePicker);
                state.didChange(fileProvider.getFile(fieldName)?.path);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileProvider.getFile(fieldName)?.name ??
                            'No file selected',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    const Icon(Icons.upload_file, color: Colors.grey),
                  ],
                ),
              ),
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