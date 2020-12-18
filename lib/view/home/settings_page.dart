import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/text/version_nr_text.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoBreakTime;
  bool _nightModeEnabled;
  bool _tourIsActive = false;

  @override
  void initState() {
    super.initState();
    setSettings();
  }

  setSettings() async {
    _autoBreakTime = await LocalStorage.getbool(LocalStorage.AUTO_BREAK_TIMER_KEY) ?? false;
    _nightModeEnabled = await LocalStorage.getbool(LocalStorage.NIGHTMODE_ENABLED) ?? false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_autoBreakTime == null) return SizedBox();
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Scaffold(
      backgroundColor: colorTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorTheme.backgroundColor,
        actions: [
          GestureDetector(
            onTap: () async {
              await context.read<UserPresenter>().signOut(context);
            },
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              color: Colors.transparent,
              child: Center(
                  child: BodyText1(
                'LOG-OUT',
                color: colorTheme.accentColor,
              )),
            ),
          )
        ],
        leading: IconButton(
          icon: Image.asset(
            'assets/img/ic_close.png',
            color: colorTheme.accentColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        title: BodyText1(
          'Settings',
          color: colorTheme.accentColor,
          fontSize: 20,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  _SettingRow(
                    description: 'Automatically start break timer after study session',
                    isSet: _autoBreakTime,
                    onToggle: (value) async {
                      await LocalStorage.setBool(LocalStorage.AUTO_BREAK_TIMER_KEY, value);
                      setState(() {
                        _autoBreakTime = value;
                      });
                    },
                  ),
                  _SettingRow(
                    description: 'Automatically initiate night mode after 19:00 pm',
                    isSet: _nightModeEnabled,
                    onToggle: (value) async {
                      await LocalStorage.setBool(LocalStorage.NIGHTMODE_ENABLED, value);
                      AppColors.of(context).controller.nightModeActive = value;
                      setState(() {
                        _nightModeEnabled = value;
                      });
                    },
                  ),

                  if (!_tourIsActive) ...[
                    const SizedBox(
                      height: 16,
                    ),
                    _SettingRow(
                        description: 'Reset tutorial tour',
                        onTap: () async {
                          await LocalStorage.setBool(LocalStorage.TOUR_KEY, true);
                          context.read<UserPresenter>().tutorialSettingSub.add(true);
                          setState(() {
                            _tourIsActive = true;
                          });
                        })
                  ],
                  // const SizedBox(
                  //   height: 24,
                  // ),
                  // _SettingRow(
                  //   description: 'Automatically initiate night mode after 19:00 pm',
                  //   isSet: _autoBreakTime,
                  //   onToggle: (value) async {
                  //     await LocalStorage.setBool(LocalStorage.AUTO_BREAK_TIMER_KEY, value);
                  //     setState(() {
                  //       _autoBreakTime = value;
                  //     });
                  //   },
                  // ),
                  const SizedBox(
                    height: 24,
                  ),
                  Divider(
                    height: 1,
                    color: colorTheme.accentColor,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  BodyText1(
                    'Themes',
                    color: colorTheme.accentColor,
                    fontSize: 20,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ThemePicker(
                    dayThemeSelected: _saveDayTheme,
                    nightThemeSelected: _saveNightTheme,
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    child: BodyText1('TERMS OF SERVICE', color: colorTheme.accentColor),
                  ),
                  Spacer(),
                  VersionNrText(color: colorTheme.accentColor)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveDayTheme(CategoryColorTheme theme) async {
    //if day
    AppColors.of(context).controller.setActiveDayColor(theme);
    await LocalStorage.setString(LocalStorage.DAY_THEME_KEY, theme.id);
    setState(() {});
  }

  void _saveNightTheme(CategoryColorTheme theme) async {
    //if night
    AppColors.of(context).controller.setActiveNightColor(theme);
    await LocalStorage.setString(LocalStorage.NIGHT_THEME_KEY, theme.id);
    setState(() {});
  }
}

class _SettingRow extends StatelessWidget {
  final String description;
  final bool isSet;
  final Function(bool) onToggle;
  final Function onTap;
  const _SettingRow({Key key, this.description = '', this.isSet = false, this.onToggle, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: onToggle == null ? Border.all(color: colorTheme.accentColor, width: 1) : null),
        padding: EdgeInsets.symmetric(vertical: onToggle == null ? 8 : 0, horizontal: onToggle == null ? 8 : 0),
        child: Row(
          children: [
            Expanded(
              child: BodyText2(
                description,
                color: colorTheme.accentColor,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            if (onToggle != null)
              Switch(
                  activeColor: colorTheme.accentColor,
                  inactiveTrackColor: colorTheme.accentColor.withOpacity(0.2),
                  value: isSet,
                  inactiveThumbColor: colorTheme.accentColor,
                  onChanged: onToggle)
          ],
        ),
      ),
    );
  }
}

class ThemePicker extends StatelessWidget {
  final Function(CategoryColorTheme theme) dayThemeSelected;
  final Function(CategoryColorTheme theme) nightThemeSelected;
  const ThemePicker({Key key, @required this.dayThemeSelected, @required this.nightThemeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: ColorThemes.dayThemes
              .map((e) => ColorCircle(
                    theme: e,
                    isSelected: AppColors.of(context).controller.activeDayColorTheme.id == e.id,
                    onTap: () => dayThemeSelected(e),
                  ))
              .toList(),
        ),
        const SizedBox(
          height: 24,
        ),
        // BodyText1(
        //   'NIGHTMODE THEMES',
        //   color: colors.accentColor,
        //   fontSize: 14,
        // ),
        // const SizedBox(
        //   height: 16,
        // ),
        // Wrap(
        //   spacing: 16,
        //   runSpacing: 16,
        //   children: ColorThemes.nightThemes
        //       .map((e) => ColorCircle(
        //             theme: e,
        //             isSelected: AppColors.of(context).controller.activeNightColorTheme.id == e.id,
        //             onTap: () => nightThemeSelected(e),
        //           ))
        //       .toList(),
        // )
      ]),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final CategoryColorTheme theme;
  final bool isSelected;
  final Function() onTap;
  const ColorCircle({Key key, this.theme, this.isSelected = false, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context).activeColorTheme();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 96,
        decoration: isSelected ? BoxDecoration(border: Border.all(color: theme.accentColor)) : null,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    color: theme.backgroundColor,
                    border: Border.all(color: theme.accentColor)),
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    RotatedBox(
                      quarterTurns: 1,
                      child: ClipPath(
                        clipper: CustomHalfCircleClipper(),
                        child: Container(
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: theme.highlightColor,
                            borderRadius: BorderRadius.circular(48),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        right: -5,
                        top: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              border: Border.all(color: theme.accentColor),
                              color: theme.backgroundColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Icon(Icons.check, size: 14, color: theme.accentColor),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              BodyText1(
                theme.name.toUpperCase(),
                fontSize: 10,
                color: colors.accentColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    // path.lineTo(size.width / 2, 0.0);
    // path.lineTo(size.width, 0.0);
    // path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
