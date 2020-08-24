import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pebbl/logic/date_helper.dart';
import 'package:pebbl/logic/texts.dart';

class CountdownTimerView extends StatefulWidget {
  final DateTime dateTime;
  final double fontSize;
  final String initialDisplay;
  final Color color;
  const CountdownTimerView({
    Key key,
    this.dateTime,
    this.initialDisplay,
    this.fontSize = 32,
    this.color,
  }) : super(key: key);
  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<CountdownTimerView> {
  var timerCountDown = '00:00:00';
  Color colors = Colors.red;
  DateTime dateCheck;
  Timer timer;
  DateTime dateTimeStart;

  @override
  void initState() {
    timerCountDown = widget.initialDisplay ?? '00:00:00';
    if (widget.dateTime == null) {
      dateTimeStart = DateTime.now();
    } else {
      dateTimeStart = widget.dateTime;
    }
    if (widget.color != null) {
      colors = widget.color;
    }
    dateCheck = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStart.toString());

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setJustTime();
    });
    setJustTime(setTheState: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setJustTime({bool setTheState = true}) {
    final seconds = dateCheck.difference(DateTime.now()).inSeconds;
    if (!mounted) return;

    if (widget.dateTime.isBefore(DateTime.now())) {
      timerCountDown = '00:00:00';
    } else {
      timerCountDown = DateHelper.secondsToHoursMinutesSeconds(seconds);
    }
    if (setTheState) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          BodyText2(
            timerCountDown,
            color: widget.color,
            fontSize: widget.fontSize,
          ),
        ],
      ),
    );
  }
}
