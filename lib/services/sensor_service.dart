import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class FocusSensorService {
  StreamSubscription? _accelSub;
  int _shakeCount = 0;

  int get shakeCount => _shakeCount;

  void resetShakeCount(){
    _shakeCount = 0;
  }

  void startListening() {
    _shakeCount = 0;

    _accelSub = accelerometerEvents.listen((event) {
      // x, y, z 축 가속도 값 (m/s^2)
      final ax = event.x;
      final ay = event.y;
      final az = event.z;

      // 크기 계산 (대충 폰이 얼마나 세게 움직이는지)
      final magnitude = sqrt(ax * ax + ay * ay + az * az); // 의사코드 느낌

      // 특정 값 이상이면 "흔들렸다!"라고 카운트
      if (magnitude > 20) {  // 이 threshold는 나중에 조정 가능
        _shakeCount++;
      }
    });
  }

  void stopListening() {
    _accelSub?.cancel();
    _accelSub = null;
  }

}
