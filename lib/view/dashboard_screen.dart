import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/view/components/bottom_bar.dart';
import 'package:pebbl/view/components/set_center_piece.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<SetsPresenter>().init();
  }

  void _onTabChanged(int index) {
    setState(() {
      if (index == _activeIndex) {
        _activeIndex = -1;
      } else {
        _activeIndex = index;
      }
    });
  }

  void _newSetSelected(AudioSet audioSet) {
    context.read<SetsPresenter>().setActiveSet(audioSet);
    setState(() {
      _activeIndex = -1;
    });
    //TODO start playing
  }

  Widget _viewForIndex() {
    if (_activeIndex == -1) return SetCenterpiece();
    if (_activeIndex == 0) return SetsList(onSetSelected: _newSetSelected);
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
