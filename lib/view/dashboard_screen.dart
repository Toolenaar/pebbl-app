import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/view/components/bottom_bar.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:pebbl/view/home/audio_test.dart';
import 'package:pebbl/view/home/favorites/favorites_page.dart';
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
      return AudioTest();
    }
    if (_activeIndex == 0) {
      return SetsList(
        onCategorySelected: _newCategorySelected,
        close: () {
          setState(() {
            _activeIndex = -1;
          });
        },
      );
    }
    if (_activeIndex == 2) {
      return FavoritesPage();
    }
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
