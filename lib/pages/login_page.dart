import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../main.dart';
import '../services/google_signin_service.dart';
import '../services/naver_login_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _loginFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.token);

        await FirebaseAuth.instance.signInWithCredential(credential);

        print("페이스북 로그인 성공");
        navigatorKey.currentState!.pushReplacementNamed('/home');
      } else {
        print("페이스북 로그인 실패: ${result.status}");
      }
    } catch (e) {
      print("페이스북 로그인 오류: $e");
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginFacebook,
              child: const Text("페이스북 로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
