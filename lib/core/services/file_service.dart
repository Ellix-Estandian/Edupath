import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileService {
  final supabase = Supabase.instance.client;

  Future<void> openFile({
    required String filePath,
    required String fileName,
  }) async {
    final url =
        supabase.storage.from("learning-materials").getPublicUrl(filePath);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Unable to download file.");
    }

    final dir = await getTemporaryDirectory();

    final file = File("${dir.path}/$fileName");

    await file.writeAsBytes(response.bodyBytes);

    await OpenFilex.open(file.path);
  }
}
