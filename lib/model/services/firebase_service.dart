import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class WhereQueryField {
  final String field;
  final dynamic value;

  WhereQueryField({this.field, this.value});
  static Query toQuery(List<WhereQueryField> fields, CollectionReference ref) {
    Query query = ref;
    for (var field in fields) {
      query = query.where(field.field, isEqualTo: field.value);
    }
    return query;
  }
}

class FirebaseResult {
  final String id;
  final String error;
  final DocumentSnapshot snapshot;
  final Map<String, dynamic> data;

  FirebaseResult({this.id, this.data, this.error, this.snapshot});
}

class FirebaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName;
  CollectionReference get ref => firestore.collection(collectionName);

  FirebaseService(this.collectionName) {
    firestore.settings = Settings(persistenceEnabled: true);
  }

  Future delete(String id) async {
    await ref.doc(id).delete();
  }

  Future<String> create(Map data, {String subCollection, String docId}) async {
    var doc = ref.doc(docId);
    if (subCollection != null) {
      await doc.collection(subCollection).doc().set(data);
    }
    await doc.set(data);
    return doc.id;
  }

  Future createOrUpdate(Map data, String id) async {
    await ref.doc(id).set(data, SetOptions(merge: true));
  }

  Future update(Map<String, dynamic> data, String id) async {
    await ref.doc(id).update(data);
  }

  Future<FirebaseResult> getById(String id) async {
    var doc = await ref.doc(id).get();

    if (!doc.exists) return null;
    return FirebaseResult(id: doc.id, data: doc.data(), snapshot: doc);
  }

  Stream<FirebaseResult> getByIdStream(String id) {
    var doc = ref.doc(id).snapshots();
    return doc.map((d) => FirebaseResult(id: d.id, data: d.data(), snapshot: d));
  }

  Stream<List<FirebaseResult>> getAllStream() {
    var stream = ref.snapshots();
    return stream.map<List<FirebaseResult>>((s) {
      return parse(s);
    });
  }

  Future<List<FirebaseResult>> getAll() async {
    return parse(await ref.get());
  }

  Future<List<FirebaseResult>> getWithWhereQuery(List<WhereQueryField> fields) async {
    //await _ref
    var items = await WhereQueryField.toQuery(fields, ref).get();
    return parse(items);
  }

  Stream<List<FirebaseResult>> getWithWhereQueryStream(List<WhereQueryField> fields) {
    var query = WhereQueryField.toQuery(fields, ref);
    var stream = query.snapshots();
    return stream.map<List<FirebaseResult>>((s) => parse(s));
  }

  List<FirebaseResult> parse(QuerySnapshot docs) {
    if (docs.docs.isEmpty) return null;
    return List<FirebaseResult>.from(docs.docs.map((d) => FirebaseResult(id: d.id, data: d.data(), snapshot: d)));
  }
}
