import 'package:flutter/material.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/registration/splash_screen.dart';
import 'package:provider/provider.dart';

class AppInitializer extends StatelessWidget {
  final Widget loginPage;
  final Widget homePage;

  AppInitializer({Key key, @required this.loginPage, @required this.homePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final presenter = context.watch<UserPresenter>();

    return StreamBuilder<bool>(
      stream: presenter.initializationStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        
        if (snapshot.data == null) {
          return SplashScreen();
        }

        if (presenter.user == null) {
          return loginPage;
        } else {
          return homePage;
        }
      },
    );
  }
}
