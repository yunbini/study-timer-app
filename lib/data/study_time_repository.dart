import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyTimeRepository {
  final FirebaseFirestore firestore;

  StudyTimeRepository({required this.firestore});

  /// 유저별 공부시간 저장
  Future<void> addStudyTime(int seconds) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('로그인된 유저 없음');
    }

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('study_times')
        .add({
      'seconds': seconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
