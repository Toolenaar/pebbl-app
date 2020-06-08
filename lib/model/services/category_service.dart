import 'package:pebbl/model/category.dart';
import 'package:pebbl/model/services/firebase_service.dart';

class CategoryService extends FirebaseService {
  CategoryService() : super('categories');

  Future<List<Category>> fetchCategories() async {
    final all = await getAll();
    return all.map((e) => Category.fromJson(e.data)).toList();
  }

  Stream<List<Category>> fetchSetsStream() {
    final all = getAllStream();
    return all.map((s) => s.map((e) => Category.fromJson(e.data)).toList());
  }
}
