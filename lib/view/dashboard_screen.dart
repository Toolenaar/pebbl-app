import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/local_notification_helper.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/view/components/animation_view.dart';
import 'package:pebbl/view/components/bottom_bar.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:pebbl/view/home/audio_test.dart';
import 'package:pebbl/view/home/favorites/favorites_page.dart';
import 'package:pebbl/view/home/timer/timer_view.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeIndex = -1;
  SetsPresenter _setsPresenter;

  @override
  void initState() {
    super.initState();
    context.read<LocalNotificationHelper>().initLocalNotifications(context);
    _setsPresenter = context.read<SetsPresenter>();
    _setsPresenter.init();
    context.read<TimerPresenter>().init();
  }

  @override
  void dispose() {
    context.read<AudioController>().dispose();

    super.dispose();
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

  void _newCategorySelected(GroupedByCategory categoryGroup) {
    //check status and act accordingly
    context.read<SetsPresenter>().setActiveCategory(categoryGroup.category);
    context.read<AudioController>().shuffleStartPlaylist(categoryGroup.sets, startPlaying: true);
    setState(() {
      _activeIndex = -1;
    });
  }

  Widget _viewForIndex() {
    if (_activeIndex == -1) {
      return Positioned.fill(child: AudioTest());
    }
    if (_activeIndex == 1) {
      return Positioned(bottom: 0, left: 0, right: 0, child: TimerView());
    }
    if (_activeIndex == 0) {
      return Positioned.fill(
        child: SetsList(
          onCategorySelected: _newCategorySelected,
          close: () {
            setState(() {
              _activeIndex = -1;
            });
          },
        ),
      );
    }
    if (_activeIndex == 2) {
      return Positioned.fill(child: FavoritesPage());
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = context.select<SetsPresenter, bool>((value) => value.isInitialized);
    final colorTheme = AppColors.getActiveColorTheme(context);
    final activeView = _viewForIndex();
    return Scaffold(
      backgroundColor: colorTheme.backgroundColor,
      body: !isInitialized
          ? const SizedBox()
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: [
                        if (_setsPresenter.activeCategory != null)
                          AnimationView(
                            animationFile: _setsPresenter.activeCategory.animationFileName,
                          ),
                        activeView
                      ],
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     RaisedButton(
                  //         child: Text('Sign-out'),
                  //         onPressed: () async {
                  //           await context.read<UserPresenter>().signOut();
                  //         }),
                  //   ],
                  // ),
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
