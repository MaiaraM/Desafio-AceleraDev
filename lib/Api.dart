import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';


import 'model/Crypto.dart';


const TOKEN = '5c81bf7bcdfd216414393b0be21f80ec2e72a6d6';
const GET = 'https://api.codenation.dev/v1/challenge/dev-ps/generate-data';
const POST = 'https://api.codenation.dev/v1/challenge/dev-ps/submit-solution';


class Api {

  Future<Crypto> get() async {
    http.Response response = await http.get(
      "$GET?token=$TOKEN",
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

      return crypto;
    }

    return null;
  }

  post(File crypto, Directory dir) async {
    Dio dio = new Dio();

    FormData formData = new FormData.fromMap({
      "answer": await MultipartFile.fromFile(
        crypto.path,
        filename: "answer.json",
      ),
    });

    try {
      Response response = await dio.post(
          "$POST?token=$TOKEN",
          data: formData,
          options: new Options(
              contentType: "multipart/form-data"
          ));

      return "${response.statusMessage}:  ${response.data.toString()}";
    } on DioError catch (e) {
      return e.response.statusMessage;
    }
  }
  }