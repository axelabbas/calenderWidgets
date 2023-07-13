import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class calenderScreen extends StatefulWidget {
  const calenderScreen({super.key});

  @override
  State<calenderScreen> createState() => _calenderScreenState();
}

class _calenderScreenState extends State<calenderScreen> {
  @override
  void initState() {
    super.initState();

    print("started");
  }

  Future<List> readJson() async {
    final String response = await rootBundle.loadString('assets/events.json');
    final data = await json.decode(response);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    List eventsOfSelectedDate = [];
    return Scaffold(
      body: FutureBuilder(
        future: readJson(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SfCalendar(
              view: CalendarView.month,
              dataSource: EventDataSource(snapshot.data!),
              initialSelectedDate: DateTime.now(),
              cellBorderColor: Colors.transparent,
              onLongPress: (detials) {
                setState(() {
                  selectedDate = detials.date!;
                });
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List events) {
    appointments = events;
  }

  getEvent(int index) => appointments![index];

  @override
  DateTime getStartTime(int index) {
    // TODO: implement getStartTime
    return DateTime.parse(getEvent(index)["start"]["dateTime"]);
  }

  @override
  DateTime getEndTime(int index) {
    // TODO: implement getEndTime
    return DateTime.parse(getEvent(index)["end"]["dateTime"]);
  }

  @override
  String getSubject(int index) {
    // TODO: implement getSubject
    return getEvent(index)["summary"];
  }

  @override
  Color getColor(int index) {
    // TODO: implement getColor
    return Colors.blue;
  }

  @override
  bool isAllDay(int index) {
    // TODO: implement isAllDay
    return false;
  }
}
