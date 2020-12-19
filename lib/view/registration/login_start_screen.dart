import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/animation_view.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/modals/dialog_helper.dart';
import 'package:pebbl/view/dashboard_screen.dart';
import 'package:pebbl/view/home_screen.dart';
import 'package:pebbl/view/registration/anonymous_screen.dart';
import 'package:pebbl/view/registration/login_screen.dart';
import 'package:pebbl/view/registration/registration_screen.dart';
import 'package:provider/provider.dart';

class LoginStartScreen extends StatelessWidget {
  const LoginStartScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimationView(
                color: AppColors.of(context).activeColorTheme().accentColor,
                animationFile: 'assets/animations/rain.json'),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Welcome to pomfi',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: AppColors.of(context).activeColorTheme().accentColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  ThemedPebbleButton(
                    title: 'Login',
                    categoryTheme: AppColors.of(context).activeColorTheme(),
                    onTap: () => NavigationHelper.navigate(context, LoginScreen(), 'LoginScreen'),
                  ),
                  const SizedBox(height: 8),
                  ThemedPebbleButton(
                    title: 'Sign-up',
                    categoryTheme: AppColors.of(context).activeColorTheme(),
                    onTap: () => NavigationHelper.navigate(context, RegistrationScreen(), 'RegistrationScreen'),
                  ),
                  PebbleTextButton(
                      title: 'Use anonymously',
                      onTap: () => NavigationHelper.navigate(context, AnonymousScreen(), 'AnonymousScreen'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
