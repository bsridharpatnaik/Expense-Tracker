import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../build_config.dart';
import '../handlers/notification_handler.dart';
import 'excelRenderer.dart';

String? inferMimeType(Uint8List blobData) {
  if (blobData.length > 4) {
    // Check for JPEG (FFD8)
    if (blobData[0] == 0xFF && blobData[1] == 0xD8) {
      return 'image/jpeg';
    }
    // Check for PNG (89504E47)
    if (blobData[0] == 0x89 &&
        blobData[1] == 0x50 &&
        blobData[2] == 0x4E &&
        blobData[3] == 0x47) {
      return 'image/png';
    }
    // Check for PDF (25504446)
    if (blobData[0] == 0x25 &&
        blobData[1] == 0x50 &&
        blobData[2] == 0x44 &&
        blobData[3] == 0x46) {
      return 'application/pdf';
    }
    // Check for Excel (XLSX) - XLSX files start with "504B0304" (PK\x03\x04)
    if (blobData[0] == 0x50 &&
        blobData[1] == 0x4B &&
        blobData[2] == 0x03 &&
        blobData[3] == 0x04) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
  }
  return null; // Unknown type
}

Future<void> saveBlobToDownloads(
    Uint8List blobData, String fileName) async {
  try {
    final Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    String filePath = '${downloadsDirectory.path}/$fileName';
    File file = File(filePath);

    // Check if a file with the same name already exists
    int counter = 1;
    while (file.existsSync()) {
      // Modify the file name with a counter (e.g., "filename(1).ext")
      final nameWithoutExtension = fileName.split('.').first;
      final extension = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      filePath = '${downloadsDirectory.path}/$nameWithoutExtension($counter)$extension';
      file = File(filePath);
      counter++;
    }
    await file.writeAsBytes(blobData);
    NotificationHandler.showDefault("File downloaded.");
  } catch (e) {
    NotificationHandler.showDefault('Error saving file: $e');
  }
}


Future<void> requestStoragePermission() async {
  final permissionStatus = await Permission.storage.status;
  if (permissionStatus.isDenied) {
    await Permission.storage.request();
  } else if (permissionStatus.isPermanentlyDenied) {
    await openAppSettings();
  } else {
  }
}

Future<void> requestManageExternalStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    print('Storage permission granted');
  } else {
    print('Storage permission denied, opening app settings...');
    // Guide the user to open app settings to manually enable the permission
    await openAppSettings();
  }
}

void showBlobDialog(
    BuildContext context, Uint8List blobData, String? mimeType, String fileName) {
  mimeType ??= inferMimeType(blobData) ?? 'application/octet-stream';
  Widget content;
  if (mimeType.startsWith('image/')) {
    content = Image.memory(blobData); // Display Image
  } else if (mimeType == 'application/pdf') {
    content = SfPdfViewer.memory(blobData); // Add PDF viewer
  } else if (mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
    content = ExcelFileRenderer(blobData: blobData);
  } else {
    content = const Center(child: Text("File preview not supported."));
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: content),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      BuildConfig.appIsActive = true;
                      try{
                        await requestStoragePermission();
                        await requestManageExternalStoragePermission();
                        await saveBlobToDownloads(blobData, fileName);
                      }finally{
                        BuildConfig.appIsActive = false;
                      }
                    },
                    child: const Text("Download"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
