import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;

class OutputAttachmentDraft {
  final String fileName;
  final String? path;
  final String? mimeType;
  final int? sizeBytes;
  final String attachmentType;

  const OutputAttachmentDraft({
    required this.fileName,
    this.path,
    this.mimeType,
    this.sizeBytes,
    required this.attachmentType,
  });
}

class AttachmentPickerResult {
  final List<OutputAttachmentDraft> attachments;
  final String? errorMessage;
  final bool isMissingPlugin;

  const AttachmentPickerResult({
    required this.attachments,
    this.errorMessage,
    this.isMissingPlugin = false,
  });
}

class AttachmentPickerService {
  const AttachmentPickerService();

  Future<AttachmentPickerResult> pickOutputAttachments() async {
    try {
      final List<XFile> files = await openFiles();
      
      if (files.isEmpty) {
        return const AttachmentPickerResult(attachments: []);
      }

      final attachments = <OutputAttachmentDraft>[];
      for (final file in files) {
        String mimeType = 'application/octet-stream';
        String attachmentType = 'other';
        final ext = p.extension(file.name).toLowerCase();
        
        if (ext == '.png') {
          mimeType = 'image/png';
          attachmentType = 'image';
        } else if (ext == '.jpg' || ext == '.jpeg') {
          mimeType = 'image/jpeg';
          attachmentType = 'image';
        } else if (ext == '.pdf') {
          mimeType = 'application/pdf';
          attachmentType = 'pdf';
        } else if (ext == '.json') {
          mimeType = 'application/json';
          attachmentType = 'json';
        } else if (ext == '.mp4') {
          mimeType = 'video/mp4';
          attachmentType = 'video';
        } else if (ext == '.csv') {
          mimeType = 'text/csv';
          attachmentType = 'dataset';
        } else if (ext == '.zip') {
          mimeType = 'application/zip';
          attachmentType = 'archive';
        }

        int? size;
        try {
          size = await file.length();
        } catch (_) {}

        attachments.add(OutputAttachmentDraft(
          fileName: file.name,
          path: file.path,
          mimeType: mimeType,
          sizeBytes: size,
          attachmentType: attachmentType,
        ));
      }

      return AttachmentPickerResult(attachments: attachments);
    } on MissingPluginException catch (_) {
      return const AttachmentPickerResult(
        attachments: [],
        errorMessage: 'File picker is unavailable on this platform/runtime. Try rebuilding the app or use a supported desktop/mobile target.',
        isMissingPlugin: true,
      );
    } catch (e) {
      return AttachmentPickerResult(
        attachments: [],
        errorMessage: 'Failed to pick files: $e',
      );
    }
  }
}
