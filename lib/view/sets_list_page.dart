import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/view/components/sets/sets_list.dart';
import 'package:provider/provider.dart';

class SetsListPage extends StatefulWidget {
  const SetsListPage({Key key}) : super(key: key);

  @override
  _SetsListPageState createState() => _SetsListPageState();
}

class _SetsListPageState extends State<SetsListPage> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Scaffold(
      backgroundColor: colorTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorTheme.backgroundColor,
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
          'Playlists',
          color: colorTheme.accentColor,
          fontSize: 20,
        ),
      ),
      body: Container(
        child: SetsList(
            close: () {
              Navigator.pop(context);
            },
            onCategorySelected: onChanged),
      ),
    );
  }

  void onChanged(GroupedByCategory categoryGroup) {
    context.read<SetsPresenter>().setActiveCategory(categoryGroup.category);
    context.read<AudioController>().shuffleStartPlaylist(categoryGroup.sets, startPlaying: true);
    Navigator.pop(context);
  }
}
