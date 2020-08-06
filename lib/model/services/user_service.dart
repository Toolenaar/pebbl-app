import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/services/firebase_service.dart';

class UserService extends FirebaseService {
  UserService() : super('users');

  Future addFavorite({@required String userId, @required AudioSet audioSet}) async {
    await ref.document(userId).collection('favorites').document(audioSet.id).setData(audioSet.toJson());
  }

  Future removeFavorite({@required String userId, String audioSetId}) async {
    await ref.document(userId).collection('favorites').document(audioSetId).delete();
  }

  Stream isFavoriteStream({@required String userId, @required AudioSet audioSet}) {
    return ref.document(userId).collection('favorites').document(audioSet.id).snapshots();
  }

  Stream<List<FirebaseResult>> favoritesStream({String userId}) {
    final stream = ref.document(userId).collection('favorites').snapshots();
    return stream.map<List<FirebaseResult>>((s) => parse(s));
  }
}
