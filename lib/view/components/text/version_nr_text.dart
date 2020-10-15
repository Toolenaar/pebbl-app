import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:provider/provider.dart';

class VersionNrText extends StatefulWidget {
  final Color color;
  VersionNrText({Key key, this.color}) : super(key: key);

  _VersionNrViewState createState() => _VersionNrViewState();
}

class _VersionNrViewState extends State<VersionNrText> {
  String _versionNr = '';
  bool _showId = false;

  @override
  void initState() {
    super.initState();
  }

  _setVersionNumber() async {
    if (_versionNr != '') {
      return;
    }
    // String flavour = AppConfig.of(context).buildFlavor;
    // var env = flavour[0].toUpperCase();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //var flavour = AppConfig.getInstance().flavorName[0].toUpperCase();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
      _versionNr = 'V $version ($buildNumber)';
    });
  }

  Widget _buildIdText(BuildContext context) {
    var authUser = Provider.of<UserPresenter>(context, listen: false).user;
    if (authUser == null || _showId == false) return SizedBox();

    return GestureDetector(
        onTap: () {
          Clipboard.setData(new ClipboardData(text: authUser.id));
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Copied userId to Clipboard"),
          ));
        },
        child: FittedBox(fit: BoxFit.fitWidth, child: BodyText1(authUser.id)));
  }

  @override
  Widget build(BuildContext context) {
    if (_versionNr == '') {
      _setVersionNumber();
    }
    return BodyText1(
      _versionNr,
      color: widget.color,
    );
    // return Container(
    //   child: Row(
    //     children: <Widget>[
    //       GestureDetector(
    //         onTap: () {
    //           setState(() {
    //             _showId = !_showId;
    //           });
    //         },
    //         child: Container(
    //           color: Colors.transparent,
    //           child: BodyText1(
    //             _versionNr,
    //           ),
    //         ),
    //       ),
    //       if (_showId) BodyText1(' · '),
    //       Expanded(child: _buildIdText(context))
    //     ],
    //   ),
    // );
  }
}
