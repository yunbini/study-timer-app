import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// NumberPicker is a widget designed to pick a number between [minValue] and [maxValue]
class NumberPicker extends StatelessWidget {
  /// height of every list element
  static const double defaultItemExtent = 50.0;

  /// width of list view
  static const double defaultListviewWidth = 100.0;

  /// called when selected value changes
  final ValueChanged<num> onChanged;

  /// min value user can pick
  final int minValue;

  /// max value user can pick
  final int maxValue;

  /// inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  /// height of every list element in pixels
  final double itemExtent;

  /// view will always contain only 3 elements of list in pixels
  final double _listViewHeight;

  /// width of list view in pixels
  final double listViewWidth;

  /// ScrollController used for integer list
  final ScrollController intScrollController;

  /// ScrollController used for decimal list (nullable)
  final ScrollController? decimalScrollController;

  /// Currently selected integer value
  final int selectedIntValue;

  /// Currently selected decimal value
  final int selectedDecimalValue;

  /// Step between elements. Only for integer datePicker
  final int step;

  final Axis scrollDirection;

  /// constructor for integer number picker - horizontal
  NumberPicker.horizontal({
    Key? key,
    required int initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListviewWidth + 50,
    this.step = 1,
    this.scrollDirection = Axis.horizontal,
  })  : assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(step > 0),
        selectedIntValue = initialValue,
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = ScrollController(
          initialScrollOffset:
          ((initialValue - minValue) ~/ step) * itemExtent,
        ),
        decimalScrollController = null,
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  /// constructor for integer number picker - vertical
  NumberPicker.integer({
    Key? key,
    required int initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListviewWidth,
    this.step = 1,
    this.scrollDirection = Axis.vertical,
  })  : assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(step > 0),
        selectedIntValue = initialValue,
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = ScrollController(
          initialScrollOffset:
          ((initialValue - minValue) ~/ step) * itemExtent,
        ),
        decimalScrollController = null,
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  /// constructor for decimal number picker
  NumberPicker.decimal({
    Key? key,
    required double initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.decimalPlaces = 1,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListviewWidth,
    this.scrollDirection = Axis.vertical,
  })  : assert(decimalPlaces > 0),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedIntValue = initialValue.floor(),
        selectedDecimalValue = ((initialValue - initialValue.floorToDouble()) *
            math.pow(10, decimalPlaces))
            .round(),
        intScrollController = ScrollController(
          initialScrollOffset:
          (initialValue.floor() - minValue) * itemExtent,
        ),
        decimalScrollController = ScrollController(
          initialScrollOffset: ((initialValue -
              initialValue.floorToDouble()) *
              math.pow(10, decimalPlaces))
              .roundToDouble() *
              itemExtent,
        ),
        _listViewHeight = 3 * itemExtent,
        step = 1,
        super(key: key);

  //
  //----------------------------- PUBLIC ------------------------------
  //

  void animateInt(int valueToSelect) {
    final diff = valueToSelect - minValue;
    final index = diff ~/ step;
    _animate(intScrollController, index * itemExtent);
  }

  void animateDecimal(int decimalValue) {
    if (decimalScrollController == null) return;
    _animate(decimalScrollController!, decimalValue * itemExtent);
  }

