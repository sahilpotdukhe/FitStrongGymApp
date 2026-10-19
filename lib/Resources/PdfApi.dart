import 'dart:io';

// foundation only: this file uses the pdf package's own Text/Container,
// so a full flutter/material import would clash with them.
import 'package:flutter/foundation.dart';

// import 'package:open_file_plus/open_file_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future<void> openFile(File file) async {
    final result = await OpenFilex.open(file.path);
    debugPrint('OpenFilex result: ${result.message}');
  }
}
