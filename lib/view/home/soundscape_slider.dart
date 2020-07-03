import 'package:flutter/material.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/soundscape_manager.dart';
import 'package:pebbl/view/components/set_center_piece.dart';
import 'package:provider/provider.dart';

@deprecated
class SoundscapeSlider extends StatefulWidget {
  const SoundscapeSlider({Key key}) : super(key: key);

  @override
  _SoundscapeSliderState createState() => _SoundscapeSliderState();
}

class _SoundscapeSliderState extends State<SoundscapeSlider> {
  SoundscapeManager _manager;
  PageController _controller;

  bool _jumpFromSystemChange = false;
  bool _jumpFromUserChange = false;

  @override
  void initState() {
    _manager = context.read<SetsPresenter>().soundscapeManager;
    _manager.queueNextSet();
    // final initialPage = _manager.activeSet == null ? 0 : _manager.playQueue.indexOf(_manager.activeSet);
    //  _controller = PageController(initialPage: initialPage);

    _manager.setStateListener(_onStateChanged);

    super.initState();
  }

  void _onStateChanged(String state) {
    if (mounted) {
      if (state == 'completed') {
        if (!_jumpFromUserChange) {
          _jumpFromSystemChange = true;
          _controller.nextPage(curve: Curves.easeInOut, duration: Duration(milliseconds: 300));
        }
        _jumpFromUserChange = false;
      }
    }
  }

  @override
  void dispose() {
    _manager.removeStateListener();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   for (var item in _manager.audioSets) {
  //     precacheImage(NetworkImage(item.image), context);
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _controller,
        onPageChanged: (index) {
          if (_jumpFromSystemChange) {
            _jumpFromSystemChange = false;
            return;
          }

          if (index == _manager.playQueue.length - 1) {
            _manager.queueNextSet();
          }
          //_manager.activeSet = _manager.playQueue[index];
          _manager.play();
          _jumpFromUserChange = true;
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
          SetCenterpiece(
            audioSet: audioSet,
          )
        ],
      ),
    );
  }
}
