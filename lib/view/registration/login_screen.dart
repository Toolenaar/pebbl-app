import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/logic/validation.dart';
import 'package:pebbl/logic/view_helper.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/animation_view.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/modals/dialog_helper.dart';
import 'package:pebbl/view/components/progress_view.dart';
import 'package:pebbl/view/components/text/pebbl_form_field.dart';
import 'package:pebbl/view/dashboard_screen.dart';
import 'package:pebbl/view/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _formActive = false;
  bool _loggingIn = false;
  String _email;
  String _password;
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(onFocusChange);
    _passwordFocus.addListener(onFocusChange);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(onFocusChange);
    _passwordFocus.removeListener(onFocusChange);
    super.dispose();
  }

  void onFocusChange() {
    setState(() {
      _formActive = _emailFocus.hasFocus || _passwordFocus.hasFocus;
    });
  }

  void _login(GlobalKey<FormState> formKey) async {
    if (formKey.currentState.validate()) {
      ViewHelper.hideKeyboard(context);
      setState(() {
        _loggingIn = true;
      });
    }

    final presenter = context.read<UserPresenter>();

    var result = await presenter.login(email: _email, password: _password);
    if (result != null) {
      NavigationHelper.navigateAndRemove(context, HomePage(), 'HomePage');
    } else {
      DialogHelper.showErrorDialog(
          context: context,
          title: 'Oops something went wrong',
          error: 'Please check your email and password and make sure they are correct');
      setState(() {
        _loggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.of(context).activeColorTheme().accentColor),
        title: H1Text('Login', fontSize: 20, color: AppColors.of(context).activeColorTheme().accentColor),
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor,
      ),
      body: _loggingIn
          ? ProgressView()
          : GestureDetector(
              onTap: () {
                setState(() {
                  _formActive = false;
                });
                ViewHelper.hideKeyboard(context);
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimationView(
                        color: AppColors.of(context).activeColorTheme().accentColor,
                        animationFile: 'assets/animations/rain.json'),
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: SafeArea(
                      child: Column(
                        children: <Widget>[
                          Spacer(),
                          Container(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: LoginForm(
                                emailInitialValue: _email,
                                passwordInitialValue: _password,
                                login: _login,
                                emailFocus: _emailFocus,
                                passwordFocus: _passwordFocus,
                                onPasswordChanged: (value) => _password = value,
                                onEmailChanged: (value) => _email = value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class AnimatedLoginGraphic extends StatelessWidget {
  const AnimatedLoginGraphic({
    Key key,
    @required bool formActive,
  })  : _formActive = formActive,
        super(key: key);

  final bool _formActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 24),
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            height: _formActive ? 64 : 128,
            child: Image.asset(
              'assets/img/img_center_piece.png',
              fit: BoxFit.fitHeight,
              color: AppColors.of(context).activeColorTheme().accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final String emailInitialValue;
  final String passwordInitialValue;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final Function(GlobalKey<FormState>) login;
  const LoginForm(
      {Key key,
      this.emailFocus,
      this.passwordFocus,
      this.emailInitialValue,
      this.passwordInitialValue,
      @required this.login,
      @required this.onEmailChanged,
      @required this.onPasswordChanged})
      : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PebblFormField(
            autoFocus: true,
            initialValue: widget.emailInitialValue,
            onChanged: widget.onEmailChanged,
            focusNode: widget.emailFocus,
            hintText: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (!Validation.isValidEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          PebblFormField(
            initialValue: widget.passwordInitialValue,
            onChanged: widget.onPasswordChanged,
            focusNode: widget.passwordFocus,
            hintText: 'Password',
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (!Validation.isValidPassword(value)) {
                return 'Password length needs to be 8 characters or more';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ThemedPebbleButton(
            title: 'Login',
            categoryTheme: AppColors.of(context).activeColorTheme(),
            onTap: () => widget.login(_formKey),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
