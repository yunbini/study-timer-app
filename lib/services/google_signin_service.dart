import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google 계정 선택
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // 로그인 취소

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Firebase Auth로 넘길 Credential 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth 로그인
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("구글 로그인 실패: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
