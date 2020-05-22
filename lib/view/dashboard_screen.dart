import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/view/components/bottom_bar.dart';
import 'package:pebbl/view/components/set_center_piece.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      if (index == _activeIndex) {
        _activeIndex = -1;
      } else {
        _activeIndex = index;
      }
    });
  }

  Widget _viewForIndex() {
    if (_activeIndex == -1) return SetCenterpiece();
    if (_activeIndex == 0) return SetsList();
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: _viewForIndex(),
                ),
              ),
            ),
            BottomBar(
              activeIndex: _activeIndex,
              onTabChanged: _onTabChanged,
            )
          ],
        ),
      ),
    );
  }
}
