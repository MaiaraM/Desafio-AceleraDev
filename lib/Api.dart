import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:acelera_dev/model/Crypto.dart';


const TOKEN = '5c81bf7bcdfd216414393b0be21f80ec2e72a6d6';
const URL = 'https://api.codenation.dev/v1/challenge/dev-ps/generate-data';

class Api{


  post(Crypto crypto) async {
    http.Response response =  await http.post(
      URL + "?",
      headers: {"Content-type": "multipart/form-data"},
      body: crypto.toJson()
    );
  }

}