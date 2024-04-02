
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sui/sui.dart';
import 'package:zklogin/address.dart';
import 'package:zklogin/utils.dart';

void main() {
  
  test('dummy zkLogin transaction', () async {

    const maxEpoch = 115;

    // const randomness = '83112888220041143452741614452805664549';

    // const nonce = 'GJsMSpYnAhUv68bx8HPr1qc25PI';

    // final jwt = {
    //   "iss": "https://accounts.google.com",
    //   "azp": "dummy.apps.googleusercontent.com",
    //   "aud": "dummy.apps.googleusercontent.com",
    //   "sub": "113765147417551786709",
    //   "nonce": "GJsMSpYnAhUv68bx8HPr1qc25PI",
    //   "nbf": 1712035153,
    //   "iat": 1712035453,
    //   "exp": 1712039053,
    //   "jti": "c6a2f081a27d2eede73a228b529f13c56da01711"
    // };

    const jwtStr = 'xxx.yyy.zzz';
    final jwt = decodeJwt(jwtStr);

    final userSalt = BigInt.parse('244579473807694399890185396317414759380');

    final address = jwtToAddress(jwtStr, userSalt);

    final zkProof = {
      "proofPoints": {
        "a": [
          "20154733307901990166833908477826118620655537239523749174749048389434989744793",
          "20421832936914781971615404336215366991426700926107191345816374502611047426975",
          "1"
        ],
        "b": [
          [
            "11833890943923527680730833557043823373274816425552253968103674435923635148904",
            "14401359162586163144568540608246233780135906981473238411558680651092641517034"
          ],
          [
            "8471047032797390862272941852792479964619943060936081370802481457839204669091",
            "20908442829211109747292485431081100236255140986675845400227023083990437060274"
          ],
          [
            "1",
            "0"
          ]
        ],
        "c": [
          "7507022710525057925568914881493441239291089747305354576616386047188517140487",
          "17512130009557241740283596768030353252050073304623605065151975649338347670710",
          "1"
        ]
      },
      "issBase64Details": {
        "value": "yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC",
        "indexMod4": 1
      },
      "headerBase64": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjkzNGE1ODE2NDY4Yjk1NzAzOTUzZDE0ZTlmMTVkZjVkMDlhNDAxZTQiLCJ0eXAiOiJKV1QifQ"
    };


    final ephemeralKeypair = Ed25519Keypair.fromSecretKey(base64Decode('fh+VAX39y3W+C0W1lO7QDxXIsD88426bOoPq1g0P5lU='));

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