import 'dart:convert';
import 'dart:typed_data';

import 'package:sui/sui.dart';
import 'package:zklogin/utils.dart';

const MAX_HEADER_LEN_B64 = 248;
const MAX_PADDED_UNSIGNED_JWT_LEN = 64 * 25;

void lengthChecks(String jwt) {
  List<String> parts = jwt.split('.');
  final header = parts[0];
  final payload = parts[1];
  // Is the header small enough
  if (header.length > MAX_HEADER_LEN_B64) {
    throw Exception('Header is too long');
  }

  // Is the combined length of (header, payload, SHA2 padding) small enough?
  // unsigned_jwt = header + '.' + payload;
  int L = (header.length + 1 + payload.length) * 8;
  int K = (512 + 448 - ((L % 512) + 1)) % 512;

  // The SHA2 padding is 1 followed by K zeros, followed by the length of the message
  int paddedUnsignedJwtLen = (L + 1 + K + 64) ~/ 8;

  // The padded unsigned JWT must be less than the max_padded_unsigned_jwt_len
  if (paddedUnsignedJwtLen > MAX_PADDED_UNSIGNED_JWT_LEN) {
    throw Exception('JWT is too long');
  }
}

String jwtToAddress(String jwt, BigInt userSalt) {
  lengthChecks(jwt);

  final decodedJWT = decodeJwt(jwt);
  if (decodedJWT['sub'] == null ||
      decodedJWT['iss'] == null ||
      decodedJWT['aud'] == null) {
    throw Exception('Missing jwt data');
  }

  if (decodedJWT['aud'] is List) {
    throw Exception('Not supported aud. Aud is an array, string was expected.');
  }

  return computeZkLoginAddress(
    userSalt: userSalt,
    claimName: 'sub',
    claimValue: decodedJWT['sub'],
    aud: decodedJWT['aud'],
    iss: decodedJWT['iss'],
  );
}

String computeZkLoginAddress({
  required String claimName,
  required String claimValue,
  required BigInt userSalt,
  required String iss,
  required String aud,
}) {
  return computeZkLoginAddressFromSeed(
    genAddressSeed(userSalt, claimName, claimValue, aud),
    iss,
  );
}

Map decodeJwt(String jwt) {
  List<String> parts = jwt.split('.');
  if (parts.length == 5) {
    throw 'Only JWTs using Compact JWS serialization can be decoded';
  }
  if (parts.length != 3) {
    throw 'Invalid JWT';
  }

  String payload = parts[1];
  if (payload.isEmpty) {
    throw 'JWTs must contain a payload';
  }

  Uint8List decoded;
  try {
    decoded = base64Url.decode(base64Url.normalize(payload));
  } catch (_) {
    throw 'Failed to base64url decode the payload';
  }

  try {
    String jsonPayload = utf8.decode(decoded);
    Map<String, dynamic> result = jsonDecode(jsonPayload);
    return result;
  } catch (e) {
    throw 'Failed to decode JWT: $e';
  }
}
