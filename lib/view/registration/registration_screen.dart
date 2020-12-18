import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/logic/validation.dart';
import 'package:pebbl/logic/view_helper.dart';
import 'package:pebbl/presenter/user_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/modals/dialog_helper.dart';
import 'package:pebbl/view/components/progress_view.dart';
import 'package:pebbl/view/components/text/pebbl_form_field.dart';
import 'package:pebbl/view/dashboard_screen.dart';
import 'package:pebbl/view/home_screen.dart';
import 'package:pebbl/view/registration/login_screen.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  FocusNode _usernameFocus = FocusNode();

  bool _formActive = false;
  bool _loggingIn = false;

  String _email;
  String _username;

  String _password;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(onFocusChange);
    _passwordFocus.addListener(onFocusChange);
    _usernameFocus.addListener(onFocusChange);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(onFocusChange);
    _passwordFocus.removeListener(onFocusChange);
    _usernameFocus.removeListener(onFocusChange);
    super.dispose();
  }

  void onFocusChange() {
    setState(() {
      _formActive = _emailFocus.hasFocus || _passwordFocus.hasFocus || _usernameFocus.hasFocus;
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

    var result = await presenter.signUpWithEmail(context, email: _email, password: _password, username: _username);
    if (result != null) {
      NavigationHelper.navigateAndRemove(context, HomePage(), 'HomePage');
    } else {
      DialogHelper.showErrorDialog(
          context: context,
          title: 'Oops something went wrong',
          error:
              'Something went wrong trying to register your account. Make sure the email you use is not already registered.');
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
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor),
      body: _loggingIn
          ? ProgressView()
          : GestureDetector(
              onTap: () {
                setState(() {
                  _formActive = false;
                });
                ViewHelper.hideKeyboard(context);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      AnimatedLoginGraphic(formActive: _formActive),
                      Expanded(
                        child: Container(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: RegistrationForm(
                              emailInitialValue: _email,
                              usernameInitialValue: _username,
                              passwordInitialValue: _password,
                              login: _login,
                              emailFocus: _emailFocus,
                              usernameFocus: _usernameFocus,
                              passwordFocus: _passwordFocus,
                              onPasswordChanged: (value) => _password = value,
                              onEmailChanged: (value) => _email = value,
                              onUsernameChanged: (value) => _username = value,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode usernameFocus;
  final String emailInitialValue;
  final String usernameInitialValue;
  final String passwordInitialValue;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final Function(String) onUsernameChanged;
  final Function(GlobalKey<FormState>) login;
  const RegistrationForm(
      {Key key,
      this.emailFocus,
      this.onUsernameChanged,
      this.passwordFocus,
      this.usernameFocus,
      this.emailInitialValue,
      this.usernameInitialValue,
      this.passwordInitialValue,
      @required this.login,
      @required this.onEmailChanged,
      @required this.onPasswordChanged})
      : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PebblFormField(
            initialValue: widget.usernameInitialValue,
            onChanged: widget.onUsernameChanged,
            focusNode: widget.usernameFocus,
            hintText: 'Username',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value.isEmpty && value.length > 3) {
                return 'Username length needs to be 3 characters or more';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          PebblFormField(
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
          PebbleButton(
            title: 'Sign-up',
            onTap: () => widget.login(_formKey),
          ),
        ],
      ),
    );
  }
}
