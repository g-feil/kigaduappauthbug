import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: startLoginProcedure,
                  child: Text("Start login procedure"))
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Future<void> startLoginProcedure() async {
    // Config stuff
    final _authorizationServiceConfiguration =
        AuthorizationServiceConfiguration(
            authorizationEndpoint:
                'https://${Config.IDP_DOMAIN}/connect/authorize',
            endSessionEndpoint:
                'https://${Config.IDP_DOMAIN}/connect/endsession',
            tokenEndpoint: 'https://${Config.IDP_DOMAIN}/connect/token');

    // First authenticate with biometrics
    FlutterAppAuth appAuth = FlutterAppAuth();
    var authenticated = await _localAuthentication.authenticate(
      localizedReason: 'Activate using biometrics please',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (authenticated) {
      print("User authenticated");
    } else {
      print("User not authenticated");
    }

    // This gets called to early, which triggers the undesired behavior
    try {
  final AuthorizationTokenResponse result =
      await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
          Config.IDP_CLIENT_ID, Config.IDP_REDIRECT_URI,
          serviceConfiguration: _authorizationServiceConfiguration,
          issuer: Config.IDP_ISSUER,
          scopes: Config.AUTH_SCOPES,
          externalUserAgent:
              ExternalUserAgent.ephemeralAsWebAuthenticationSession));
    } on FlutterAppAuthUserCancelledException catch (e) {
      print("Usere cancelled the login procedure");
    }
  }
}

class Config {
  static const String IDP_CLIENT_ID = 'kigadu_app';
  static const String IDP_REDIRECT_URI = 'at.kigadu.app://login-callback/';
  static String IDP_DOMAIN = 'account.kigadu.at';
  static String get IDP_ISSUER => 'https://$IDP_DOMAIN';
  static final List<String> AUTH_SCOPES = <String>[
    'openid',
    'kigadu_app_api',
    'offline_access',
    'profile'
  ];
}
