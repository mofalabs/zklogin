import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sui/sui.dart';
import 'package:zklogin/zklogin.dart';

void main() {
  late Ed25519Keypair keypair;
  const int maxEpoch = 1442;
  const String randomness = '14752559325642415408119996554694955254';

  setUpAll(() {
    var privateKey =
        base64Decode('OHEvQmt8QMPX/nug6VvBDCJH1DnVvNMbVn1IYqkzGe0=');
    var publicKey =
        base64Decode('DeNjAm9vxWXqxUbTcrd2akbNCmBNRoPfw+DCInOw2iE=');
    List<int> l = [];
    l.addAll(privateKey.toList());
    l.addAll(publicKey.toList());
    keypair = Ed25519Keypair(Uint8List.fromList(l));
  });

  test('test poseidonHash', () async {
    final publicKeyBytes = BigInt.parse(
        '6281824653831026224998922387073113193498095287946158112976943056571082005025');
    BigInt ephPublicKey0 = publicKeyBytes ~/ BigInt.two.pow(128);
    BigInt ephPublicKey1 = publicKeyBytes % BigInt.two.pow(128);
    expect(
        ephPublicKey0, BigInt.parse('18460623483586357805708369096221357674'));
    expect(
        ephPublicKey1, BigInt.parse('94110591014858981974560167800041691681'));
    final bigNum = poseidonHash([
      ephPublicKey0,
      ephPublicKey1,
      BigInt.from(maxEpoch),
      BigInt.parse(randomness)
    ]);
    final isValid = bigNum ==
        BigInt.parse(
            '2619264862928796237665642107758540586456026125333792035747733517061756436769');
    expect(isValid, true);
  });

  test('test generateNonce', () async {
    final nonce = generateNonce(keypair.getPublicKey(), maxEpoch, randomness);
    final isValid = nonce == 'fg9VRS1RQuezjY_XlzsYcZ9aQSE';
    expect(isValid, true);
  });
}
