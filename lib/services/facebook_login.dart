import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  try {
    // Facebook에서 로그인 요청
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      // AccessToken -> Firebase Credential 변환
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(result.accessToken!.token);

      // Firebase 로그인 처리
      return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } else {
      print('Facebook 로그인 실패: ${result.status} / ${result.message}');
      return null;
    }
  } catch (e) {
    print("Facebook 로그인 중 오류 발생: $e");
    return null;
  }
}