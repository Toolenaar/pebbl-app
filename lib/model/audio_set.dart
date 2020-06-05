import 'package:pebbl/logic/download_manager.dart';
import 'package:pebbl/model/stem.dart';

class SetCategory {
  final String name;
  final List<AudioSet> sets;

  SetCategory({this.name, this.sets});

  //convert a list of audiosets to a list ordered by category
  static List<SetCategory> fromAudioSetList(List<AudioSet> setList) {
    final categoryMap = Map<String, SetCategory>();

    for (var item in setList) {
      var cat = categoryMap[item.category];
      if (cat == null) {
        categoryMap[item.category] = SetCategory(name: item.category, sets: [item]);
      } else {
        cat.sets.add(item);
      }
    }
    final categoryList = List<SetCategory>();
    categoryMap.forEach((key, value) {
      categoryList.add(value);
    });
    return categoryList;
  }
}

enum AudioSetStatus { notDownloaded, locked, downloaded, owned,unknown }

class AudioSet {
  final List<Stem> stems;
  final String category;
  final String name;
  final String id;
  final String fileName;
  DownloadedSet downloadedSet;

  AudioSetStatus get status {
    if (downloadedSet == null) return AudioSetStatus.notDownloaded;
    if (downloadedSet.isFullyDownloaded) return AudioSetStatus.downloaded;
    return AudioSetStatus.unknown;
  }

  AudioSet({this.stems, this.category, this.name, this.fileName, this.id});

  List<String> get downloadedStemPaths {
    return downloadedSet?.downloadedStems?.map((s) => s.filePath)?.toList() ?? null;
  }

  static AudioSet fromJson(Map data, String id) {
    return AudioSet(
        id: id,
        fileName: data['fileName'],
        name: data['name'],
        category: data['category'],
        stems: List<Stem>.from(data['stems'].map((s) => Stem.fromJson(s))));
  }

  static List<AudioSet> dummySets() {
    var stems = [
      Stem(filePath: 'test_1_0Core.mp3', name: 'Core'),
      Stem(filePath: 'test_1_1low.mp3', name: 'Low'),
      Stem(filePath: 'test_1_3blink.mp3', name: 'Blink'),
      Stem(filePath: 'test_1_4birds.mp3', name: 'Birds'),
      Stem(filePath: 'test_1_paars.mp3', name: 'Paars')
    ];
    return [
      AudioSet(fileName: 'test', name: 'Sunrays', category: 'R:elax', stems: stems),
      AudioSet(fileName: 'test', name: 'Piano bar', category: 'R:elax', stems: stems),
      AudioSet(fileName: 'test', name: 'Crystal Caves', category: 'R:elax', stems: stems),
      AudioSet(fileName: 'test', name: 'Rainforset', category: 'S:leep', stems: stems),
      AudioSet(fileName: 'test', name: 'Astral Plane', category: 'S:leep', stems: stems),
      AudioSet(fileName: 'test', name: 'Shore', category: 'S:leep', stems: stems),
      AudioSet(fileName: 'test', name: 'The coffee bar', category: 'F:ocus', stems: stems),
      AudioSet(fileName: 'test', name: 'Light Surge', category: 'F:ocus', stems: stems),
      AudioSet(fileName: 'test', name: 'Brainy beats', category: 'F:ocus', stems: stems),
    ];
  }

  String get fullName {
    final cat = category[0];
    return '$cat:$name';
  }
}
