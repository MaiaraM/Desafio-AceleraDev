import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:acelera_dev/SaveFile.dart';
import 'package:acelera_dev/model/Crypto.dart';
import 'package:async_loader/async_loader.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; //add path provider dart plugin on pubspec.yaml file
import 'package:spinner_input/spinner_input.dart';

import 'Api.dart';

void main() =>
    runApp(MaterialApp(
      home: Home(),
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //True = descriptografa , False = Criptografica
  bool _choiceDeciphered = true;
  bool _getApi = false;
  bool _boo = false;

  //Numero de casas que sera aplicada
  double _numberHouse = 1;
  TextEditingController _typedText = TextEditingController();
  bool _visible = false;
  Crypto _crypto = Crypto(numeroCasas: 1,
      codigo: "",
      decifrado: "",
      resumoCriptografico: "",
      token: TOKEN);

  SaveFile saveFile = SaveFile();
  Api api = Api();

  @override
  void initState() {
    super.initState();
    /*to store files temporary we use getTemporaryDirectory() but we need
    permanent storage so we use getApplicationDocumentsDirectory() */
    getApplicationDocumentsDirectory().then((Directory directory) {
      saveFile.dir = directory;
      saveFile.jsonFile = new File(saveFile.dir.path + "/" + saveFile.fileName);
      saveFile.fileExists = saveFile.jsonFile.existsSync();
      if (saveFile.fileExists)
        this.setState(
                () =>
            saveFile.fileContent =
                json.decode(saveFile.jsonFile.readAsStringSync()));
    });
  }


  /*
   * Desifra e codifica o texto
   */
  _start(String text, int numeroCasas, {Crypto crypto}) {
    List<int> result = List<int>();
    for (int a in text.runes.toList()) {
      if (a >= 97 && a <= 122) {
        if (_choiceDeciphered || _getApi) {
          if (a - numeroCasas < 97) {
            int casas = 123 - (97 - (a - numeroCasas));
            result.add(casas);
            continue;
          } else {
            result.add(a - numeroCasas);
            continue;
          }
        } else {
          if (a + numeroCasas > 122) {
            int casas = 98 + ((a + numeroCasas) - 122);
            result.add(casas);
            continue;
          } else {
            result.add(a + numeroCasas);
            continue;
          }
        }
      }
      result.add(a);
    }

    setState(() {
      _visible = true;
      _boo = false;
      if (_choiceDeciphered || _getApi) {
        _crypto.decifrado = String.fromCharCodes(Uint8List.fromList(result));
        _crypto.codigo = text;
      } else {
        _crypto.decifrado = text;
        _crypto.codigo = String.fromCharCodes(Uint8List.fromList(result));
      }
      _crypto.numeroCasas = numeroCasas;
      _crypto.resumoCriptografico =
          sha1.convert(Uint8List.fromList(result)).toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AceleraDev Challenge"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  "Número de Casas:",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                SpinnerInput(
                    spinnerValue: _numberHouse,
                    middleNumberStyle:
                    TextStyle(color: Colors.blue, fontSize: 20),
                    minusButton: SpinnerButtonStyle(
                        elevation: 5,
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10)),
                    plusButton: SpinnerButtonStyle(
                        elevation: 5,
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10)),
                    middleNumberPadding: EdgeInsets.all(10),
                    minValue: 1,
                    maxValue: 10,
                    onChange: (newValue) {
                      setState(() {
                        _numberHouse = newValue;
                      });
                    }),
              ],
            ),
            ListTile(
                title: TextField(
                  controller: _typedText,
                  decoration: InputDecoration(labelText: "Digite o código"),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text("Cripotografar"),
                Switch(
                  value: _choiceDeciphered,
                  onChanged: (bool value) {
                    setState(() {
                      _choiceDeciphered = value;
                    });
                  },
                  //activeThumbImage: new NetworkImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.lightBlue,
                  inactiveThumbColor: Colors.indigo,
                ),
                Text("Descripografar"),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _start(_typedText.text, _numberHouse.toInt());
                      setState(() {
                        _getApi = false;
                      });
                    },
                    child: Text("Descripografar"),
                    elevation: 10,
                    color: Colors.indigo,
                    colorBrightness: Brightness.dark,
                  ),
                  Text("Ou"),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _getApi = true;
                        _boo = true;
                      });

                      api.get().then((result){
                        _start(result.codigo, result.numeroCasas.toInt());
                     });
                    },
                    child: Text("Buscar na API"),
                    elevation: 10,
                    color: Colors.green,
                    colorBrightness: Brightness.light,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _boo,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Visibility(
              visible: _visible,
              child: ListTile(
                leading: Icon(Icons.filter_2),
                title: Text('Número de Casas'),
                subtitle: Text(
                  _crypto.numeroCasas.toString(),
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
              ),
            ),
            Visibility(
              visible: _visible,
              child: ListTile(
                leading: Icon(Icons.enhanced_encryption),
                title: Text('Código:'),
                subtitle: Text(
                  _crypto.codigo,
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
              ),
            ),
            Visibility(
              visible: _visible,
              child: ListTile(
                leading: Icon(Icons.no_encryption),
                title: Text(
                  'Decifrado:',
                ),
                subtitle: Text(
                  _crypto.decifrado,
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
              ),
            ),
            Visibility(
              visible: _visible,
              child: ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('SHA1'),
                subtitle: Text(
                  _crypto.resumoCriptografico,
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
              ),
            ),
            Visibility(
                visible: _visible,
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: RaisedButton(
                    onPressed: () {
                      saveFile.writeToFile(_crypto.toJson());
                    },
                    child: Text(
                      "Enviar para API",
                      style: TextStyle(fontSize: 16),
                    ),
                    elevation: 10,
                    color: Colors.indigo,
                    colorBrightness: Brightness.dark,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
