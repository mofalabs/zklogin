
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sui/sui.dart';
import 'package:sui/utils/hex.dart';
import 'package:zklogin/address.dart';
import 'package:zklogin/utils.dart';

import 'package:dio/dio.dart';

void main() {
  
  test('dummy zkLogin transaction', () async {

    const maxEpoch = 140;

    const randomness = '52093847050252666398858998671021422992';

    // const nonce = 'eXcm9IR3-8p4MAwb3u5dm8T2CvE';

    const jwtStr = 'xxx.yyy.zzz';
    final jwt = decodeJwt(jwtStr);

    final userSalt = BigInt.parse('244579473807694399890185396317414759380');

    final address = jwtToAddress(jwtStr, userSalt);

    final ephemeralKeypair = Ed25519Keypair.fromSecretKey(base64Decode('fh+VAX39y3W+C0W1lO7QDxXIsD88426bOoPq1g0P5lU='));

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

    final txb = TransactionBlock();
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