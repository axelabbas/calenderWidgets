import 'package:calendarevents/CustomDatePicker/date_widget.dart';
import 'package:calendarevents/CustomDatePicker/extra/color.dart';
import 'package:calendarevents/CustomDatePicker/extra/style.dart';
import 'package:calendarevents/CustomDatePicker/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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

class DatePicker extends StatefulWidget {
  /// Start Date in case user wants to show past dates
  /// If not provided calendar will start from the initialSelectedDate
  final DateTime startDate;

  /// Width of the selector
  final double width;

  // added
  final bool shouldAnimate;
  final Curve curve;
  final Duration duration;
  final List events;
  final double iconSize;

  /// Height of the selector
  final double height;

  /// DatePicker Controller
  final DatePickerController? controller;

  /// Text color for the selected Date
  final Color selectedTextColor;

  /// Background color for the selector
  final Color selectionColor;

  /// Text Color for the deactivated dates
  final Color deactivatedColor;

  /// TextStyle for Month Value
  final TextStyle monthTextStyle;

  /// TextStyle for day Value
  final TextStyle dayTextStyle;

  /// TextStyle for the date Value
  final TextStyle dateTextStyle;

  /// Current Selected Date
  final DateTime? /*?*/ initialSelectedDate;

  /// Contains the list of inactive dates.
  /// All the dates defined in this List will be deactivated
  final List<DateTime>? inactiveDates;

  /// Contains the list of active dates.
  /// Only the dates in this list will be activated.
  final List<DateTime>? activeDates;

  /// Callback function for when a different date is selected
  final DateChangeListener? onDateChange;

  /// Max limit up to which the dates are shown.
  /// Days are counted from the startDate
  final int daysCount;

  /// Locale for the calendar default: en_us
  final String locale;

  const DatePicker(
    this.startDate, {
    super.key,
    this.width = 60,
    this.height = 80,
    this.controller,
    required this.events,
    required this.iconSize,
    required this.duration,
    required this.shouldAnimate,
    required this.curve,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.deactivatedColor = AppColors.defaultDeactivatedColor,
    this.initialSelectedDate,
    this.activeDates,
    this.inactiveDates,
    this.daysCount = 500,
    this.onDateChange,
    this.locale = "en_US",
  }) : assert(
            activeDates == null || inactiveDates == null,
            "Can't "
            "provide both activated and deactivated dates List at the same time.");

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _currentDate;

  final ScrollController _controller = ScrollController();

  late final TextStyle selectedDateStyle;
  late final TextStyle selectedMonthStyle;
  late final TextStyle selectedDayStyle;

  late final TextStyle deactivatedDateStyle;
  late final TextStyle deactivatedMonthStyle;
  late final TextStyle deactivatedDayStyle;

  @override
  void initState() {
    // Init the calendar locale
    initializeDateFormatting(widget.locale, null);
    // Set initial Values
    _currentDate = widget.initialSelectedDate;

    if (widget.controller != null) {
      widget.controller!.setDatePickerState(this);
    }

    selectedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.selectedTextColor);
    selectedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.selectedTextColor);
    selectedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.selectedTextColor);

    deactivatedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.deactivatedColor);
    deactivatedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.deactivatedColor);
    deactivatedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.deactivatedColor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSameDate(DateTime first, DateTime second) {
      return first.year == second.year &&
          first.month == second.month &&
          first.day == second.day;
    }

    bool firstTimeAnimating = true;
    double _calculateDateOffset(DateTime date) {
      final startDate = DateTime(
          widget.startDate.year, widget.startDate.month, widget.startDate.day);
      int offset = date.difference(startDate).inDays;
      return ((offset + 2) * widget.width);
    }

    // animate to the current date

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        itemCount: widget.daysCount,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        itemBuilder: (context, index) {
          if (widget.shouldAnimate) {
            if (firstTimeAnimating) {
              _controller.animateTo(_calculateDateOffset(_currentDate!),
                  duration: widget.duration, curve: widget.curve);
              firstTimeAnimating = false;
            }
          }

          // get the date object based on the index position
          // if widget.startDate is null then use the initialDateValue
          DateTime date;
          DateTime date0 = widget.startDate.add(Duration(days: index));

          date = DateTime(date0.year, date0.month, date0.day);

          bool isDeactivated = false;

          // check if this date needs to be deactivated for only DeactivatedDates
          if (widget.inactiveDates != null) {
//            print("Inside Inactive dates.");
            for (DateTime inactiveDate in widget.inactiveDates!) {
              if (_compareDate(date, inactiveDate)) {
                isDeactivated = true;
                break;
              }
            }
          }

          // check if this date needs to be deactivated for only ActivatedDates
          if (widget.activeDates != null) {
            isDeactivated = true;
            for (DateTime activateDate in widget.activeDates!) {
              // Compare the date if it is in the
              if (_compareDate(date, activateDate)) {
                isDeactivated = false;
                break;
              }
            }
          }

          // Check if this date is the one that is currently selected
          bool isSelected =
              _currentDate != null ? _compareDate(date, _currentDate!) : false;
          List todayEvents = widget.events
              .map((event) =>
                  (isSameDate(DateTime.parse(event['start']['dateTime']), date)
                      ? true
                      : false))
              .toList();
          // Return the Date Widget
          DateWidget datewidget = DateWidget(
            iconSize: widget.iconSize,
            eventCount: todayEvents.where((item) => item == true).length,
            date: date,
            monthTextStyle: isDeactivated
                ? deactivatedMonthStyle
                : isSelected
                    ? selectedMonthStyle
                    : widget.monthTextStyle,
            dateTextStyle: isDeactivated
                ? deactivatedDateStyle
                : isSelected
                    ? selectedDateStyle
                    : widget.dateTextStyle,
            dayTextStyle: isDeactivated
                ? deactivatedDayStyle
                : isSelected
                    ? selectedDayStyle
                    : widget.dayTextStyle,
            width: widget.width,
            locale: widget.locale,
            selectionColor:
                isSelected ? widget.selectionColor : Colors.transparent,
            onDateSelected: (selectedDate) {
              // Don't notify listener if date is deactivated
              if (isDeactivated) return;

              // A date is selected
              if (widget.onDateChange != null) {
                widget.onDateChange!(selectedDate);
              }
              setState(() {
                _currentDate = selectedDate;
              });
            },
          );
          return datewidget;
        },
      ),
    );
  }

  /// Helper function to compare two dates
  /// Returns True if both dates are the same
  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}

