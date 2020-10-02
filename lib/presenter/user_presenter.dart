import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/services/audio_service.dart';
import 'package:pebbl/model/services/firebase_service.dart';
import 'package:pebbl/model/services/user_service.dart';
import 'package:pebbl/model/user.dart';
import 'package:rxdart/rxdart.dart';

class UserPresenter {
  final _auth = FirebaseAuth.instance;
  final _service = UserService();
  User loggedInUser;
  AppUser user;

  final BehaviorSubject<bool> isInitialized = BehaviorSubject.seeded(null);
  ValueStream<bool> get initializationStream => isInitialized.stream;

  StreamSubscription<User> _loginSub;

  void initialize() {
    if (_loginSub != null) return;
    _loginSub = _auth.authStateChanges().listen((event) async {
      loggedInUser = _auth.currentUser;
      if (loggedInUser != null) {
        if (!loggedInUser.emailVerified) {
          await loggedInUser.getIdToken(true);
          await loggedInUser.reload();
        }

        user = await fetchUser(loggedInUser.uid);
      }

      isInitialized.add(true);
    });
  }

  Future<AppUser> fetchUser(String id) async {
    FirebaseResult result = await _service.getById(id);
    if (result == null) {
      return null;
    }
    this.user = AppUser.fromJson(result.data, result.id);

    return this.user;
  }

  Future<AppUser> login({@required String email, @required String password}) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
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
      user = AppUser(email: email, username: username, id: loggedInUser.uid);

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
    _loginSub.cancel();
    _loginSub = null;
    isInitialized.add(null);
    await _auth.signOut();
    initialize();
  }

  void addFavorite(AudioSet audioSet) {
    _service.addFavorite(userId: loggedInUser.uid, audioSet: audioSet);
  }

  void removeFavorite(AudioSet audioSet) {
    _service.removeFavorite(userId: loggedInUser.uid, audioSetId: audioSet.id);
  }

  Stream isFavoriteStream(AudioSet audioSet) {
    return _service.isFavoriteStream(userId: loggedInUser.uid, audioSet: audioSet);
  }

  Stream<List<AudioSet>> favoritesStream() {
    final stream = _service.favoritesStream(userId: loggedInUser.uid);
    return stream.map<List<AudioSet>>((s) => parseFavos(s));
  }

  List<AudioSet> parseFavos(List<FirebaseResult> docs) {
    return List<AudioSet>.from(docs.map((d) => AudioSet.fromJson(d.data, d.id)));
  }
}
