/// ***
/// This class consists of the DateWidget that is used in the ListView.builder
///
/// Author: Vivek Kaushik <me@vivekkasuhik.com>
/// github: https://github.com/iamvivekkaushik/
/// ***

import "package:calendarevents/CustomDatePicker/gestures/tap.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final double? width;
  final DateTime date;
  final TextStyle? monthTextStyle, dayTextStyle, dateTextStyle;
  final Color selectionColor;
  final DateSelectionCallback? onDateSelected;
  final String? locale;
  final int? eventCount;
  final double? iconSize;

  const DateWidget({
    super.key,
    required this.date,
    required this.iconSize,
    required this.monthTextStyle,
    required this.dayTextStyle,
    required this.dateTextStyle,
    required this.selectionColor,
    this.width,
    required this.eventCount,
    this.onDateSelected,
    this.locale,
  });

  int? getEventCount() {
    return eventCount;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: width,
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          color: selectionColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                  DateFormat("MMM", locale).format(date).toUpperCase(), // Month
                  style: monthTextStyle),
              Text(date.day.toString(), // Date
                  style: dateTextStyle),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: countToDots(eventCount),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        // Check if onDateSelected is not null
        if (onDateSelected != null) {
          // Call the onDateSelected Function
          onDateSelected!(date);
        }
      },
    );
  }

  countToDots(amount) {
    List<Widget> widgets = [];
    for (int i = 0; i < amount; i++) {
      widgets.add(Icon(
        Icons.circle,
        size: iconSize,
      ));
    }
    return widgets;
  }
}
