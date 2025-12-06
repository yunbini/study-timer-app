import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'package:flutter/material.dart';

class NaverLoginService {
  static const String clientId = "HpqL8HZ8pDg_YnSro6bF";
  static const String clientSecret = "Tq7vWgZx2d";
  static const String redirectUri = "http://127.0.0.1:8080/callback";

  static Future<String?> loginWithNaverWebView() async {
    Completer<String?> loginResult = Completer();

    final authUrl =
        "https://nid.naver.com/oauth2.0/authorize"
        "?response_type=code"
        "&client_id=$clientId"
        "&redirect_uri=$redirectUri"
        "&state=naver_login_state";

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            if (url.startsWith(redirectUri)) {
              final uri = Uri.parse(url);
              final code = uri.queryParameters["code"];
              final state = uri.queryParameters["state"];

              if (code != null) {
                final token = await _requestToken(code, state ?? "");
                loginResult.complete(token);
              } else {
                loginResult.complete(null);
              }

              // WebView 페이지 닫기
              navigatorKey.currentState?.pop();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(authUrl));

    // WebView 페이지 띄우기
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("네이버 로그인")),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );

    return loginResult.future;
  }

  static Future<String?> _requestToken(String code, String state) async {
    final url =
        "https://nid.naver.com/oauth2.0/token"
        "?grant_type=authorization_code"
        "&client_id=$clientId"
        "&client_secret=$clientSecret"
        "&code=$code"
        "&state=$state";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }
}
