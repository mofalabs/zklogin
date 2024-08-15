
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sui/builder/transaction.dart';
import 'package:sui/sui.dart';

import 'package:dio/dio.dart';
import 'package:zklogin/zklogin.dart';

void main() {
  
  test('dummy zkLogin transaction', () async {

    const maxEpoch = 140;

    final randomness = generateRandomness();

    final ephemeralKeypair = Ed25519Keypair();

    final nonce = generateNonce(ephemeralKeypair.getPublicKey(), maxEpoch, randomness);

    const jwtStr = 'xxx.yyy.zzz';
    final jwt = decodeJwt(jwtStr);

    final userSalt = BigInt.parse('244579473807694399890185396317414759380');

    final address = jwtToAddress(jwtStr, userSalt);

    final extendedEphemeralPublicKey = getExtendedEphemeralPublicKey(ephemeralKeypair.getPublicKey());

    final body = {
      "jwt": jwtStr,
      "extendedEphemeralPublicKey": extendedEphemeralPublicKey,
      "maxEpoch": maxEpoch,
      "jwtRandomness": randomness,
      "salt": userSalt.toString(),
      "keyClaimName": "sub",
    };

    final zkProof = (await Dio().post('https://prover-dev.mystenlabs.com/v1', data: body)).data;

    final txb = Transaction();
    txb.setSenderIfNotSet(address);
    final coin = txb.splitCoins(txb.gas, [txb.pureInt(22222)]);
    txb.transferObjects([coin], txb.pureAddress(address));
    
    final client = SuiClient(SuiUrls.devnet);
    final sign = await txb.sign(SignOptions(signer: ephemeralKeypair, client: client));

    final addressSeed = genAddressSeed(userSalt, 'sub', jwt['sub'].toString(), jwt['aud'].toString());
    zkProof["addressSeed"] = addressSeed.toString();

    final zksign = getZkLoginSignature(ZkLoginSignature(
        inputs: ZkLoginSignatureInputs.fromJson(zkProof),
        maxEpoch: maxEpoch,
        userSignature: base64Decode(sign.signature)
      )
    );

    final resp = await client.executeTransactionBlock(sign.bytes, [zksign], options: SuiTransactionBlockResponseOptions(showEffects: true));
    expect(resp.effects?.status.status, ExecutionStatusType.success);

  });


}