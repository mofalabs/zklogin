import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sui/cryptography/keypair.dart';
import 'package:sui/utils/hex.dart';
import 'package:sui/zklogin/utils.dart';
import 'poseidon.dart';

const NONCE_LENGTH = 27;

BigInt toBigIntBE(Uint8List bytes) {
  String hex = Hex.encode(bytes);
  if (hex.isEmpty) {
    return BigInt.from(0);
  }
  return BigInt.parse('0x$hex');
}

String generateRandomness() {
  Uint8List bytes = randomBytes(16);
  return toBigIntBE(bytes).toString();
}

Uint8List randomBytes(int size) {
  var random = Random.secure();
  return Uint8List.fromList(
      List.generate(size, (index) => random.nextInt(256)));
}

String generateNonce(PublicKey publicKey, int maxEpoch, dynamic randomness) {
  BigInt publicKeyBytes = toBigIntBE(publicKey.toSuiBytes());
  BigInt ephPublicKey0 = publicKeyBytes ~/ BigInt.two.pow(128);
  BigInt ephPublicKey1 = publicKeyBytes % BigInt.two.pow(128);
  BigInt bigNum;

  if (randomness is String) {
    bigNum = poseidonHash([
      ephPublicKey0,
      ephPublicKey1,
      BigInt.from(maxEpoch),
      BigInt.parse(randomness)
    ]);
  } else if (randomness is BigInt) {
    bigNum = poseidonHash(
        [ephPublicKey0, ephPublicKey1, BigInt.from(maxEpoch), randomness]);
  } else {
    throw ArgumentError(
        'Invalid type for randomness. It should be either BigInt or String.');
  }

  Uint8List z = toBigEndianBytes(bigNum, 20);
  String nonce = base64UrlEncode(z)
      .replaceAll('=', '')
      .replaceAll('+', '-')
      .replaceAll('/', '_');
  if (nonce.length != NONCE_LENGTH) {
    throw Exception(
        'Length of nonce $nonce (${nonce.length}) is not equal to $NONCE_LENGTH');
  }
  return nonce;
}
