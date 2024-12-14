import 'package:flutter/material.dart';
import 'package:notes_app/note.dart';
import 'package:notes_app/note_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();
  //search status
  bool isSearching = false;

  //filter status
  bool isFilteredByFavorite = false;

  // Search controller
  final searchController = TextEditingController();

  // final searchController = TextEditingController();

  // Note database
  final _noteDatabase = NoteDatabase();
  // String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: isSearching
              ? TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search notes',
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                  onChanged: (value) => setState(() {}),
                )
              : const Text('Notes'),
          actions: [
            IconButton(
              onPressed: () => setState(() => isSearching = !isSearching),
              icon: Icon(isSearching ? Icons.close : Icons.search),
            ),
            IconButton(
              onPressed: () =>
                  setState(() => isFilteredByFavorite = !isFilteredByFavorite),
              icon: Icon(isFilteredByFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
            ),
          ]
          // bottom: PreferredSize(
          //   preferredSize: const Size.fromHeight(60),
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: TextField(
          //       controller: searchController,
          //       onChanged: (value) {
          //         setState(() {
          //           searchQuery = value;
          //         });
          //       },
          //       decoration: InputDecoration(
          //         hintText: 'Search ...',
          //         prefixIcon: const Icon(Icons.search),
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          ),
      body: StreamBuilder(
        stream: _noteDatabase.getNotesStream(),
        builder: (context, snapshot) {
          // loading ...
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // loaded
          final notes = snapshot.data!;
          final searchedNotes = searchController.text.isEmpty
              ? notes
              : notes
                  .where((note) => note.content
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();
          // Filter by favorite
          final filteredNotes = isFilteredByFavorite
              ? searchedNotes
                  .where((searchedNotes) => searchedNotes.isFavorite)
                  .toList()
              : searchedNotes;

          // final filteredNotes = notes
          //   .where((note) => note.content
          //     .toLowerCase()
          //     .contains(searchQuery.toLowerCase()))
          //   .toList();

          // Empty state
          if (searchedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(searchController.text.isEmpty
                      ? 'No notes found'
                      : 'No results found'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addNewNote,
                    child: const Text('Add a note'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (filteredNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(searchController.text.isEmpty
                      ? 'No notes found'
                      : 'No results found'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addNewNote,
                    child: const Text('Add a note'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(filteredNotes[index].content),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editNote(searchedNotes[index]),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => deleteNote(searchedNotes[index]),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
              leading: filteredNotes[index].isFavorite
                  ? GestureDetector(
                      onTap: () => toggleFavorite(filteredNotes[index]),
                      child: Icon(Icons.favorite, color: Colors.red))
                  : GestureDetector(
                      onTap: () => toggleFavorite(filteredNotes[index]),
                      child: Icon(Icons.favorite_border)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addNewNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Note'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Create a new note
              final note = Note(
                content: textController.text,
                isFavorite: false,
              );

              // Save the note to the database
              _noteDatabase.insertNote(note);

              // Close the dialog
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveNote() async {
    await Supabase.instance.client.from('notes').insert({
      'body': textController.text,
    });
    textController.clear();
  }

  // Edit a note
  void editNote(Note note) {
    // controller
    textController.text = note.content;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Update
              note.content = textController.text;
              _noteDatabase.updateNote(note);

              // Close
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete
  void deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Note'),
        content: Text('Yakin Hapus Note Ini?\n\n"${note.content}"'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Hapus'),
                  content: const Text(
                      'Note akan dihapus secara permanen. Apakah Anda yakin?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _noteDatabase.deleteNote(note.id!);
                        Navigator.pop(context);
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void toggleFavorite(Note note) {
    note.isFavorite = !note.isFavorite;
    _noteDatabase.updateNote(note);
  }
}