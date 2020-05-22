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

class AudioSet {
  final List<Stem> stems;
  final String category;
  final String name;
  final String fileName;

  AudioSet({this.stems, this.category, this.name, this.fileName});

  static List<AudioSet> dummySets() {
    var stems = [
      Stem(fileName: 'test_1_0Core.mp3', name: 'Core'),
      Stem(fileName: 'test_1_1low.mp3', name: 'Low'),
      Stem(fileName: 'test_1_3blink.mp3', name: 'Blink'),
      Stem(fileName: 'test_1_4birds.mp3', name: 'Birds'),
      Stem(fileName: 'test_1_paars.mp3', name: 'Paars')
    ];
    return [
      AudioSet(fileName: 'test', name: 'Sunrays', category: 'R:elax',stems: stems),
      AudioSet(fileName: 'test', name: 'Piano bar', category: 'R:elax',stems: stems),
      AudioSet(fileName: 'test', name: 'Crystal Caves', category: 'R:elax',stems: stems),
      AudioSet(fileName: 'test', name: 'Rainforset', category: 'S:leep',stems: stems),
      AudioSet(fileName: 'test', name: 'Astral Plane', category: 'S:leep',stems: stems),
      AudioSet(fileName: 'test', name: 'Shore', category: 'S:leep',stems: stems),
      AudioSet(fileName: 'test', name: 'The coffee bar', category: 'F:ocus',stems: stems),
      AudioSet(fileName: 'test', name: 'Light Surge', category: 'F:ocus',stems: stems),
      AudioSet(fileName: 'test', name: 'Brainy beats', category: 'F:ocus',stems: stems),
    ];
  }
}
