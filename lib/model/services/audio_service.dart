import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/services/firebase_service.dart';

class AudioService extends FirebaseService {
  AudioService() : super('sets');

  Future<List<AudioSet>> fetchSets() async {
    final all = await getAll();
    return all.map((e) => AudioSet.fromJson(e.data, e.id)).toList();
  }
}
