import 'package:calendarevents/CustomDatePicker/date_picker_widget.dart';

import 'package:flutter/material.dart';

class timelineScreen extends StatefulWidget {
  const timelineScreen({super.key});

  @override
  State<timelineScreen> createState() => _timelineScreenState();
}

class _timelineScreenState extends State<timelineScreen> {
  DateTime _selectedValue = DateTime.now();

  DatePickerController _controller = DatePickerController();
  String events = "none";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: <Widget>[
            DatePicker(
              DateTime.now().subtract(Duration(days: 100)),
              initialSelectedDate: DateTime.now(),
              controller: _controller,
              selectionColor: Colors.black,
              selectedTextColor: Colors.white,
              shouldAnimate: true,
              curve: Curves.easeOut,
              duration: Duration(seconds: 1),
              onDateChange: (date) {
                // New date selected
                setState(() {
                  _selectedValue = date;
                  dateToEvent(date);
                });
              },
            ),
            Text("$events")
          ],
        ),
      ),
    );
  }

  dateToEvent(DateTime date) {
    events = date.toString();
  }

  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}
