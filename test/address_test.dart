import 'package:flutter_test/flutter_test.dart';
import 'package:zklogin/zklogin.dart';

void main() {
  test(
    'a valid JWT should not throw an error',
    () async {
      const jwt =
          'eyJraWQiOiJzdWkta2V5LWlkIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI4YzJkN2Q2Ni04N2FmLTQxZmEtYjZmYy02M2U4YmI3MWZhYjQiLCJhdWQiOiJ0ZXN0IiwibmJmIjoxNjk3NDY1NDQ1LCJpc3MiOiJodHRwczovL29hdXRoLnN1aS5pbyIsImV4cCI6MTY5NzU1MTg0NSwibm9uY2UiOiJoVFBwZ0Y3WEFLYlczN3JFVVM2cEVWWnFtb0kifQ.';
      final userSalt = BigInt.parse('248191903847969014646285995941615069143');
      final address = jwtToAddress(jwt, userSalt);
      final isValid = address ==
          '0x22cebcf68a9d75d508d50d553dd6bae378ef51177a3a6325b749e57e3ba237d6';
      expect(isValid, true);
    },
  );

  test(
    'should return the same address for both google iss',
    () async {
      /**
       * {
       * "iss": "https://accounts.google.com",
       * "sub": "1234567890",
       * "aud": "1234567890.apps.googleusercontent.com",
       * "exp": 1697551845,
       * "iat": 1697465445
       * }
       */
      const jwt1 =
          'eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMjM0NTY3ODkwIiwiYXVkIjoiMTIzNDU2Nzg5MC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImV4cCI6MTY5NzU1MTg0NSwiaWF0IjoxNjk3NDY1NDQ1fQ.';
      /**
       * {
       * "iss": "accounts.google.com",
       * "sub": "1234567890",
       * "aud": "1234567890.apps.googleusercontent.com",
       * "exp": 1697551845,
       * "iat": 1697465445
       * }
       */
      const jwt2 =
          'eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwic3ViIjoiMTIzNDU2Nzg5MCIsImF1ZCI6IjEyMzQ1Njc4OTAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJleHAiOjE2OTc1NTE4NDUsImlhdCI6MTY5NzQ2NTQ0NX0.';
      final isValid =
          jwtToAddress(jwt1, BigInt.zero) == jwtToAddress(jwt2, BigInt.zero);
      expect(isValid, true);
    },
  );

  test('wenimal sui address', () async {
    const String userSalt = '178325214277756936057804824740577021427';
    const String jwt =
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjZjZTExYWVjZjllYjE0MDI0YTQ0YmJmZDFiY2Y4YjMyYTEyMjg3ZmEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI1NzMxMjAwNzA4NzEtMGs3Z2E2bnM3OWllMGpwZzFlaTZpcDV2amUyb3N0dDYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI1NzMxMjAwNzA4NzEtMGs3Z2E2bnM3OWllMGpwZzFlaTZpcDV2amUyb3N0dDYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTQ4MDE0NjEwMjExMTQyOTkwNjgiLCJub25jZSI6IjZ5Y0tHVEJUcnBvTy03VlZWSmlJTG5yZndjayIsIm5iZiI6MTcxMzMyNzY3MywiaWF0IjoxNzEzMzI3OTczLCJleHAiOjE3MTMzMzE1NzMsImp0aSI6IjIzMzJjNjg4OTczZmU4Yjg3YTIyZjMxNTU1MjZhNjAxZGZhYTZmZGEifQ.ULTmK70bMe__B1H3VEOL65J4HBF02E9edcX6yGn2veIRVTGQLZvN3e1uvs8X175DAwmgTUriqvWPSMJ27KKWcbmcjiS6NOj5UA7OejYe0ZUSovAiFMkuzNBUEi9T_vR2dLgXeG6HquFKAj67vb1QuQiitBXoAP4HFqMfA80Oa_CGdVxU8s3DQHeEjKeAiyngtry0VyUOSvDbEfHoRVJlRPo7ozrJsLX-YtopVgAnRkPzl7oAZenDbfEhhVW02mPvHly2R8nBhXrO4oECtuycC2ZYtRMvJmATZT_7lje9Fkj5L50mk4pFYsfdzhaKk3LkwBXp7V8e1hrr5EU4M_ZrKg";
    // {
    //   "iss": "https://accounts.google.com",
    //   "azp": "573120070871-0k7ga6ns79ie0jpg1ei6ip5vje2ostt6.apps.googleusercontent.com",
    //   "aud": "573120070871-0k7ga6ns79ie0jpg1ei6ip5vje2ostt6.apps.googleusercontent.com",
    //   "sub": "114801461021114299068",
    //   "nonce": "6ycKGTBTrpoO-7VVVJiILnrfwck",
    //   "nbf": 1713327673,
    //   "iat": 1713327973,
    //   "exp": 1713331573,
    //   "jti": "2332c688973fe8b87a22f3155526a601dfaa6fda"
    // }
    String suiAddress = jwtToAddress(jwt, BigInt.parse(userSalt));
    print('sui address: $suiAddress');
  });
}
