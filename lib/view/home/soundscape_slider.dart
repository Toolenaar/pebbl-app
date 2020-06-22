import 'package:flutter/material.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/soundscape_manager.dart';
import 'package:provider/provider.dart';

class SoundscapeSlider extends StatefulWidget {
  const SoundscapeSlider({Key key}) : super(key: key);

  @override
  _SoundscapeSliderState createState() => _SoundscapeSliderState();
}

class _SoundscapeSliderState extends State<SoundscapeSlider> {
  SoundscapeManager _manager;

  @override
  void initState() {
    _manager = context.read<SetsPresenter>().soundscapeManager;
    _manager.queueNextSet();

    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   for (var item in _manager.audioSets) {
  //     precacheImage(NetworkImage(item.image), context);
  //   }
  //   super.didChangeDependencies();
  // }

  void _play() async {
    context.read<SetsPresenter>().setActiveSet(_manager.activeSet);
    context.read<SetsPresenter>().playActiveSet();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        onPageChanged: (index) {
          if (index == _manager.playQueue.length - 1) {
            _manager.queueNextSet();
          }
          _manager.activeSet = _manager.playQueue[index];
          _play();
          setState(() {});
        },
        itemCount: _manager.playQueue.length,
        itemBuilder: (BuildContext context, int index) {
          final audioSet = _manager.playQueue[index];
          return SoundscapeSlide(
            audioSet: audioSet,
          );
        });
  }
}

class SoundscapeSlide extends StatelessWidget {
  final AudioSet audioSet;
  const SoundscapeSlide({Key key, @required this.audioSet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: H1Text(
                audioSet.name,
                fontSize: 20,
                color: audioSet.category.colorTheme.accentColor40,
              ),
            ),
          ),
          Center(
            child: Container(width: 128, height: 128, child: Image.network(audioSet.image)),
          ),
        ],
      ),
    );
  }
}
