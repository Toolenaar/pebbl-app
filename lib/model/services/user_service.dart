import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/services/firebase_service.dart';

class UserService extends FirebaseService {
  UserService() : super('users');

  Future addFavorite({@required String userId, @required AudioSet audioSet}) async {
    await ref.doc(userId).collection('favorites').doc(audioSet.id).set(audioSet.toJson());
  }

  Future removeFavorite({@required String userId, String audioSetId}) async {
    await ref.doc(userId).collection('favorites').doc(audioSetId).delete();
  }

  Future<List<FirebaseResult>> favorites({String userId}) async {
    final result = await ref.doc(userId).collection('favorites').get();
    return parse(result);
  }

  Stream<List<FirebaseResult>> favoritesStream({String userId}) {
    final stream = ref.doc(userId).collection('favorites').snapshots();
    return stream.map<List<FirebaseResult>>((s) => parse(s));
  }
}
