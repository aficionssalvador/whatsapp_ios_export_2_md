import 'package:markdown/markdown.dart' as md;

void convertToMarkdown(String filePath) {
  // Lee el contenido del archivo
  String fileContent = File(filePath).readAsStringSync();

  // Convierte el contenido a Markdown
  String markdownContent = md.markdownToHtml(fileContent);

  // Puedes guardar el contenido Markdown en un archivo con extensión ".md" si es necesario.
  // Por ejemplo, puedes usar la biblioteca `path` para manipular las rutas de archivos.
  String outputFilePath = filePath.replaceAll(RegExp(r'\..+$'), '.md');
  File(outputFilePath).writeAsStringSync(markdownContent);
}
