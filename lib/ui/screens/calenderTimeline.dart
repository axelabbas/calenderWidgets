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
  List jsData = [];
  Future<List> readJson() async {
    final String response = await rootBundle.loadString('assets/events.json');
    final data = await json.decode(response);
    return data;
  }

  getEventsInDate(List data, DateTime date) {
    return data
        .where((element) =>
            isSameDate(DateTime.parse(element["start"]["dateTime"]), date))
        .toList();
  }

  final DatePickerController _controller = DatePickerController();
  List events = [];
  bool isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () {
                setState(() {
                  _controller.animateToNextEvent();
                  _selectedValue = _controller.getCurrentDate();
                  events = getEventsInDate(jsData, _selectedValue);
                });
              },
              child: Icon(Icons.arrow_right_outlined)),
        ],
        title: InkWell(
            onTap: () {
              setState(() {
                _controller.animateToPreviousEvent();
                _selectedValue = _controller.getCurrentDate();
                events = getEventsInDate(jsData, _selectedValue);
              });
            },
            child: Icon(Icons.arrow_left_outlined)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // _controller.animateToNextEvent();
            // _selectedValue = _controller.getCurrentDate();
            // events = getEventsInDate(jsData, _selectedValue);

            _controller.setDateAndAnimate(DateTime.now());
            _selectedValue = _controller.getCurrentDate();
            events = getEventsInDate(jsData, _selectedValue);
          });
        },
      ),
      body: FutureBuilder(
        future: readJson(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            jsData = snapshot.data!;
            jsData.sort((a, b) => DateTime.parse(a['start']['dateTime'])
                .compareTo(DateTime.parse(b['start']['dateTime'])));
            ;
            events = getEventsInDate(jsData, _selectedValue);

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
                    events: jsData,
                    height: 100,
                    iconSize: 10,
                    width: 50,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 800),
                    onDateChange: (date) {
                      // New date selected
                      setState(() {
                        _selectedValue = date;
                        events = getEventsInDate(jsData, _selectedValue);
                      });
                    },
                  ),
                  Container(
                    height: 500,
                    child: ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.black),
                          child: Column(children: [
                            Text(events[index]["summary"]),
                            Text(events[index]["description"]),
                          ]),
                        );
                      },
                    ),
                  )
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

  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}
