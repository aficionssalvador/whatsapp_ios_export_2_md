import 'package:file_picker/file_picker.dart';

void pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    String filePath = result.files.single.path;
    // Aquí puedes procesar el archivo seleccionado y convertirlo a Markdown.
  }
}
