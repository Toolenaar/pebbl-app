import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/model/services/firebase_service.dart';
import 'package:pebbl/model/services/user_service.dart';
import 'package:pebbl/model/user.dart';
import 'package:rxdart/rxdart.dart';

class UserPresenter {
  final _auth = FirebaseAuth.instance;
  final _service = UserService();
  FirebaseUser loggedInUser;
  User user;

  final BehaviorSubject<bool> isInitialized = BehaviorSubject.seeded(null);
  ValueStream<bool> get initializationStream => isInitialized.stream;

  void initialize() async {
    loggedInUser = await _auth.currentUser();
    if (loggedInUser != null) {
      if (!loggedInUser.isEmailVerified) {
        await loggedInUser.getIdToken(refresh: true);
        await loggedInUser.reload();
      }

      user = await fetchUser(loggedInUser.uid);
    }

    isInitialized.add(true);
  }

  Future<User> fetchUser(String id) async {
    FirebaseResult result = await _service.getById(id);
    if (result == null) {
      return null;
    }
    this.user = User.fromJson(result.data, result.id);

    return this.user;
  }

  Future<User> login({@required String email, @required String password}) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      loggedInUser = authResult.user;
    } catch (e) {
      return null;
    }
    user = await fetchUser(loggedInUser.uid);
    return user;
  }

  Future<String> signUpWithEmail(BuildContext context,
      {@required String email, @required String password, @required String username}) async {
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      loggedInUser = authResult.user;
      user = User(email: email, username: username, id: loggedInUser.uid);

      var result = await _service.create(user.toJson(), docId: loggedInUser.uid);

      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future signOut() async {
    user = null;
    loggedInUser = null;
    isInitialized.add(null);
    await _auth.signOut();
    initialize();
  }
}
