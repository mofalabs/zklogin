import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wenimal_zklogin_demo/zk_login_store.dart';
import 'package:zklogin/zklogin.dart';
import 'login_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginPage(),
  ));
}

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isLoading = false;
  late String REDIRECT_URL = 'http://localhost:3000/#id_token=';
  String redirect = '';
  WebViewController getWebViewController(BuildContext context) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent("random")
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            String temp = redirect.replaceAll('$REDIRECT_URL', '');
            temp = temp.substring(0, temp.indexOf('&'));
            Navigator.pop(context, temp);
          },
          onNavigationRequest: (NavigationRequest request) {
            redirect = request.url;
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    print('build web');
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
              child: WebViewWidget(
                controller: getWebViewController(context),
              ),
            )),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final REDIRECT_URL = 'http://localhost:3000';
  // Configure OpenID Providers: https://docs.sui.io/guides/developer/cryptography/zklogin-integration/developer-account
  final CLIENT_ID =
      '1083467233418-no9crphhseet7cgn7grsn98l16odg613.apps.googleusercontent.com';

  late Map<String, dynamic> info;

  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getZkLoginInfo(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> res = snapshot.data!;
            // Stores data that is used in move calls and ZkSignBuilder.setInfo
            ZkLoginStore.ephemeralKey = res['ephemeralKeyPair'];
            ZkLoginStore.maxEpoch = res['maxEpoch'];
            //
            String URL =
                'https://accounts.google.com/o/oauth2/v2/auth/oauthchooseaccount?client_id=1083467233418-i6est2jg0mbd59ptddrf6elh2kg7uvf4.apps.googleusercontent.com&response_type=id_token&redirect_uri=$REDIRECT_URL&scope=openid&nonce=${res['nonce']}&service=lso&o2v=2&theme=mn&ddm=0&flowName=GeneralOAuthFlow';
            RequestProofModel requestProofModel = res['requestProofModel'];
            print('requestProofModel: ${requestProofModel.toJson()}');
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg_app.png'),
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      bottom: 50,
                      right: 50,
                      left: 30,
                      top: 20), // Add top padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOGETHER",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "WE",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              letterSpacing: 5,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "CAN",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              letterSpacing: 5,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w900,
                              color: Color.fromRGBO(86, 105, 255, 1.000),
                              decoration: TextDecoration.none,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "!",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        "This is first version of zkLogin developed by Wenimal Team.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        "JOIN WITH US",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(86, 105, 255, 1.000),
                          decoration: TextDecoration.none,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      OutlinedButton(
                        onPressed: () async {
                          // login with google
                          try {
                            await _handleLoginButtonClick(
                                URL, requestProofModel, res);
                          } catch (e) {
                            print('Exception');

                            throw Exception(e.toString());
                          }
                          print('WENIMAL ZKLOGIN SUCCESSFULLY');
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color.fromRGBO(86, 105, 255, 1.000),
                            textStyle: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                            padding: const EdgeInsets.only(
                                left: 50, right: 50, top: 20, bottom: 20)),
                        child: const Row(children: [
                          Image(
                            image: AssetImage("assets/images/icon_google.png"),
                            height: 30,
                            width: 30.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: Text("Login with google"),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('ERROR'),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _handleLoginButtonClick(
      String URL, RequestProofModel requestProofModel, dynamic res) async {
    var loginResRedirect = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            url: URL,
          ),
        ));
    print('loginResRedirect: $loginResRedirect');
    if (loginResRedirect != null) {
      requestProofModel.jwt = loginResRedirect;
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Container(
              alignment: Alignment.center,
              width: double.maxFinite,
              child: const Text('WENIMAL LOGIN SUCCESSFULLY'),
            ),
            children: const [
              Text(
                  'You can check loginResRedirect and waiting for zkSign and userAdrress load in function loadAddressAndSignature()')
            ],
          );
        },
      );
      LoginProvider().loadAddressAndSignature(loginResRedirect, res);
    }
  }
}
