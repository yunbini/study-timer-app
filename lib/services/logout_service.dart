import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogoutService {
  /// -------------------------------
  /// 🔵 Google 로그아웃
  /// -------------------------------
  static Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();       // Google 계정 연결 종료
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut(); // Firebase 세션 종료
    } catch (_) {}
  }

  /// -------------------------------
  /// 🟡 Kakao 로그아웃
  /// -------------------------------
  static Future<void> signOutKakao() async {
    try {
      await UserApi.instance.logout(); // 카카오 토큰 삭제
    } catch (_) {}
  }

  /// -------------------------------
  /// 🟢 Naver 로그아웃 (REST API 방식)
  /// -------------------------------
  static Future<void> signOutNaver(String accessToken) async {
    final url = Uri.parse("https://nid.naver.com/oauth2.0/token");

    try {
      final response = await http.post(url, body: {
        "grant_type": "delete",
        "client_id": "HpqL8HZ8pDg_YnSro6bF",       // 🔥 네이버 client_id
        "client_secret": "Tq7vWgZx2d", // 🔥 네이버 secret
        "access_token": accessToken,
        "service_provider": "NAVER"
      });

      print("네이버 로그아웃 결과: ${response.body}");
    } catch (e) {
      print("네이버 로그아웃 실패: $e");
    }
  }

  /// -------------------------------
  /// 🔥 전체 로그아웃 (로그인 종류 상관 없음)
  /// -------------------------------
  static Future<void> signOutAll({String? naverAccessToken}) async {

    // Google
    try { await signOutGoogle(); } catch (_) {}

    // Kakao
    try { await signOutKakao(); } catch (_) {}

    // 네이버 (토큰 전달 시)
    if (naverAccessToken != null) {
      try { await signOutNaver(naverAccessToken); } catch (_) {}
    }
  }
}
