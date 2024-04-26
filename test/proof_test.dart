import 'package:flutter_test/flutter_test.dart';
import 'package:sui/cryptography/ed25519_keypair.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';
import 'package:zklogin/nonce.dart';
import 'package:zklogin/proof.dart';

void main() {
  test('test get proof input', () async {
    // generate nonce, randomness, maxEpoch
    SuiClient client = SuiClient(SuiUrls.devnet);
    // get ephemeralKeyPair
    var ephemeralkey = Ed25519Keypair();
    var publicKey = ephemeralkey.getPublicKey();
    // get randomness
    String randomness = generateRandomness();
    // get maxEpoch
    var getEpoch = await client.getLatestSuiSystemState();
    var epoch = getEpoch.epoch;
    var maxEpoch = int.parse(epoch) + 10;
    // get nonce
    var nonce = generateNonce(publicKey, maxEpoch.toInt(), randomness);
    print('randomness: $randomness');
    print('maxEpoch: $maxEpoch');
    print('nonce: $nonce');
    //
    String id_token =
        'eyJhbGciOiJSUzI1NiIsImtpZCI6ImUxYjkzYzY0MDE0NGI4NGJkMDViZjI5NmQ2NzI2MmI2YmM2MWE0ODciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMDgzNDY3MjMzNDE4LWk2ZXN0MmpnMG1iZDU5cHRkZHJmNmVsaDJrZzd1dmY0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiMTA4MzQ2NzIzMzQxOC1pNmVzdDJqZzBtYmQ1OXB0ZGRyZjZlbGgya2c3dXZmNC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjExNDgwMTQ2MTAyMTExNDI5OTA2OCIsIm5vbmNlIjoiRFg5cmFUX05xREZ2MGRua2pTUnNFbFdBWkdRIiwibmJmIjoxNzE0MTE5MjA3LCJpYXQiOjE3MTQxMTk1MDcsImV4cCI6MTcxNDEyMzEwNywianRpIjoiYWIwNThmYmI1MmE3ZTdhNjExOTFiMmMwNWMyYzY3ZWUyNGQ2MTdkOCJ9.SOZ8z7DXSw5mjYXwAlb0sk1HF5UEORezvcEefy9e3KTe-VlVWuRprayY5Q-K0HhJg0dlKzJ5geGsApt6UM7nEtnbfSjXaHqF2C1Kf6sQHO736ytNQm23L55nhhmVKdkuRBq8iHsALtX773L6zQTdADq5yN9tp7V56vkpJTTzA6mA06UUhmeEZGB182hrUYfBeLQ2I0S5Hl-z5DFCO6rPp9VAOlGrY_pT85UeLwhwPfJUvnT7B106wEqy0aamEWwAirnAGbqweCt-x7izXOMtN_wIw5Afq4nVEW8RI65WZsP6DTzdNWSxDeq_RXfJ0Zem_jcJKvg842wdk2eR6Syg-w';

    var proofRequestInfo = getRequestProofInput(
        id_token: id_token,
        publicKey: ephemeralkey.getPublicKey(),
        maxEpoch: maxEpoch,
        randomness: randomness,
        salt: '255873485666802367946136116146407409355');
    print('proofRequestInfo: ${proofRequestInfo.toJson()}');
  });

  test('test get proof', () async {
    // generate nonce, randomness, maxEpoch
    SuiClient client = SuiClient(SuiUrls.devnet);
    // get ephemeralKeyPair
    var ephemeralkey = Ed25519Keypair();
    var publicKey = ephemeralkey.getPublicKey();
    // get randomness
    String randomness = generateRandomness();
    // get maxEpoch
    var getEpoch = await client.getLatestSuiSystemState();
    var epoch = getEpoch.epoch;
    var maxEpoch = int.parse(epoch) + 10;
    // get nonce
    var nonce = generateNonce(publicKey, maxEpoch.toInt(), randomness);
    print('randomness: $randomness');
    print('maxEpoch: $maxEpoch');
    print('nonce: $nonce');
    // you need a jwt token which have nonce field match with your generateNonce
    String id_token =
        'eyJhbGciOiJSUzI1NiIsImtpZCI6ImUxYjkzYzY0MDE0NGI4NGJkMDViZjI5NmQ2NzI2MmI2YmM2MWE0ODciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMDgzNDY3MjMzNDE4LWk2ZXN0MmpnMG1iZDU5cHRkZHJmNmVsaDJrZzd1dmY0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiMTA4MzQ2NzIzMzQxOC1pNmVzdDJqZzBtYmQ1OXB0ZGRyZjZlbGgya2c3dXZmNC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjExNDgwMTQ2MTAyMTExNDI5OTA2OCIsIm5vbmNlIjoiRFg5cmFUX05xREZ2MGRua2pTUnNFbFdBWkdRIiwibmJmIjoxNzE0MTE5MjA3LCJpYXQiOjE3MTQxMTk1MDcsImV4cCI6MTcxNDEyMzEwNywianRpIjoiYWIwNThmYmI1MmE3ZTdhNjExOTFiMmMwNWMyYzY3ZWUyNGQ2MTdkOCJ9.SOZ8z7DXSw5mjYXwAlb0sk1HF5UEORezvcEefy9e3KTe-VlVWuRprayY5Q-K0HhJg0dlKzJ5geGsApt6UM7nEtnbfSjXaHqF2C1Kf6sQHO736ytNQm23L55nhhmVKdkuRBq8iHsALtX773L6zQTdADq5yN9tp7V56vkpJTTzA6mA06UUhmeEZGB182hrUYfBeLQ2I0S5Hl-z5DFCO6rPp9VAOlGrY_pT85UeLwhwPfJUvnT7B106wEqy0aamEWwAirnAGbqweCt-x7izXOMtN_wIw5Afq4nVEW8RI65WZsP6DTzdNWSxDeq_RXfJ0Zem_jcJKvg842wdk2eR6Syg-w';
    // {
    //   "iss": "https://accounts.google.com",
    //   "azp": "1083467233418-i6est2jg0mbd59ptddrf6elh2kg7uvf4.apps.googleusercontent.com",
    //   "aud": "1083467233418-i6est2jg0mbd59ptddrf6elh2kg7uvf4.apps.googleusercontent.com",
    //   "sub": "114801461021114299068",
    //   "nonce": "UhKaK7mNd1aVFe341SmaRHxZZoM",
    //   "nbf": 1714117880,
    //   "iat": 1714118180,
    //   "exp": 1714121780,
    //   "jti": "fee031a4277058e14186a334c89e277b953a5078"
    // }

    // get proof request info
    RequestProofModel proofRequestInfo = getRequestProofInput(
        id_token: id_token,
        publicKey: ephemeralkey.getPublicKey(),
        maxEpoch: maxEpoch,
        randomness: randomness,
        salt: '255873485666802367946136116146407409355');

    // Change the information to match the information when creating id_token.
    // Actually you don't need this step
    proofRequestInfo.maxEpoch = '48';
    proofRequestInfo.jwtRandomness = '268303342654692502012154128887183423286';
    proofRequestInfo.extendedEphemeralPublicKey =
        '21626483936192487733305024020540053098516354521646925090728634171545975306644';
    print('proofRequestInfo: ${proofRequestInfo.toJson()}');
    //
    var proof = await getProof(proofRequestInfo);
    print(proof);
  });
}
