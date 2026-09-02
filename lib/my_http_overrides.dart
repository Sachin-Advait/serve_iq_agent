import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

Future<SecurityContext> createSecurityContext() async {
  final context = SecurityContext(withTrustedRoots: true);
  final certBytes = await rootBundle.load(
    'assets/certs/MSSPF-MSSPFDCPR02-CA.crt',
  );
  context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
  return context;
}

class MyHttpOverrides extends HttpOverrides {
  final SecurityContext securityContext;
  MyHttpOverrides(this.securityContext);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(securityContext);
  }
}
