import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import 'package:whatsapp_ios_export_2_md/u2/u2_list_strings.dart';
import 'package:whatsapp_ios_export_2_md/u2/u2_string_utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Establece esto en false
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String filePath = '';
  String markdownContent = '';
  String errorText = '';
  RegExp datetimePattern = RegExp(r'\d{1,2}\/\d{1,2}\/\d{2}, \d{2}:\d{2}:\d{2}');
  RegExp datePattern = RegExp(r'^\[\d{1,2}\/\d{1,2}\/\d{2}, \d{2}:\d{2}:\d{2}\] .*');
  RegExp datePatternSin2puntos = RegExp(r'^\[\d{1,2}\/\d{1,2}\/\d{2}, \d{1,2}:\d{2}:\d{2}\] .*: .*');
  final utf8206 = String.fromCharCode(0x200E);

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        filePath = result.files.single.path!;
        markdownContent = ''; // Limpiar el contenido Markdown
        errorText = ''; // Limpiar cualquier mensaje de error anterior
      });
    }
  }

  //bool teDataHora(String cadena){
  //  if (cadena == '') {print(".");return false;}
  //  String s1 = U2StringUtils.u2Field(cadena, '[', 1);
  //  if (s1 != '') {
  //    if (s1 != this.utf8206) {print("*");return false;}
  //  }
  //  String s2 = U2StringUtils.u2Field(cadena, '[', 2);
  //  s2 = U2StringUtils.u2Field(s2,']',1);
  //  if (s2 == '') {print("+");return false;}
  //  bool isMatch = this.datetimePattern.hasMatch(s2);
  //  return isMatch;
  //}

  String escapeChar(String cadena){
    return cadena.replaceAll('<', '**').replaceAll('>', '**');
  }
  
  String resaltaNom(String cadena){
    if (cadena == 'Non i cognoms del meu whatapp') {
      return '. . . . . . . . **$cadena** ';
    } else {
      return cadena;
    }
  }

  void convertToMarkdown() {
    if (filePath.isNotEmpty) {
      try {
        String fileContent = File(filePath).readAsStringSync();
        U2ListStrings lsIn = U2ListStrings(fileContent, '\r\n');
        U2ListStrings lsOut = U2ListStrings('', '\r\n');
        for (int i = 1; i <= lsIn.fieldDCount();i++){
          String s = lsIn.field(i);
          bool tecr = (s.indexOf('\r') >= 0);
          if( tecr) {s = s.replaceAll('\r', '');}
          bool tenl = (s.indexOf('\n') >= 0);
          if( tenl) {s = s.replaceAll('\n', '');}
          bool teutf8206 = (s.indexOf(this.utf8206) >= 0);
          if( teutf8206) {s = s.replaceAll(this.utf8206, '');}
          bool isMatch = this.datePattern.hasMatch(s);
          if (isMatch) {
            List<String> parts = s.split('] ');
            String dateAndTime = parts[0].replaceFirst('[', '');
            String restOfString = parts.sublist(1).join('] ');
            bool isSin2Puntos = !this.datePatternSin2puntos.hasMatch(s);
            if (isSin2Puntos) {
              lsOut.fieldStore('', -1);
              lsOut.fieldStore(dateAndTime, -1);
              lsOut.fieldStore('> ${escapeChar(restOfString)}', -1);
            } else {
              List<String> parts2 = restOfString.split(': ');
              String name = parts2[0];
              String restOfString2 = parts2.sublist(1).join(': ');
              lsOut.fieldStore('', -1);
              lsOut.fieldStore('$dateAndTime ${escapeChar(resaltaNom(name))}' , -1);
              if (teutf8206){
                bool teAttached= ((restOfString2.indexOf('<attached: ')>=0)&&(restOfString2.indexOf('>')>=0));
                if (teAttached) {
                  String reste3 = U2StringUtils.u2Field(U2StringUtils.u2Field(restOfString2, '<attached: ', 2),'>',1);
                  lsOut.fieldStore('> ![[$reste3]]', -1);
                } else
                {
                  lsOut.fieldStore('> ${escapeChar(restOfString2)}', -1);
                }
              } else {
                lsOut.fieldStore('> ${escapeChar(restOfString2)}', -1);
              }
            }
          } else {
            lsOut.fieldStore('> ${escapeChar(s)}', -1);
          }
        }
        if (lsOut.fieldDCount()>10){
          lsOut.fieldInsert('^start', 1);
          lsOut.fieldStore('^end', -1);
        }
        String outputFilePath = filePath.replaceAll('.txt', '.md');
        print ('salida: $outputFilePath');
        print ('len: ${lsOut.fieldJoin().length}');
        File(outputFilePath).writeAsStringSync(lsOut.fieldJoin());

        setState(() {
          markdownContent = lsOut.fieldJoin(); // Cargar el contenido en Markdown
          errorText = ''; // Limpiar cualquier mensaje de error anterior
        });

      } catch (e) {
        setState(() {
          errorText = 'Error al cargar/guardar el archivo: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File to Markdown Converter'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (filePath.isNotEmpty)
                  Text(
                    'Ruta del archivo: $filePath',
                    style: TextStyle(fontSize: 16),
                  ),
                ElevatedButton(
                  onPressed: pickFile,
                  child: Text('Seleccionar archivo'),
                ),
                ElevatedButton(
                  onPressed: convertToMarkdown,
                  child: Text('Convertir a Markdown'),
                ),
                if (errorText.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      errorText,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          if (markdownContent.isNotEmpty)
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Markdown(data: markdownContent),
              ),
            ),
        ],
      ),
    );
  }
}
