import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xtimer/model/task_model.dart';
import 'package:xtimer/pages/timer_page.dart';

class TaskWidget extends StatelessWidget {
  TaskWidget({
    Key? key,
    required this.task,
  }) : super(key: key);

  final Task task;
  final BorderRadius _borderRadius = BorderRadius.all(Radius.circular(8.0));

  /// When called start timer Screen
  void _startTimerPage(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => TimerPage(task: task),
      ),
    );
  }

  String _formatDuration() {
    return '${task.hours.toString().padLeft(2, '0')}:'
        '${task.minutes.toString().padLeft(2, '0')}:'
        '${task.seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 0.7,
        ),
      ),
      child: InkWell(
        onTap: () => _startTimerPage(context),
        borderRadius: _borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 26),
          child: Row(
            children: <Widget>[
              // 작은 컬러 동그라미
              Container(
                margin: const EdgeInsets.only(
                    left: 8.0, right: 12.0, top: 8.0, bottom: 8.0),
                width: 15.0,
                height: 15.0,
                decoration: BoxDecoration(
                  color: task.color,
                  shape: BoxShape.circle,
                ),
              ),

              // 제목 + Duration
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Duration: ${_formatDuration()}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 오른쪽 화살표
              Icon(
                Icons.navigate_next,
                color: task.color,
                size: 28,
              )
            ],
          ),
        ),
      ),
    );
  }
}
