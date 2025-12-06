import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../main.dart';
import '../services/google_signin_service.dart';
import '../services/naver_login_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> _loginKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      print("카카오 로그인 성공: ${token.accessToken}");
      navigatorKey.currentState!.pushReplacementNamed('/home');
    } catch (e) {
      print("카카오 로그인 실패: $e");
    }
  }

  Future<void> _loginGoogle() async {
    final user = await GoogleSignInService.signInWithGoogle();
    if (user != null) {
      navigatorKey.currentState!.pushReplacementNamed('/home');
    }
  }

  Future<void> _loginNaver() async {
    final token = await NaverLoginService.loginWithNaverWebView();
    if (token != null) {
      print("네이버 로그인 성공: $token");
      navigatorKey.currentState!.pushReplacementNamed('/home');
    } else {
      print("네이버 로그인 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _loginKakao,
              child: const Text("카카오 로그인"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginGoogle,
              child: const Text("구글 로그인"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginNaver,
              child: const Text("네이버 로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
