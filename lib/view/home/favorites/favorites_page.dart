import 'package:flutter/material.dart';
import 'package:pebbl/logic/audio/audio_controller.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
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
  SetsPresenter _setsPresenter;

  AudioController _audioController;

  @override
  void initState() {
    _audioController = context.read<AudioController>();
    _setsPresenter = context.read<SetsPresenter>();
    _favoritesStream = context.read<UserPresenter>().favoritesStream();
    super.initState();
  }

  void _startFavoPlaylist() {
    if (_favos != null && _favos.length != 0) {
      context.read<AudioController>().shuffleStartPlaylist(_favos, startPlaying: true);
    }
  }

  Widget _buildList(List<AudioSet> favos, CategoryColorTheme colorTheme) {
    return StreamBuilder<AudioSet>(
        stream: _audioController.activeTrackStream,
        builder: (BuildContext context, AsyncSnapshot<AudioSet> snapshot) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: colorTheme.accentColor)),
                child: ListView.builder(
                    itemCount: favos.length + 1,
                    itemBuilder: (ctx, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 48, top: 24, bottom: 16),
                          child: H1Text(
                            'Favorites',
                            fontSize: 20,
                            color: colorTheme.accentColor,
                          ),
                        );
                      }
                      final item = favos[index - 1];
                      return TrackListItem(
                        isActive: snapshot.data != null && (snapshot.data.id == item.id),
                        isInFavoriteList: true,
                        audioSet: item,
                        onTap: () {
                          context.read<AudioController>().activeTrackSubject.add(item);
                          context.read<AudioController>().startPlaylistAtIndex(_favos, index - 1);
                        },
                      );
                    }),
              ),
              Positioned(
                bottom: 1,
                left: 1,
                right: 1,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter, // 10% of the width, so there are ten blinds.
                        colors: [
                          colorTheme.backgroundColor,
                          colorTheme.backgroundColor.withOpacity(0.6),
                          colorTheme.backgroundColor.withOpacity(0.1)
                        ] // whitish to gray
                        ),
                  ),
                ),
              ),
            ],
          );
        });
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
    final colorTheme = AppColors.of(context).activeColorTheme();
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
        _setsPresenter.attachCategory(_favos);

        return Container(
          color: colorTheme.backgroundColor,
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
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