class DatePickerController {
  _DatePickerState? _datePickerState;

  void setDatePickerState(_DatePickerState state) {
    _datePickerState = state;
  }

  DateTime getCurrentDate() {
    return _datePickerState!._currentDate!;
  }

  void jumpToSelection() {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // jump to the current Date
    _datePickerState!._controller
        .jumpTo(_calculateDateOffset(_datePickerState!._currentDate!));
  }

  /// This function will animate the Timeline to the currently selected Date
  void animateToSelection(
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // animate to the current date
    _datePickerState!._controller.animateTo(
        _calculateDateOffset(_datePickerState!._currentDate!),
        duration: duration,
        curve: curve);
  }

  bool isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void animateToNextEvent(
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    final nextEvent = _datePickerState!.widget.events.firstWhere(
      (event) {
        DateTime nextEventTime = DateTime.parse(event['start']['dateTime']);
        DateTime? currentTime = _datePickerState!._currentDate;

        return (currentTime!.isBefore(nextEventTime) &&
            (isSameDate(nextEventTime, currentTime) == false));
      },
      orElse: () {
        return -1;
      },
    );
    if (nextEvent == -1) {
      return;
    }
    DateTime nextEventDate = DateTime.parse(nextEvent['start']['dateTime']);
    setDateAndAnimate(nextEventDate, curve: curve, duration: duration);
  }

  void animateToPreviousEvent(
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    final nextEvent = _datePickerState!.widget.events.lastWhere(
      (event) {
        DateTime nextEventTime = DateTime.parse(event['start']['dateTime']);
        DateTime? currentTime = _datePickerState!._currentDate;
        return (currentTime!.isAfter(nextEventTime) &&
            (isSameDate(nextEventTime, currentTime) == false));
      },
      orElse: () {
        return -1;
      },
    );
    if (nextEvent == -1) {
      return;
    }
    DateTime nextEventDate = DateTime.parse(nextEvent['start']['dateTime']);
    setDateAndAnimate(nextEventDate, curve: curve, duration: duration);
  }

  /// This function will animate to any date that is passed as an argument
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    _datePickerState!._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// this will also set that date as the current selected date
  void setDateAndAnimate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    _datePickerState!._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);

    if (date.compareTo(_datePickerState!.widget.startDate) >= 0 &&
        date.compareTo(_datePickerState!.widget.startDate
                .add(Duration(days: _datePickerState!.widget.daysCount))) <=
            0) {
      // date is in the range
      _datePickerState!._currentDate = date;
    }
  }

  /// Calculate the number of pixels that needs to be scrolled to go to the
  /// date provided in the argument
  double _calculateDateOffset(DateTime date) {
    final startDate = DateTime(
        _datePickerState!.widget.startDate.year,
        _datePickerState!.widget.startDate.month,
        _datePickerState!.widget.startDate.day);

    int offset = date.difference(startDate).inDays;
    return (offset * _datePickerState!.widget.width) + (offset * 6);
  }
}
