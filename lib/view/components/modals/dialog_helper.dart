import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/validation.dart';

class DialogHelper {
  static Future showResetPasswordDialog(BuildContext mainContext, String email, Function(String) onReset) async {
    var result = await showDialog<String>(
        context: mainContext,
        builder: (BuildContext context) {
          return ResetPasswordDialog(
            email: email,
          );
        });

    if (result != '') {
      //todo reset password
      onReset(result);

      Scaffold.of(mainContext).showSnackBar(SnackBar(content: Text('Email sent')));
    }
  }

  static Future<bool> showOkCancelDialog({
    @required BuildContext context,
    @required String title,
    @required String message,
  }) async {
    return showDialog<bool>(
      context: context,
      // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).activeColorTheme().accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text(
                'Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).activeColorTheme().accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<Null> showErrorDialog({
    @required BuildContext context,
    @required String title,
    @required String error,
    Function ok,
  }) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              onPressed: () {
                if (ok != null) ok();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ResetPasswordDialog extends StatefulWidget {
  final String email;
  const ResetPasswordDialog({this.email});

  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordDialogState();
  }
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  String _email = '';
  TextEditingController _controller;

  @override
  void initState() {
    _email = widget.email;
    _controller = TextEditingController(text: widget.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (String value) {
                  setState(() {
                    _email = value;
                  });
                },
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'email'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL', style: TextStyle(fontSize: 16)),
              textColor: AppColors.of(context).activeColorTheme().accentColor,
              onPressed: () {
                Navigator.pop(context, '');
              }),
          new FlatButton(
              child: const Text(
                'SEND',
                style: TextStyle(fontSize: 16),
              ),
              textColor: AppColors.of(context).activeColorTheme().accentColor,
              onPressed: !Validation.isValidEmail(_email)
                  ? null
                  : () {
                      Navigator.pop(context, _email);
                    })
        ],
      ),
    );
  }
}
