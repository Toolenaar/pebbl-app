import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/navigation_helper.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/services/audio_service.dart';
import 'package:pebbl/model/services/firebase_service.dart';
import 'package:pebbl/model/services/user_service.dart';
import 'package:pebbl/model/user.dart';
import 'package:pebbl/view/registration/login_start_screen.dart';
import 'package:rxdart/rxdart.dart';

class UserPresenter {
  final _auth = FirebaseAuth.instance;
  final _service = UserService();
  User loggedInUser;
  AppUser user;
  AppColors appColors;

  final BehaviorSubject<bool> isInitialized = BehaviorSubject.seeded(null);

  StreamSubscription<List<FirebaseResult>> _favoSub;
  ValueStream<bool> get initializationStream => isInitialized.stream;

  final BehaviorSubject<List<AudioSet>> favoritesSubject = BehaviorSubject.seeded(null);
  ValueStream<List<AudioSet>> get favoritesStream => favoritesSubject.stream;

  StreamSubscription<User> _loginSub;

  void initialize() async {
    if (_loginSub != null) return;

    _loginSub = _auth.authStateChanges().listen((event) async {
      loggedInUser = _auth.currentUser;
      if (loggedInUser != null) {
        if (!loggedInUser.emailVerified) {
          await loggedInUser.getIdToken(true);
          await loggedInUser.reload();
        }

        user = await fetchUser(loggedInUser.uid);
        setupFavoritesStream();
      }

      isInitialized.add(true);
    });
  }

  void setupFavoritesStream() {
    _favoSub = _service.favoritesStream(userId: loggedInUser.uid).listen((favorites) {
      if (favorites != null) {
        favoritesSubject.add(favorites.map((e) {
          return AudioSet.fromJson(e.data, e.id);
        }).toList());
      } else {
        favoritesSubject.add([]);
      }
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

  Future<String> signUpAnonymously() async {
    try {
      var authResult = await _auth.signInAnonymously();
      loggedInUser = authResult.user;
      user = AppUser(username: 'anonymous', id: loggedInUser.uid);

      var result = await _service.create(user.toJson(), docId: loggedInUser.uid);

      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future signOut(BuildContext context) async {
    user = null;
    loggedInUser = null;
    await LocalStorage.setBool(LocalStorage.TOUR_KEY, true);
    _loginSub.cancel();
    _loginSub = null;
    _favoSub = null;
    isInitialized.add(null);
    await _auth.signOut();
    NavigationHelper.navigateAndRemove(context, LoginStartScreen(), 'LoginStartScreen');
    initialize();
  }

  void addFavorite(AudioSet audioSet) {
    favoritesSubject.add(favoritesSubject.value..add(audioSet));
    _service.addFavorite(userId: loggedInUser.uid, audioSet: audioSet);
  }

  void removeFavorite(AudioSet audioSet) {
    var items = favoritesSubject.value;
    var contains = items.where((e) => e.id == audioSet.id).isNotEmpty;
    if (contains) {
      items.removeWhere((e) => e.id == audioSet.id);
    }
    favoritesSubject.add(items);
    _service.removeFavorite(userId: loggedInUser.uid, audioSetId: audioSet.id);
  }

  Future<List<AudioSet>> favorites() async {
    final results = await _service.favorites(userId: loggedInUser.uid);
    try {
      return parseFavos(results);
    } catch (e) {
      print(e);
    }
  }

  List<AudioSet> parseFavos(List<FirebaseResult> docs) {
    return List<AudioSet>.from(docs.map((d) => AudioSet.fromJson(d.data, d.id)));
  }
}
