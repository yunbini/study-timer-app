import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xtimer/model/task_model.dart';
import 'package:xtimer/services/sensor_service.dart';
import 'package:xtimer/widgets/rounded_button_widget.dart';
import 'package:xtimer/widgets/wave_animation.dart';
import 'package:xtimer/services/sensor_service.dart';

class TimerPage extends StatefulWidget {
  final Task task;

  const TimerPage({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {

  late Timer _timer;
  late AnimationController _controller;

  late final FocusSensorService _sensorService; //센서 서비스 객체
  bool _isPausedBySensor = false; //센서 감지후 일시정지 상태를 저장하는 변수

  Stopwatch stopwatch = Stopwatch();
  String timeText = "";
  String statusText = "";
  String buttonText = "Start";

  double beginHeight = 0.0;
  late Animation<double> heightSize;

  @override
  void initState() {
    super.initState();

    _sensorService = FocusSensorService();//FocusSensorService 객체 초기화
    _sensorService.startListening(); //센서 리스닝 시작

    final duration = Duration(
      hours: widget.task.hours,
      minutes: widget.task.minutes,
      seconds: widget.task.seconds,
    );

    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    heightSize = Tween<double>(
      begin: beginHeight,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateClock());

    _setInitialTimeText();
  }

  void _setInitialTimeText() {
    timeText =
    "${widget.task.hours.toString().padLeft(2, '0')}:"
        "${widget.task.minutes.toString().padLeft(2, '0')}:"
        "${widget.task.seconds.toString().padLeft(2, '0')}";
  }

  void updateClock() {
    final duration = Duration(
      hours: widget.task.hours,
      minutes: widget.task.minutes,
      seconds: widget.task.seconds,
    );

    if (!stopwatch.isRunning){ // 정지상태라면 센서 흔들림 카운트만 확인
      if(_sensorService.shakeCount > 0){
        print('타이머가 멈춰있는데 흔들림 감지');
        _sensorService.resetShakeCount();
      }
      return;
    }

    final currentShakeCount = _sensorService.shakeCount; //센서 흔들림 횟수 확인
    if (currentShakeCount > 0) { //만약 흔들림이 감지됐다면
      // 타이머를 멈추는 함수를 호출!
      stopwatch.stop();
      _controller.stop();

      // 상태 텍스트를 "흔들려서 일시정지!" 같은 메시지로 업데이트!
      setState(() {
        statusText = "🚨 움직임 감지! 일시정지 🚨";
        buttonText = "Start"; // 다시 시작할 수 있도록 버튼 텍스트 변경
        // 🚨 그리고 흔들림 카운트를 0으로 리셋해줘서 다시 움직일 때까지 멈춰있게 해야 해!
        _sensorService.resetShakeCount(); // (public 리셋 메서드 쓰면 더 좋아!)
      });
      return; // 멈췄으니 아래 타이머 업데이트 로직은 건너뛰기!
    }

    if (stopwatch.elapsed >= duration) {
      stopwatch.stop();
      _controller.stop();

      setState(() {
        statusText = "Finished";
        buttonText = "Restart";
        timeText = "00:00:00";
      });

      return;
    }

    final remaining = duration - stopwatch.elapsed;

    setState(() {
      timeText =
      "${remaining.inHours.toString().padLeft(2, '0')}:"
          "${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:"
          "${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _sensorService.stopListening();
    super.dispose();
  }

  void _restart() {
    stopwatch.reset();
    stopwatch.stop();
    _controller.reset();
    beginHeight = 0.0;

    setState(() {
      buttonText = "Start";
      statusText = "";
    });

    _setInitialTimeText();
  }

  void _toggleStartPause() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      _controller.stop();
      statusText = "Paused";
    } else {
      stopwatch.start();
      _controller.forward();
      statusText = "";
    }

    setState(() {
      buttonText = stopwatch.isRunning ? "Running" : "Paused";
    });
  }

  @override
  Widget build(BuildContext context) {
    heightSize = Tween<double>(
      begin: beginHeight,
      end: MediaQuery.of(context).size.height - 65,
    ).animate(_controller);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return DemoBody(
                size: Size(
                  MediaQuery.of(context).size.width,
                  heightSize.value,
                ),
                color: widget.task.color,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 4, right: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.navigate_before,
                      size: 40, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sync,
                      size: 32, color: Colors.white70),
                  onPressed: _restart,
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(bottom: 250),
              child: Text(
                widget.task.title,
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                        fontSize: 54, color: Colors.white),
                  ),
                  Text(
                    statusText,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                child: RoundedButton(text: buttonText),
                onTap: () {
                  if (buttonText == "Restart") {
                    _restart();
                  } else {
                    _toggleStartPause();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
