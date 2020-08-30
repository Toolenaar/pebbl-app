import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/sets/tracks_list.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Stream _favoritesStream;
  List<AudioSet> _favos;
  @override
  void initState() {
    _favoritesStream = context.read<UserPresenter>().favoritesStream();
    super.initState();
  }

  void _startFavoPlaylist() {
    if (_favos != null && _favos.length != 0) {
      context.read<AudioController>().shuffleStartPlaylist(_favos, startPlaying: true);
    }
  }

  Widget _buildList(List<AudioSet> favos, CategoryColorTheme colorTheme) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: colorTheme.accentColor)),
      child: ListView.builder(
          itemCount: favos.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 24, top: 16, bottom: 24),
                child: H1Text(
                  'Favorites',
                  fontSize: 32,
                  color: colorTheme.accentColor,
                ),
              );
            }
            final item = favos[index - 1];
            return TrackListItem(
              isInFavoriteList: true,
              audioSet: item,
              onTap: () {
                context.read<AudioController>().startPlaylistAtIndex(_favos, index - 1);
              },
            );
          }),
    );
  }

  Widget _buildShuffleButton(CategoryColorTheme colorTheme) {
    return ThemedPebbleButton(
      title: 'Shuffle favorites',
      categoryTheme: colorTheme,
      onTap: _startFavoPlaylist,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.getActiveColorTheme(context);
    return StreamBuilder<List<AudioSet>>(
      stream: _favoritesStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<List<AudioSet>> snapshot) {
        if (snapshot.data == null) {
          return Container(
            child: Center(
              child: BodyText2(
                'No favorites yet',
                color: colorTheme.accentColor40,
              ),
            ),
          );
        }
        _favos = snapshot.data;
        return Container(
          color: colorTheme.backgroundColor,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: _buildList(snapshot.data, colorTheme),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildShuffleButton(colorTheme)
            ],
          ),
        );
      },
    );
  }
}
