import 'dart:convert';
import 'dart:io';

import 'Api.dart';


class SaveFile{

  File jsonFile;
  Directory dir;
  String fileName = "answer.json";
  bool fileExists = false;
  Map<String, dynamic> fileContent;

  _createFile(Map<String, dynamic> content, Directory dir, String fileName) {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
    print(jsonFile);
  }

  writeToFile(Map<String, dynamic> content) {
    print("Writing to file!");
    if (fileExists) {
      print("File exists");
      Map<String, dynamic> jsonFileContent =
      json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist!");
      _createFile(content, dir, fileName);
    }

    print(fileContent);
    Api api = Api();
    api.post(jsonFile, dir);
  }

}