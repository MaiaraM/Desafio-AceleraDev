import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Crypto{
  int numeroCasas;
  String token;
  String codigo;
  String decifrado;
  String resumoCriptografico;


  Crypto({this.numeroCasas, this.token, this.codigo, this.decifrado,
      this.resumoCriptografico});

  factory Crypto.fromJson(Map<String, dynamic> json){
    return Crypto(
      numeroCasas: json["numero_casas"],
      token: json["token"],
      codigo: json["cifrado"],
      decifrado: json["decifrado"],
      resumoCriptografico: json["resumo_criptografico"],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'numero_casas': this.numeroCasas,
        'token': this.token,
        'cifrado': this.codigo,
        'decifrado': this.decifrado,
        'resumo_criptografico': this.resumoCriptografico,
      };


}