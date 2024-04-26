import 'package:flutter/foundation.dart';
import 'package:sui/sui.dart';
import 'package:zklogin/zklogin.dart';
import 'zk_login_store.dart';
import 'zk_sign_builder.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginProvider extends ChangeNotifier {
  String zkSignature = '';
  String userAddress = '';

  Future<void> loadAddressAndSignature(
      String userJwt, Map<String, dynamic> resProofRequestInfo) async {
    String userAddress = await _handleLogin(userJwt, resProofRequestInfo);
    print('userAddress: $userAddress');
    notifyListeners();
  }

  Future<String> _handleLogin(String userJwt, dynamic res) async {
    RequestProofModel requestProofModel = res['requestProofModel'];
    requestProofModel.jwt = userJwt;

    var proof = await getProof(RequestProofModel(
        jwt: requestProofModel.jwt,
        extendedEphemeralPublicKey:
            requestProofModel.extendedEphemeralPublicKey,
        maxEpoch: requestProofModel.maxEpoch,
        jwtRandomness: requestProofModel.jwtRandomness,
        salt: requestProofModel.salt,
        keyClaimName: requestProofModel.keyClaimName));
    var userAddress = jwtToAddress(
        requestProofModel.jwt!, BigInt.parse(requestProofModel.salt));
    final decodedJWT = JwtDecoder.decode(requestProofModel.jwt!);
    var addressSeed = genAddressSeed(BigInt.parse(requestProofModel.salt),
        'sub', decodedJWT['sub'], decodedJWT['aud']);
    ProofPoints proofPoints = ProofPoints.fromJson(proof['proofPoints']);
    ZkLoginSignatureInputs zkLoginSignatureInputs = ZkLoginSignatureInputs(
      proofPoints: proofPoints,
      issBase64Details: Claim.fromJson(proof['issBase64Details']),
      addressSeed: addressSeed.toString(),
      headerBase64: proof['headerBase64'],
    );
    print('myProof: $proof');
    // set data for move call
    ZkSignBuilder.setInfo(
        inputZkLoginSignatureInputs: zkLoginSignatureInputs,
        inputMaxEpoch: ZkLoginStore.maxEpoch);
    return userAddress;
  }
}
