import 'dart:io';

import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit Profile Photo", isBackButton: true,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child:
                  _selectedImage == null
                      ? const Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPickOptions,
              child: Text("Change Photo"),
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

