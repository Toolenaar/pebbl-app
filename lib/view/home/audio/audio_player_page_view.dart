// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:pebbl/logic/audio/audio_manager.dart';
// import 'package:pebbl/model/audio_set.dart';
// import 'package:pebbl/view/home/audio/audio_player_view.dart';
// import 'package:provider/provider.dart';

// class AudioPlayerPageView extends StatefulWidget {
//   const AudioPlayerPageView({Key key}) : super(key: key);

//   @override
//   _AudioPlayerPageViewState createState() => _AudioPlayerPageViewState();
// }

// class _AudioPlayerPageViewState extends State<AudioPlayerPageView> {
//   PageController _controller;
//   AudioManager _audioManager;
//   StreamSubscription<AudioSet> _streamSubscription;
//   int _pageIndex = 0;
//   @override
//   void initState() {
//     _audioManager = context.read<AudioManager>();
//     _pageIndex = _audioManager.activeIndex;
//     _controller = PageController(initialPage: _pageIndex);
//     _audioManager.activeTrackStream.listen(_gotoTrack);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _streamSubscription.cancel();
//     super.dispose();
//   }

//   void _gotoTrack(AudioSet audioSet) {
//     // _controller.animateToPage(_audioManager.activeIndex,
//     //     duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_audioManager.activePlaylist == null || _audioManager.activePlaylist.length == 0) return const SizedBox();
//     return PageView.builder(
//       onPageChanged: (page) {
//         if (page > _pageIndex) {
//           _audioManager.next();
//         } else {
//           _audioManager.previous();
//         }
//         setState(() {
//           _pageIndex = page;
//         });
//       },
//       controller: _controller,
//       itemCount: _audioManager.activePlaylist.length,
//       itemBuilder: (ctx, index) {
//         final audioSet = _audioManager.activePlaylist[index];
//         return AudioPlayerView(audioSet: audioSet);
//       },
//     );
//   }
// }
