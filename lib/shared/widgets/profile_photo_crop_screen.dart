import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Holds the cropped image result with both raw [bytes] (available on all platforms including Web)
/// and optional [file] (available on mobile/desktop platforms).
class ProfilePhotoCropResult {
  final Uint8List bytes;
  final File? file;
  final String fileName;

  ProfilePhotoCropResult({
    required this.bytes,
    this.file,
    required this.fileName,
  });
}

/// A simplified, distraction-free crop screen for profile photos (Square crop only).
class ProfilePhotoCropScreen extends StatefulWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final String title;

  const ProfilePhotoCropScreen({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.title = 'Crop Photo',
  }) : assert(
         imageFile != null || imageBytes != null,
         'Either imageFile or imageBytes must be provided',
       );

  /// Helper to open the crop screen and return the [ProfilePhotoCropResult] (or `null` if cancelled).
  static Future<ProfilePhotoCropResult?> cropImage(
    BuildContext context, {
    File? imageFile,
    Uint8List? imageBytes,
    String title = 'Crop Photo',
  }) async {
    return Navigator.of(context).push<ProfilePhotoCropResult>(
      MaterialPageRoute(
        builder:
            (context) => ProfilePhotoCropScreen(
              imageFile: imageFile,
              imageBytes: imageBytes,
              title: title,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ProfilePhotoCropScreen> createState() => _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  final CropController _controller = CropController();

  Uint8List? _currentBytes;
  bool _isLoading = true;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _loadImageData();
  }

  Future<void> _loadImageData() async {
    try {
      if (widget.imageBytes != null) {
        _currentBytes = widget.imageBytes;
      } else if (widget.imageFile != null && !kIsWeb) {
        _currentBytes = await widget.imageFile!.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error reading image data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'cropped_profile_$timestamp.jpg';
          File? targetFile;

          if (!kIsWeb) {
            try {
              final tempDir = await getTemporaryDirectory();
              targetFile = File('${tempDir.path}/$fileName');
              await targetFile.writeAsBytes(croppedImage);
            } catch (e) {
              debugPrint('Warning: Could not save to local temp file: $e');
            }
          }

          if (mounted) {
            Navigator.of(context).pop(
              ProfilePhotoCropResult(
                bytes: croppedImage,
                file: targetFile,
                fileName: fileName,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error saving cropped image: $e');
          if (mounted) {
            setState(() => _isCropping = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save cropped image.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;

      case CropFailure(:final cause):
        debugPrint('Crop failed: $cause');
        if (mounted) {
          setState(() => _isCropping = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Crop failed: $cause'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(),

            // Center Cropping Area (Square only)
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading || _currentBytes == null)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00AEF0),
                      ),
                    )
                  else
                    Crop(
                      image: _currentBytes!,
                      controller: _controller,
                      onCropped: _onCropped,
                      aspectRatio: 1.0,
                      withCircleUi: false,
                      interactive: true,
                      baseColor: Colors.black,
                      maskColor: Colors.black.withValues(alpha: 0.75),
                      progressIndicator: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00AEF0),
                        ),
                      ),
                    ),

                  // Cropping in progress overlay
                  if (_isCropping)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(
                              color: Color(0xFF00AEF0),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cropping photo...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Bar: Cancel & Done only
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            tooltip: 'Cancel',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: const Color(0xFF111827),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size(70, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed:
                (_isCropping || _isLoading)
                    ? null
                    : () {
                      setState(() => _isCropping = true);
                      _controller.crop();
                    },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 42),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: const Color(0xFF00AEF0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child:
                _isCropping
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Done',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
          ),
        ],
      ),
    );
  }
}
