import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xtimer/model/task_model.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key? key}) : super(key: key);

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  late TextEditingController _titleController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const int max_hours = 24;
  static const int max_minutes = 60;
  static const int max_seconds = 60;
  static const int _maxTitleLength = 30;

  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedSecond = 0;

  Color getRandomColor() {
    Random r = Random();
    var colorsList = Colors.primaries;
    return colorsList[r.nextInt(colorsList.length)];
  }

  void _saveTaskAndClose() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text;
    final color = getRandomColor();

    final task = Task(
      color: color,
      title: title,
      hours: _selectedHour,
      minutes: _selectedMinute,
      seconds: _selectedSecond,
    );

    Navigator.of(context).pop(task);
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _titleController,
              maxLength: _maxTitleLength,
              decoration: const InputDecoration(
                hintText: 'Task Title',
                counterText: '',
                filled: true,
              ),
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Task title is required.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Duration',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: _Selector<int>(
                    items: List.generate(max_hours, (i) => i),
                    itemBuilder: (i) => "$i h",
                    onSelectedItemChanged: (value) {
                      _selectedHour = value;
                    },
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: _Selector<int>(
                    items: List.generate(max_minutes, (i) => i),
                    itemBuilder: (i) => "$i m",
                    onSelectedItemChanged: (value) {
                      _selectedMinute = value;
                    },
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: _Selector<int>(
                    items: List.generate(max_seconds, (i) => i),
                    itemBuilder: (i) => "$i s",
                    onSelectedItemChanged: (value) {
                      _selectedSecond = value;
                    },
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: _saveTaskAndClose,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'SAVE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Selector<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T> onSelectedItemChanged;

  const _Selector({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
  }) : super(key: key);

  @override
  _SelectorState<T> createState() => _SelectorState<T>();
}

class _SelectorState<T> extends State<_Selector<T>> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      itemExtent: 60,
      childCount: widget.items.length,
      backgroundColor: Colors.transparent,
      itemBuilder: (context, index) {
        final isSelected = _currentIndex == index;
        final item = widget.items[index];

        return Center(
          child: Text(
            widget.itemBuilder(item),
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
              fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
      onSelectedItemChanged: (i) {
        setState(() {
          _currentIndex = i;
          widget.onSelectedItemChanged(widget.items[i]);
        });
      },
    );
  }
}
