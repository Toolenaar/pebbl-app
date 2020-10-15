import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/local_notification_helper.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/view/components/animation_view.dart';
import 'package:pebbl/view/components/bottom_bar.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:pebbl/view/home/audio_view.dart';
import 'package:pebbl/view/home/favorites/favorites_page.dart';
import 'package:pebbl/view/home/timer/timer_view.dart';
import 'package:pebbl/view/home/tutorial_view.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeIndex = -1;
  SetsPresenter _setsPresenter;
  bool _showTour = false;
  AudioController _audioController;
  @override
  void initState() {
    super.initState();
    context.read<LocalNotificationHelper>().initLocalNotifications(context);
    _audioController = context.read<AudioController>();
    _audioController.init();
    _setsPresenter = context.read<SetsPresenter>();
    _setsPresenter.init();
    context.read<TimerPresenter>().init();
    _loadSettings();
  }

  void _loadSettings() async {
    _showTour = await LocalStorage.getbool(LocalStorage.TOUR_KEY) ?? true;
  }

  @override
  void dispose() {
    context.read<AudioController>().dispose();

    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_showTour) return;
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

  void _close() {
    setState(() {
      _activeIndex = -1;
    });
  }

  Widget _viewForIndex() {
    return Stack(
      children: [
        Offstage(offstage: _activeIndex != -1, child: AudioView()),
        Offstage(offstage: _activeIndex != 1, child: TimerView(onCloseTap: _close)),
        Offstage(
            offstage: _activeIndex != 0,
            child: SetsList(
              onCategorySelected: _newCategorySelected,
              close: _close,
            )),
        Offstage(offstage: _activeIndex != 2, child: FavoritesPage())
      ],
    );
  }

  Widget _buildAnimationView() {
    return StreamBuilder<AudioSet>(
      stream: _audioController.activeTrackStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<AudioSet> snapshot) {
        if (snapshot.data == null)
          return Positioned.fill(
            child: Container(),
          );
        return Positioned.fill(
          child: AnimationView(
            animationFile: snapshot.data?.animationFileName == null
                ? 'assets/animations/study_data.json'
                : snapshot.data?.animationFileName,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AppColors.of(context).controller.activeColorThemeStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final isInitialized = context.select<SetsPresenter, bool>((value) => value.isInitialized);
        final colorTheme = AppColors.of(context).activeColorTheme();
        final activeView = _viewForIndex();
        return Scaffold(
          backgroundColor: colorTheme.backgroundColor,
          body: !isInitialized
              ? const SizedBox()
              : Stack(
                  children: [
                    _buildAnimationView(),
                    Positioned.fill(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 72),
                          child: activeView,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: SafeArea(
                        child: BottomBar(
                          activeIndex: _activeIndex,
                          onTabChanged: _onTabChanged,
                        ),
                      ),
                    ),
                    if (_showTour)
                      Positioned(
                        bottom: 72,
                        right: 24,
                        left: 24,
                        child: SafeArea(
                          child: TutorialView(
                            onTourCompleted: () {
                              setState(() {
                                _showTour = false;
                                LocalStorage.setBool(LocalStorage.TOUR_KEY, false);
                              });
                            },
                          ),
                        ),
                      )
                  ],
                ),
        );
      },
    );
  }
}
