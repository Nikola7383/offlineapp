import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../config/app_config.dart';
import '../logging/logger_service.dart';

class ImageProcessor {
  final LoggerService _logger;

  ImageProcessor({
    required LoggerService logger,
  }) : _logger = logger;

  Future<File?> compressImage(File imageFile) async {
    try {
      final String originalPath = imageFile.path;
      final String targetPath = originalPath.replaceAll(
        RegExp(r'(\.[^.]*$)'),
        '_compressed.jpg',
      );

      final originalSize = await imageFile.length();

      final result = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        targetPath,
        quality: AppConfig.imageCompressionQuality,
        rotate: 0,
      );

      if (result != null) {
        final compressedSize = await result.length();
        final savings =
            ((originalSize - compressedSize) / originalSize * 100).round();

        _logger.info(
          'Image compressed: $savings% reduction '
          '(${_formatSize(originalSize)} -> ${_formatSize(compressedSize)})',
        );

        return result;
      }

      _logger.warning('Image compression failed');
      return null;
    } catch (e) {
      _logger.error('Error compressing image', e);
      return null;
    }
  }

  Future<List<File>> processBatchImages(List<File> images) async {
    final processedImages = <File>[];

    for (final image in images) {
      final compressed = await compressImage(image);
      if (compressed != null) {
        processedImages.add(compressed);
      }
    }

    return processedImages;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
