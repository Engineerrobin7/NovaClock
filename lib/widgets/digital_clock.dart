import 'package:flutter/material.dart';

class DigitalClock extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? textStyle;
  final bool show24HourFormat;

  const DigitalClock({
    super.key,
    required this.dateTime,
    this.textStyle,
    this.show24HourFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    final hour = show24HourFormat
        ? dateTime.hour
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    final timeString = show24HourFormat
        ? '$hour:$minute:$second'
        : '$hour:$minute:$second $period';

    return Text(
      timeString,
      style: textStyle ??
          const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
    );
  }
}
