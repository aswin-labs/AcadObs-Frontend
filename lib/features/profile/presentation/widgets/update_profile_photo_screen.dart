import 'dart:io';

import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class UpdateProfilePhotoScreen extends StatefulWidget {
  const UpdateProfilePhotoScreen({super.key});

  @override
  State<UpdateProfilePhotoScreen> createState() =>
      _UpdateProfilePhotoScreenState();
}

class _UpdateProfilePhotoScreenState extends State<UpdateProfilePhotoScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    await context.read<ProfileProvider>().updateProfilePhoto(_selectedImage!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      // appBar: AppBar(title: const Text("Edit Profile Photo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile photo preview
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child:
                  _selectedImage == null
                      ? const Icon(
                        LucideIcons.user,
                        size: 60,
                        color: Colors.grey,
                      )
                      : null,
            ),

            const SizedBox(height: 30),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.image),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.camera),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),

            const Spacer(),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    provider.isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(LucideIcons.upload),
                label: const Text("Upload Photo"),
                onPressed: provider.isLoading ? null : _uploadImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// void showEditProfilePhotoBottomheet ({
//   required BuildContext context
// })
// {
//       final provider = context.watch<ProfileProvider>();
//     final imageUrl = provider.guardianProfile?.guardianEmail;
//   showModalBottomSheet(context: context, 
//   isScrollControlled: true,
//    shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//   builder: (context){
//     return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 60,
//             height: 5,
//             margin: const EdgeInsets.only(bottom: 20),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           const Text(
//             "Edit Profile Photo",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),

//           // Profile photo preview
//           CircleAvatar(
//             radius: 65,
//             backgroundColor: Colors.grey[200],
//             backgroundImage: _selectedImage != null
//                 ? FileImage(_selectedImage!)
//                 : (imageUrl != null
//                     ? NetworkImage(imageUrl) as ImageProvider
//                     : null),
//             child: _selectedImage == null && imageUrl == null
//                 ? const Icon(LucideIcons.user, size: 60, color: Colors.grey)
//                 : null,
//           ),

//           const SizedBox(height: 25),

//           // Camera / Gallery buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 icon: const Icon(LucideIcons.image),
//                 label: const Text("Gallery"),
//                 onPressed: () => _pickImage(ImageSource.gallery),
//               ),
//               const SizedBox(width: 20),
//               ElevatedButton.icon(
//                 icon: const Icon(LucideIcons.camera),
//                 label: const Text("Camera"),
//                 onPressed: () => _pickImage(ImageSource.camera),
//               ),
//             ],
//           ),

//           const SizedBox(height: 30),

//           // Upload button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               icon: provider.isLoading
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : const Icon(LucideIcons.upload),
//               label: const Text("Upload Photo"),
//               onPressed: provider.isLoading ? null : _uploadImage,
//             ),
//           ),
//         ],
//       );
//   });
// }

