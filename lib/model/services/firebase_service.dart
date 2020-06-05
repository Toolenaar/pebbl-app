import 'package:cloud_firestore/cloud_firestore.dart';

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
  Firestore firestore = new Firestore();
  final String collectionName;
  CollectionReference get ref => firestore.collection(collectionName);

  FirebaseService(this.collectionName) {
    firestore = new Firestore();
    firestore.settings(persistenceEnabled: true);
  }

  Future delete(String id) async {
    await ref.document(id).delete();
  }

  Future<String> create(Map data, {String subCollection, String docId}) async {
    var doc = ref.document(docId);
    if (subCollection != null) {
      await doc.collection(subCollection).document().setData(data);
    }
    await doc.setData(data);
    return doc.documentID;
  }

  Future createOrUpdate(Map data, String id) async {
    await ref.document(id).setData(data, merge: true);
  }

  Future update(Map<String,dynamic> data, String id) async {
    await ref.document(id).updateData(data);
  }

  Future<FirebaseResult> getById(String id) async {
    var doc = await ref.document(id).get();

    if (!doc.exists) return null;
    return FirebaseResult(id: doc.documentID, data: doc.data, snapshot: doc);
  }

  Stream<FirebaseResult> getByIdStream(String id) {
    var doc = ref.document(id).snapshots();
    return doc.map((d) => FirebaseResult(id: d.documentID, data: d.data, snapshot: d));
  }

  Stream<List<FirebaseResult>> getAllStream() {
    var stream = ref.snapshots();
    return stream.map<List<FirebaseResult>>((s) => parse(s));
  }

  Future<List<FirebaseResult>> getAll() async {
    return parse(await ref.getDocuments());
  }

  Future<List<FirebaseResult>> getWithWhereQuery(List<WhereQueryField> fields) async {
    //await _ref
    var items = await WhereQueryField.toQuery(fields, ref).getDocuments();
    return parse(items);
  }

  Stream<List<FirebaseResult>> getWithWhereQueryStream(List<WhereQueryField> fields) {
    var query = WhereQueryField.toQuery(fields, ref);
    var stream = query.snapshots();
    return stream.map<List<FirebaseResult>>((s) => parse(s));
  }

  List<FirebaseResult> parse(QuerySnapshot docs) {
    if (docs.documents.isEmpty) return null;
    return List<FirebaseResult>.from(
        docs.documents.map((d) => FirebaseResult(id: d.documentID, data: d.data, snapshot: d)));
  }
}
