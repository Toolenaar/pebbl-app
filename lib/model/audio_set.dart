import 'package:pebbl/model/artist.dart';
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

enum AudioSetStatus { notDownloaded, locked, downloaded, owned, unknown, streaming }

class AudioSet {
  final List<Stem> stems;
  final String categoryId;
  Category category;
  final String name;
  final String id;
  final Artist artist;
  final String fileName;
  final String image;
  final String trackUrl;
  String playbackUrl;
  // DownloadedSet downloadedSet;

  AudioSetStatus get status {
    // if (downloadedSet == null || !downloadedSet.isFullyDownloaded) return AudioSetStatus.notDownloaded;
    // if (downloadedSet.isFullyDownloaded) return AudioSetStatus.downloaded;
    return AudioSetStatus.streaming;
  }

  AudioSet(
      {this.stems,
      this.category,
      this.trackUrl,
      this.categoryId,
      this.artist,
      this.playbackUrl,
      this.name,
      this.fileName,
      this.id,
      this.image});

  // List<String> get downloadedStemPaths {
  //   return downloadedSet?.downloadedStems?.map((s) => s.filePath)?.toList() ?? null;
  // }

  static AudioSet fromJson(Map data, String id) {
    return AudioSet(
      id: id,
      fileName: data['fileName'],
      image: data['image'],
      name: data['name'],
      trackUrl: data['trackUrl'],
      artist: Artist.fromJson(data['artist']),
      categoryId: data['categoryId'],
      stems: data['stems'] == null
          ? null
          : List<Stem>.from(
              data['stems'].map(
                (s) => Stem.fromJson(s),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'image': image,
      'categoryId': categoryId,
      'name': name,
      'artist': artist.toJson(),
      'trackUrl': trackUrl
    };
  }

  String get fullName {
    final cat = category.name[0];
    return '$cat:$name';
  }

  AudioSet copyWith() {
    return AudioSet(
        category: category,
        id: id,
        // downloadedSet: downloadedSet?.copyWith() ?? null,
        fileName: fileName,
        trackUrl: trackUrl,
        image: image,
        playbackUrl: this.playbackUrl,
        artist: artist.copyWith(),
        name: name,
        categoryId: categoryId,
        stems: stems);
  }
}
