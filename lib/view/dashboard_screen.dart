import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/bottom_bar.dart';

import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:pebbl/view/home/audio_player.dart';

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
    //check status and act accordingly

    if (audioSet.status == AudioSetStatus.notDownloaded) {
      //download set
      context.read<SetsPresenter>().downloadSet(audioSet);
    } else if (audioSet.status == AudioSetStatus.downloaded) {
      context.read<SetsPresenter>().setActiveSet(audioSet);
      context.read<SetsPresenter>().setSoundscapeManager();

      setState(() {
        _activeIndex = -1;
      });
    }
  }

  Widget _viewForIndex() {
    if (_activeIndex == -1) return AudioPlayer();
    if (_activeIndex == 0) return SetsList(onSetSelected: _newSetSelected);
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = context.select<SetsPresenter, bool>((value) => value.isInitialized);
    final colorTheme = AppColors.getActiveColorTheme(context);
    return Scaffold(
      backgroundColor: colorTheme.backgroundColor,
      body: !isInitialized
          ? const SizedBox()
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Center(
                        child: _viewForIndex(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                          child: Text('Sign-out'),
                          onPressed: () async {
                            await context.read<UserPresenter>().signOut();
                          }),
                    ],
                  ),
                  const SizedBox(height: 16),
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