  void animateDecimalAndInteger(double valueToSelect) {
    animateInt(valueToSelect.floor());
    animateDecimal(
      ((valueToSelect - valueToSelect.floorToDouble()) *
          math.pow(10, decimalPlaces))
          .round(),
    );
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (decimalPlaces == 0) {
      return _integerListView(themeData);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _integerListView(themeData),
          _decimalListView(themeData),
        ],
      );
    }
  }

  Widget _integerListView(ThemeData themeData) {
    final TextStyle defaultStyle =
        themeData.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final TextStyle selectedStyle = (themeData.textTheme.headlineSmall ??
        const TextStyle(fontSize: 18))
        .copyWith(color: themeData.colorScheme.secondary);

    final int itemCount = (maxValue - minValue) ~/ step + 3;

    return NotificationListener<ScrollNotification>(
      onNotification: _onIntegerNotification,
      child: SizedBox(
        height: _listViewHeight / 3,
        width: listViewWidth,
        child: ListView.builder(
          scrollDirection: scrollDirection,
          controller: intScrollController,
          itemExtent: itemExtent,
          itemCount: itemCount,
          cacheExtent: _calculateCacheExtent(itemCount),
          itemBuilder: (BuildContext context, int index) {
            final int value = _intValueFromIndex(index);

            final TextStyle itemStyle =
            value == selectedIntValue ? selectedStyle : defaultStyle;

            final bool isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? const SizedBox.shrink()
                : Center(
              child: Text(
                value.toString(),
                style: itemStyle,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _decimalListView(ThemeData themeData) {
    final TextStyle defaultStyle =
        themeData.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final TextStyle selectedStyle = (themeData.textTheme.headlineSmall ??
        const TextStyle(fontSize: 18))
        .copyWith(color: themeData.colorScheme.secondary);

    final int itemCount = selectedIntValue == maxValue
        ? 3
        : math.pow(10, decimalPlaces).toInt() + 2;

    return NotificationListener<ScrollNotification>(
      onNotification: _onDecimalNotification,
      child: SizedBox(
        height: _listViewHeight,
        width: listViewWidth,
        child: ListView.builder(
          controller: decimalScrollController,
          itemExtent: itemExtent,
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            final int value = index - 1;

            final TextStyle itemStyle =
            value == selectedDecimalValue ? selectedStyle : defaultStyle;

            final bool isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? const SizedBox.shrink()
                : Center(
              child: Text(
                value.toString().padLeft(decimalPlaces, '0'),
                style: itemStyle,
              ),
            );
          },
        ),
      ),
    );
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  int _intValueFromIndex(int index) => minValue + (index - 1) * step;

  bool _onIntegerNotification(ScrollNotification notification) {
    final metrics = notification.metrics;

    final int intIndexOfMiddleElement =
    ((metrics.pixels + _listViewHeight / 2) / itemExtent).floor();
    int intValueInTheMiddle = _intValueFromIndex(intIndexOfMiddleElement);
    intValueInTheMiddle = _normalizeIntegerMiddleValue(intValueInTheMiddle);

    if (_userStoppedScrolling(notification)) {
      animateInt(intValueInTheMiddle);
    }

    if (intValueInTheMiddle != selectedIntValue) {
      num newValue;
      if (decimalPlaces == 0) {
        newValue = intValueInTheMiddle;
      } else {
        if (intValueInTheMiddle == maxValue) {
          newValue = intValueInTheMiddle.toDouble();
          animateDecimal(0);
        } else {
          final double decimalPart = _toDecimal(selectedDecimalValue);
          newValue = (intValueInTheMiddle + decimalPart).toDouble();
        }
      }
      onChanged(newValue);
    }

    return true;
  }

  bool _onDecimalNotification(ScrollNotification notification) {
    if (decimalScrollController == null) return true;

    final metrics = notification.metrics;

    int indexOfMiddleElement =
    ((metrics.pixels + _listViewHeight / 2) / itemExtent).floor();
    int decimalValueInTheMiddle = indexOfMiddleElement - 1;
    decimalValueInTheMiddle =
        _normalizeDecimalMiddleValue(decimalValueInTheMiddle);

    if (_userStoppedScrolling(notification)) {
      animateDecimal(decimalValueInTheMiddle);
    }

    if (selectedIntValue != maxValue &&
        decimalValueInTheMiddle != selectedDecimalValue) {
      final double decimalPart = _toDecimal(decimalValueInTheMiddle);
      final double newValue =
      (selectedIntValue + decimalPart).toDouble();
      onChanged(newValue);
    }

    return true;
  }

  double _calculateCacheExtent(int itemCount) {
    double cacheExtent = 250.0;
    if ((itemCount - 2) * defaultItemExtent <= cacheExtent) {
      cacheExtent = ((itemCount - 3) * defaultItemExtent);
    }
    return cacheExtent;
  }

  int _normalizeMiddleValue(int valueInTheMiddle, int min, int max) {
    return math.max(math.min(valueInTheMiddle, max), min);
  }

  int _normalizeIntegerMiddleValue(int integerValueInTheMiddle) {
    final int max = (maxValue ~/ step) * step;
    return _normalizeMiddleValue(integerValueInTheMiddle, minValue, max);
  }

  int _normalizeDecimalMiddleValue(int decimalValueInTheMiddle) {
    return _normalizeMiddleValue(
      decimalValueInTheMiddle,
      0,
      math.pow(10, decimalPlaces).toInt() - 1,
    );
  }

  /// indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(ScrollNotification notification) {
    return notification is ScrollEndNotification;
  }

  double _toDecimal(int decimalValueAsInteger) {
    return double.parse(
      (decimalValueAsInteger * math.pow(10, -decimalPlaces))
          .toStringAsFixed(decimalPlaces),
    );
  }

  void _animate(ScrollController controller, double value) {
    controller.animateTo(
      value,
      duration: const Duration(seconds: 1),
      curve: const ElasticOutCurve(),
    );
  }
}

/// Returns AlertDialog as a Widget so it is designed to be used in showDialog method
class NumberPickerDialog extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int? initialIntegerValue;
  final double? initialDoubleValue;
  final int decimalPlaces;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final Widget confirmWidget;
  final Widget cancelWidget;
  final int step;

  /// constructor for integer values
  NumberPickerDialog.integer({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.initialIntegerValue,
    this.title,
    this.titlePadding,
    this.step = 1,
    Widget? confirmWidget,
    Widget? cancelWidget,
  })  : confirmWidget = confirmWidget ?? const Text("OK"),
        cancelWidget = cancelWidget ?? const Text("CANCEL"),
        decimalPlaces = 0,
        initialDoubleValue = null,
        super(key: key);

  /// constructor for decimal values
  NumberPickerDialog.decimal({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.initialDoubleValue,
    this.decimalPlaces = 1,
    this.title,
    this.titlePadding,
    Widget? confirmWidget,
    Widget? cancelWidget,
  })  : confirmWidget = confirmWidget ?? const Text("OK"),
        cancelWidget = cancelWidget ?? const Text("CANCEL"),
        initialIntegerValue = null,
        step = 1,
        super(key: key);

  @override
  State<NumberPickerDialog> createState() =>
      _NumberPickerDialogControllerState(
        initialIntegerValue,
        initialDoubleValue,
      );
}

class _NumberPickerDialogControllerState extends State<NumberPickerDialog> {
  int? selectedIntValue;
  double? selectedDoubleValue;

  _NumberPickerDialogControllerState(
      this.selectedIntValue, this.selectedDoubleValue);

  void _handleValueChanged(num value) {
    if (value is int) {
      setState(() => selectedIntValue = value);
    } else {
      setState(() => selectedDoubleValue = value.toDouble());
    }
  }

  NumberPicker _buildNumberPicker() {
    if (widget.decimalPlaces > 0) {
      return NumberPicker.decimal(
        initialValue: selectedDoubleValue ?? widget.initialDoubleValue ?? 0.0,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        decimalPlaces: widget.decimalPlaces,
        onChanged: _handleValueChanged,
      );
    } else {
      return NumberPicker.integer(
        initialValue: selectedIntValue ?? widget.initialIntegerValue ?? 0,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        step: widget.step,
        onChanged: _handleValueChanged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      content: _buildNumberPicker(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: widget.cancelWidget,
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            widget.decimalPlaces > 0
                ? selectedDoubleValue ?? widget.initialDoubleValue
                : selectedIntValue ?? widget.initialIntegerValue,
          ),
          child: widget.confirmWidget,
        ),
      ],
    );
  }
}
