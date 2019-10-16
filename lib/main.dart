import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:acelera_dev/model/Crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';


import 'Api.dart';

void main() => runApp(MaterialApp(
      home: Home(),
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _enable = true;
  double _spinner = 1;
  int _number = 1;
  bool _visible = false;
  Crypto _post;
  TextEditingController _typedText = TextEditingController();
  String _encrypted = "";
  String _deciphered = "";
  String _sha = "";

  _start(String text, int numeroCasas, {Crypto crypto}) {
    List<int> texto = List<int>();
    for (int a in text.runes.toList()) {
      if (a >= 97 && a <= 122) {
        if (_enable) {
          if (a - numeroCasas < 97) {
            int casas = 97 - numeroCasas;
            casas = 122 - (97 - casas);
            texto.add(casas);
            continue;
          } else {
            print("codigo : $a");
            texto.add(a - numeroCasas);
            continue;
          }
        } else {
          if (a + numeroCasas > 122) {
            int casas = 122 + numeroCasas;
            casas = 97 + (casas - 122);
            texto.add(casas);
            continue;
          } else {
            print("codigo : $a");
            texto.add(a + numeroCasas);
            continue;
          }
        }
      }
      texto.add(a);
    }
    crypto.decifrado =  String.fromCharCodes(Uint8List.fromList(texto));
    crypto.resumoCriptografico = sha1.convert(Uint8List.fromList(texto)).toString();

    setState(() {
      _post = crypto;
      if(_enable){
        _deciphered = String.fromCharCodes(Uint8List.fromList(texto));
        _encrypted = text;
      }else{
        _encrypted = String.fromCharCodes(Uint8List.fromList(texto));
        _deciphered = text;
      }
      _number = numeroCasas;
      _sha = sha1.convert(Uint8List.fromList(texto)).toString();
      print(_deciphered);
      print(_encrypted);
    });
  }

  _requestApi() async {
    http.Response response = await http.get(
      URL + "?token=" + TOKEN,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      Crypto crypto = Crypto(
        numeroCasas: result["numero_casas"],
        token: result["token"],
        codigo: result["cifrado"],
        decifrado: result["decifrado"],
        resumoCriptografico: result["resumo_criptografico"],
      );
      setState(() {
        _enable = true;
      });
      _start(crypto.codigo, crypto.numeroCasas, crypto: crypto);
    }

    FormData formData = FormData.from({
      "name": "wendux",
      "age": 25,
      "file": await MultipartFile.fromFile("./text.txt",filename: "upload.txt")
    });
    response = await dio.post("/info", data: formData);

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
                    spinnerValue: _spinner,
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
                        _spinner = newValue;
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
                  value: _enable,
                  onChanged: (bool value) {
                    setState(() {
                      _enable = value;
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
                      _start(_typedText.text, _spinner.toInt());
                      setState(() {
                        _visible = true;
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
                      _requestApi();
                      setState(() {
                        _visible = true;
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
              visible: _visible,
              child: ListTile(
                leading: Icon(Icons.filter_2),
                title: Text('Número de Casas'),
                subtitle: Text(
                  _number.toString(),
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
                  _encrypted,
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
                  _deciphered,
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
                  _sha,
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
                      Api api = Api();
                      api.post(_post);
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
