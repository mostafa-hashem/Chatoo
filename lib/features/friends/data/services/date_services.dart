import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<DateTime> getData() async {
  HttpOverrides.global = MyHttpOverrides();
  final response = await http.get(Uri.parse("https://worldclockapi.com/api/json/utc/now"));
  if (response.statusCode == 200) {
    final date = jsonDecode(response.body);
    return DateTime.parse(date["currentDateTime"] as String);
  } else {
    return DateTime.now();
  }
}
