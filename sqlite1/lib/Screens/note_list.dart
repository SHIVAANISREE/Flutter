import 'package:flutter/material.dart';
import 'package:sqlite/Screens/note_details.dart';
import 'package:sqlite/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/note.dart';
import 'package:csv/csv.dart';
import 'package:share/share.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;

  // Add this method to export the data as a CSV file
  void _exportAsCSV() async {
    List<Note> noteList = await databaseHelper.getNoteList();

    List<List<dynamic>> csvData = [
      ['id', 'title', 'description', 'date', 'priority']
    ];

    for (Note note in noteList) {
      csvData.add(
          [note.id, note.title, note.description, note.date, note.priority]);
    }

    String csv = ListToCsvConverter().convert(csvData);

    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${appDocumentsDirectory.path}/notes.csv';

    File file = File(filePath);
    await file.writeAsString(csv);

    Share.shareFiles([filePath], text: 'CSV file of notes');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateListView(); // Call updateListView in didChangeDependencies.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
              onPressed: () {
                _exportAsCSV();
              },
              icon: Icon(Icons.share))
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: databaseHelper.getNoteList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Note> noteList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                Note note = noteList[index];
                return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getPriorityColor(note.priority),
                      child: getPriorityIcon(note.priority),
                    ),
                    title: Text(note.title),
                    subtitle: Text(note.date),
                    trailing: GestureDetector(
                      child: Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _delete(context, note);
                      },
                    ),
                    onTap: () {
                      debugPrint('ListTile is Tapped');
                      navigateToDetail(note, 'Edit Note');
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Floating Action button is clicked");
          navigateToDetail(Note('', 2, '', ''), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    if (noteList.isEmpty) {
      return ListView(
        children: [
          ListTile(
            title: Text('No notes found.'),
          ),
        ],
      );
    }

    // TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(this.noteList[position].title),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                debugPrint('ListTile is Tapped');
                navigateToDetail(this.noteList[position], 'Edit Text');
              },
            ),
          );
        });
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(title, note, databaseHelper);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
