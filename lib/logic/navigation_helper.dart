import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationHelper {
  // static Future navigateAsOverlay(BuildContext context, Widget content) {
  //   return Navigator.of(context).push(DFModalOverlayRoute(child: content));
  // }

  static navigate(BuildContext context, Widget page, String name) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: name != null ? RouteSettings(name: name) : null,
        builder: (context) => page,
      ),
    );
    return result;
  }

  static navigateAndRemove(BuildContext context, Widget page, String name) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: name != null ? RouteSettings(name: name) : null,
          builder: (context) => page,
        ),
        (Route<dynamic> route) => false);
  }

  static navigateAsModal(BuildContext context, Widget page, String name) async {
    var result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
        settings: name != null ? RouteSettings(name: name) : null,
        fullscreenDialog: true));
    return result;
  }

  static launchURL(String url) async {
    var finalUrl = url;
    if (url.startsWith('www')) {
      finalUrl = url.replaceFirst('www', 'https://www');
    } else if (!url.startsWith('https://') && !url.startsWith('http://')) {
      finalUrl = 'https://' + url;
    }
    if (await canLaunch(finalUrl)) {
      await launch(finalUrl);
    } else {
      throw 'Could not launch $url';
    }
  }

  // static launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  // static void launchYoutube(String url) async {
  //   if (Platform.isIOS) {
  //     var ytUrl = url.replaceAll('https:', 'youtube:');
  //     if (await canLaunch(ytUrl)) {
  //       await launch(ytUrl, forceSafariVC: false);
  //     } else {
  //       if (await canLaunch(url)) {
  //         await launch(url);
  //       } else {
  //         throw 'Could not launch $url';
  //       }
  //     }
  //   } else {
  //     if (await canLaunch(url)) {
  //       await launch(url);
  //     } else {
  //       throw 'Could not launch $url';
  //     }
  //   }
  // }
}

/// PopResult
class PopWithResults<T> {
  /// poped from this page
  final String fromPage;

  /// pop until this page
  final String toPage;

  /// results
  final Map<String, T> results;

  /// constructor
  PopWithResults({@required this.fromPage, @required this.toPage, this.results});
}
