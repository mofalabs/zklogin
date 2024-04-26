import 'dart:convert';

import 'package:sui/zklogin/signature.dart';
import 'package:sui/zklogin/types.dart';

class ZkSignBuilder {
  static late ZkLoginSignatureInputs zkLoginSignatureInputs;
  static late int maxEpoch;
  static String getZkSign({required String signSignature}) {
    final zkSign = getZkLoginSignature(ZkLoginSignature(
        inputs: zkLoginSignatureInputs,
        maxEpoch: maxEpoch,
        userSignature: base64Decode(signSignature)));
    return zkSign;
  }

  static setInfo(
      {required ZkLoginSignatureInputs inputZkLoginSignatureInputs,
      required int inputMaxEpoch}) {
    zkLoginSignatureInputs = inputZkLoginSignatureInputs;
    maxEpoch = inputMaxEpoch;
  }
}
