import 'package:pebbl/logic/download_manager.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/model/stem.dart';

class GroupedByCategory {
  final Category category;
  final List<AudioSet> sets;

  GroupedByCategory({this.category, this.sets});

  //convert a list of audiosets to a list ordered by category
  static List<GroupedByCategory> fromAudioSetList(List<AudioSet> setList) {
    final categoryMap = Map<String, GroupedByCategory>();

    for (var item in setList) {
      var cat = categoryMap[item.categoryId];
      if (cat == null) {
        categoryMap[item.categoryId] = GroupedByCategory(category: item.category, sets: [item]);
      } else {
        cat.sets.add(item);
      }
    }
    final categoryList = List<GroupedByCategory>();
    categoryMap.forEach((key, value) {
      categoryList.add(value);
    });
    return categoryList;
  }
}

enum AudioSetStatus { notDownloaded, locked, downloaded, owned, unknown }

class AudioSet {
  final List<Stem> stems;
  final String categoryId;
  Category category;
  final String name;
  final String id;
  final String fileName;
  final String image;
  DownloadedSet downloadedSet;

  AudioSetStatus get status {
    if (downloadedSet == null || !downloadedSet.isFullyDownloaded) return AudioSetStatus.notDownloaded;
    if (downloadedSet.isFullyDownloaded) return AudioSetStatus.downloaded;
    return AudioSetStatus.unknown;
  }

  AudioSet({this.stems, this.category, this.categoryId, this.name, this.fileName, this.id, this.image});

  List<String> get downloadedStemPaths {
    return downloadedSet?.downloadedStems?.map((s) => s.filePath)?.toList() ?? null;
  }

  static AudioSet fromJson(Map data, String id) {
    return AudioSet(
      id: id,
      fileName: data['fileName'],
      image: data['image'],
      name: data['name'],
      categoryId: data['categoryId'],
      stems: List<Stem>.from(
        data['stems'].map(
          (s) => Stem.fromJson(s),
        ),
      ),
    );
  }

  String get fullName {
    final cat = category.name[0];
    return '$cat:$name';
  }

  AudioSet copyWith() {
    return AudioSet(
        category: category,
        id: id,
        fileName: fileName,
        image: image,
        name: name,
        categoryId: categoryId,
        stems: stems);
  }
}
