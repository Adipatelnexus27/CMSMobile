import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _flashEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Camera placeholder
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54,
              child: const Icon(
                Icons.camera,
                size: 80,
                color: Colors.white30,
              ),
            ),
          ),

          // Top controls
          Positioned(
            top: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    _flashEnabled ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: AppSpacing.iconLarge,
                  ),
                  onPressed: () {
                    setState(() => _flashEnabled = !_flashEnabled);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: AppSpacing.iconLarge,
                  ),
                  onPressed: () {
                    // Camera settings
                  },
                ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    iconSize: AppSpacing.iconLarge,
                    onPressed: () {
                      // Open gallery
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      // Capture photo
                      _showCapturePreview();
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    iconSize: AppSpacing.iconLarge,
                    onPressed: () {
                      // Switch camera
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCapturePreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Captured'),
        content: const Text('Would you like to save or retake this photo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Retake'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo saved successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
