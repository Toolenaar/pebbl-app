import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/local_notification_helper.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/animation_view.dart';
import 'package:pebbl/view/components/bottom_bar.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:pebbl/view/home/audio/audio_player_view.dart';
import 'package:pebbl/view/home/audio_view.dart';
import 'package:pebbl/view/home/favorites/favorites_page.dart';
import 'package:pebbl/view/home/settings_page.dart';
import 'package:pebbl/view/home/timer/timer_view.dart';
import 'package:pebbl/view/home/tutorial_view.dart';
import 'package:pebbl/view/sets_list_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeIndex = 0;
  SetsPresenter _setsPresenter;
  bool _showTour = false;

  AudioController _audioController;
  StreamSubscription<bool> _showTourSub;

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

  Widget _viewForIndex() {
    return Stack(
      children: [
        Offstage(
          offstage: _activeIndex != 0,
          child: AudioView(
            key: Key('AudioView'),
          ),
        ),
        Offstage(
          offstage: _activeIndex != 1,
          child: TimerView(
            key: Key('TimerView'),
          ),
        ),
        Offstage(
          offstage: _activeIndex != 2,
          child: FavoritesPage(
            key: Key('FavoritesPage'),
          ),
        ),
        // Offstage(offstage: _activeIndex != -1, child: AudioView()),
        // Offstage(offstage: _activeIndex != 1, child: TimerView(onCloseTap: _close)),
        // Offstage(
        //     offstage: _activeIndex != 0,
        //     child: SetsList(
        //       onCategorySelected: _newCategorySelected,
        //       close: _close,
        //     )),
        // Offstage(offstage: _activeIndex != 2, child: FavoritesPage())
      ],
    );
  }

  Widget _buildMainView(bool isInitialized, CategoryColorTheme colorTheme) {
    final activeView = _viewForIndex();
    return Scaffold(
      appBar: _buildAppBar(colorTheme),
      backgroundColor: Colors.transparent,
      body: !isInitialized
          ? const SizedBox()
          : Column(
              children: [
                Expanded(
                  child: !_showTour ? activeView : SizedBox(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BottomBar(
                    activeIndex: _activeIndex,
                    onTabChanged: _onTabChanged,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar(CategoryColorTheme colorTheme) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      elevation: 0,
      title: _showTour
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: TrackInfo(),
            ),
      actions: _showTour ? [] : [_MenuActions(onActionTap: _onMenuActionClick, showPlayist: _activeIndex == 0)],
    );
  }

  Widget _buildAnimationView(CategoryColorTheme colorTheme) {
    return StreamBuilder<AudioSet>(
      stream: _audioController.activeTrackStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<AudioSet> snapshot) {
        // if (snapshot.data == null)
        //   return Positioned.fill(
        //     child: Container(),
        //   );
        return Positioned.fill(
          child: AnimationView(
            color: colorTheme.accentColor,
            animationFile: snapshot.data?.animationFileName == null
                ? 'assets/animations/rain.json'
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
        return Container(
          color: colorTheme.backgroundColor,
          child: Stack(
            children: [
              _buildAnimationView(colorTheme),
              Positioned.fill(child: _buildMainView(isInitialized, colorTheme)),
              if (_showTour)
                Positioned(
                  bottom: 72,
                  right: 0,
                  left: 0,
                  top: 0,
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

  void _onTabChanged(int index) {
    if (_showTour || index == _activeIndex) return;
    setState(() {
      _activeIndex = index;
    });
  }

  void _loadSettings() {
    _showTourSub = context.read<UserPresenter>().tutorialSettingSub.listen((value) {
      setState(() {
        _showTour = value;
      });
    });
  }

  void _onMenuActionClick(String value) async {
    if (value == 'settings') {
      NavigationHelper.navigateAsModal(context, SettingsPage(), 'SettingsPage');
    } else if (value == 'playlist') {
      NavigationHelper.navigateAsModal(context, SetsListPage(), 'SetsListPage');
    }
  }
}

class _MenuActions extends StatefulWidget {
  final Function(String) onActionTap;
  final bool showPlayist;
  _MenuActions({Key key, this.onActionTap, this.showPlayist = false}) : super(key: key);

  @override
  _MenuActionsState createState() => _MenuActionsState();
}

class _MenuActionsState extends State<_MenuActions> {
  List<Map> _menuOptions;

  void init() {
    _menuOptions = [
      {'value': 'settings', 'display': 'Settings'},
      if (widget.showPlayist) {'value': 'playlist', 'display': 'Playlists'}
    ];
  }

  @override
  Widget build(BuildContext context) {
    init();
    final colorTheme = AppColors.of(context).activeColorTheme();
    return PopupMenuButton<String>(
      onSelected: widget.onActionTap,
      icon: Icon(
        Icons.more_vert,
        color: colorTheme.accentColor,
      ),
      itemBuilder: (BuildContext context) {
        return _menuOptions.map((Map choice) {
          return PopupMenuItem<String>(
            value: choice['value'],
            enabled: choice['enabled'] ?? true,
            child: BodyText1(choice['display'],
                color: (choice['enabled'] == null || choice['enabled'])
                    ? colorTheme.accentColor
                    : colorTheme.accentColor40),
          );
        }).toList();
      },
    );
  }
}
