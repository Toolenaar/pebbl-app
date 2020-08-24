import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/presenter/timer_presenter.dart';

class CountdownTimerView extends StatefulWidget {
  final double fontSize;
  final Color color;
  final String time;
  const CountdownTimerView({
    Key key,
    this.time,
    this.fontSize = 32,
    this.color,
  }) : super(key: key);
  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<CountdownTimerView> {
  Stream<String> countdownTimeStream;

  @override
  void initState() {
    countdownTimeStream = context.read<TimerPresenter>().timeDisplayStream;
    super.initState();
  }

  Widget _buildText(String time) {
    return BodyText2(
      time,
      color: widget.color,
      fontSize: widget.fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.time != null) {
      _buildText(widget.time);
    }
    return StreamBuilder<String>(
      stream: countdownTimeStream,
      initialData: '',
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return _buildText(snapshot.data);
      },
    );
  }
}
