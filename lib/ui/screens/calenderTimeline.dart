import 'dart:convert';

import 'package:calendarevents/CustomDatePicker/date_picker_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class timelineScreen extends StatefulWidget {
  const timelineScreen({super.key});

  @override
  State<timelineScreen> createState() => _timelineScreenState();
}

class _timelineScreenState extends State<timelineScreen> {
  DateTime _selectedValue = DateTime.now();
  Future<List> readJson() async {
    final String response = await rootBundle.loadString('assets/events.json');
    final data = await json.decode(response);
    return data;
  }

  final DatePickerController _controller = DatePickerController();
  String events = "none";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.animateToNextEvent();
            dateToEvent(_controller.getCurrentDate());
            // _controller.setDateAndAnimate(DateTime.now());
            // dateToEvent(DateTime.now());
          });
        },
      ),
      body: FutureBuilder(
        future: readJson(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: <Widget>[
                  DatePicker(
                    DateTime.now().subtract(const Duration(days: 100)),
                    initialSelectedDate: DateTime.now(),
                    controller: _controller,
                    selectionColor: Colors.black,
                    selectedTextColor: Colors.white,
                    shouldAnimate: true,
                    events: snapshot.data!,
                    height: 100,
                    iconSize: 10,
                    width: 50,
                    curve: Curves.easeOut,
                    duration: Duration(milliseconds: 800),
                    onDateChange: (date) {
                      // New date selected
                      setState(() {
                        _selectedValue = date;
                        dateToEvent(_controller.getCurrentDate());
                      });
                    },
                  ),
                  Text(events)
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
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
