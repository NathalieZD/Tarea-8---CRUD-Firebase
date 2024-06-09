import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController idController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  String estado = 'creado';
  bool importante = false;

  void openNoteBox({String? docID, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      idController.text = existingData['id'];
      descripcionController.text = existingData['descripcion'];
      fechaController.text = existingData['fecha'];
      estado = existingData['estado'];
      importante = existingData['importante'];
    } else {
      idController.clear();
      descripcionController.clear();
      fechaController.text = getCurrentDate();
      estado = 'creado';
      importante = false;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(labelText: 'ID'),
                  ),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: fechaController,
                    decoration:
                        InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: estado,
                    items: <String>[
                      'creado',
                      'por hacer',
                      'trabajando',
                      'finalizado'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        estado = newValue!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Estado'),
                  ),
                  Row(
                    children: [
                      Text("Importante"),
                      Checkbox(
                        value: importante,
                        onChanged: (value) {
                          setState(() {
                            importante = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              String fecha = fechaController.text;

              if (docID == null) {
                firestoreService.addNote(
                  idController.text,
                  descripcionController.text,
                  fecha,
                  estado,
                  importante,
                );
              } else {
                firestoreService.updateNote(
                  docID,
                  idController.text,
                  descripcionController.text,
                  fecha,
                  estado,
                  importante,
                );
              }

              idController.clear();
              descripcionController.clear();
              fechaController.clear();
              setState(() {
                estado = 'creado';
                importante = false;
              });

              Navigator.pop(context);
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notas")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String descripcion = data['descripcion'];

                return ListTile(
                  title: Text(descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            openNoteBox(docID: docID, existingData: data),
                        icon: const Icon(Icons.settings),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text("No Notas...");
          }
        },
      ),
    );
  }
}

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(String id, String descripcion, String fecha,
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

  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Future<void> updateNote(String docID, String id, String descripcion,
      String fecha, String estado, bool importante) {
    return notes.doc(docID).update({
      'id': id,
      'descripcion': descripcion,
      'fecha': fecha,
      'estado': estado,
      'importante': importante,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
