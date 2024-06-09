import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //create
  Future<void> addNote(String id, String descripcion, DateTime fecha,
      String estado, bool importante) {
    return notes.add({
      'id': id,
      'descripcion': descripcion,
      'fecha': fecha,
      'estado': estado,
      'importante': importante,
      'timestamp': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  //update
  Future<void> updateNote(String docID, String id, String descripcion,
      DateTime fecha, String estado, bool importante) {
    return notes.doc(docID).update({
      'id': id,
      'descripcion': descripcion,
      'fecha': fecha,
      'estado': estado,
      'importante': importante,
      'timestamp': Timestamp.now(),
    });
  }

  // delete
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
