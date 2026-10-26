import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';

/// Service to handle real camera capture and gallery picking across Web and Mobile.
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from Camera or Gallery and returns a displayable URL / Data URI.
  /// On Web/Mobile, converts bytes to a Base64 data URI: `data:image/jpeg;base64,...`
  /// which can be stored and rendered immediately with [Image.network] or [NetworkImage].
  static Future<String?> pickImage({
    required ImageSource source,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (file == null) return null;

      final Uint8List bytes = await file.readAsBytes();
      final String base64String = base64Encode(bytes);
      final String mimeType = file.mimeType ?? 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('[ImagePickerService] Error picking image: $e');
      return null;
    }
  }

  /// Shows a modal bottom sheet allowing the user to choose Camera or Gallery.
  static Future<void> showPickerSheet({
    required BuildContext context,
    required String title,
    required ValueChanged<String> onImageSelected,
    List<Map<String, String>>? presets,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose Camera to take a photo or Gallery to select an existing file:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Option 1: Live Camera
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Capture real-time photo directly',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final dataUrl = await pickImage(source: ImageSource.camera);
                    if (dataUrl != null) {
                      onImageSelected(dataUrl);
                    }
                  },
                ),

                // Option 2: Gallery
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text(
                    'Choose from Device Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Select photo or document from storage',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final dataUrl =
                        await pickImage(source: ImageSource.gallery);
                    if (dataUrl != null) {
                      onImageSelected(dataUrl);
                    }
                  },
                ),

                if (presets != null && presets.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    'Or Quick Preset Demo Avatars:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: presets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final p = presets[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            onImageSelected(p['url']!);
                          },
                          child: CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(p['url']!),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
