import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sui/cryptography/keypair.dart';

import 'nonce.dart';

Map<String, String> headers = {
  "Content-Type": "application/json",
  "Accept": "application/json",
};

// final String urlGetProof =
//     'http://192.168.1.15:3000/api/v1/contract/getZkProof';
const String urlGetProof = 'https://prover-dev.mystenlabs.com/v1';

RequestProofModel getRequestProofInput(
    {String? id_token,
    required PublicKey publicKey,
    required int maxEpoch,
    required String randomness,
    required String salt}) {
  var extendedEphemeralPublicKey =
      toBigIntBE(publicKey.toSuiBytes()).toString();

  RequestProofModel requestProofModel = RequestProofModel(
      jwt: id_token,
      extendedEphemeralPublicKey: extendedEphemeralPublicKey,
      maxEpoch: maxEpoch.toString(),
      jwtRandomness: randomness,
      salt: salt,
      keyClaimName: 'sub');
  return requestProofModel;
}

Future<Map<String, dynamic>> getProof(
    RequestProofModel requestProofModel) async {
  var res = await http.post(Uri.parse(urlGetProof),
      headers: headers, body: jsonEncode(requestProofModel.toJson()));
  if (res.statusCode == 200) {
    Map<String, dynamic> response = jsonDecode(res.body);
    return response;
  } else {
    throw Exception("Load page fail ${res.statusCode}, ${res.body}");
  }
}

RequestProofModel requestProofModelFromJson(String str) =>
    RequestProofModel.fromJson(json.decode(str));

String requestProofModelToJson(RequestProofModel data) =>
    json.encode(data.toJson());

class RequestProofModel {
  String? jwt;
  String extendedEphemeralPublicKey;
  String maxEpoch;
  String jwtRandomness;
  String salt;
  String keyClaimName;

  RequestProofModel({
    this.jwt,
    required this.extendedEphemeralPublicKey,
    required this.maxEpoch,
    required this.jwtRandomness,
    required this.salt,
    this.keyClaimName = 'sub',
  });

  RequestProofModel copyWith({
    String? jwt,
    String? extendedEphemeralPublicKey,
    String? maxEpoch,
    String? jwtRandomness,
    String? salt,
    String? keyClaimName,
  }) =>
      RequestProofModel(
        jwt: jwt ?? this.jwt,
        extendedEphemeralPublicKey:
            extendedEphemeralPublicKey ?? this.extendedEphemeralPublicKey,
        maxEpoch: maxEpoch ?? this.maxEpoch,
        jwtRandomness: jwtRandomness ?? this.jwtRandomness,
        salt: salt ?? this.salt,
        keyClaimName: keyClaimName ?? this.keyClaimName,
      );

  factory RequestProofModel.fromJson(Map<String, dynamic> json) =>
      RequestProofModel(
        jwt: json["jwt"],
        extendedEphemeralPublicKey: json["extendedEphemeralPublicKey"],
        maxEpoch: json["maxEpoch"],
        jwtRandomness: json["jwtRandomness"],
        salt: json["salt"],
        keyClaimName: json["keyClaimName"],
      );

  Map<String, dynamic> toJson() => {
        "jwt": jwt,
        "extendedEphemeralPublicKey": extendedEphemeralPublicKey,
        "maxEpoch": maxEpoch,
        "jwtRandomness": jwtRandomness,
        "salt": salt,
        "keyClaimName": keyClaimName,
      };
}
