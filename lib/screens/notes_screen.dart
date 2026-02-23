import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/schedule_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<ScheduleProvider>().notes
        .where((n) => n.title.toLowerCase().contains(_search.toLowerCase()) || n.body.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
            GestureDetector(
              onTap: () => _openNote(context, null),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Color(0xFF6C63FF)),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search notes…',
              hintStyle: const TextStyle(color: Color(0xFF8888AA)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8888AA)),
              filled: true, fillColor: const Color(0xFF18181F),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E2E3D))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E2E3D))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF))),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: notes.isEmpty
          ? const Center(child: Text('No notes yet.\nTap + to create one.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8888AA))))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: notes.length,
              itemBuilder: (ctx, i) => _NoteCard(note: notes[i], onTap: () => _openNote(context, notes[i])),
            ),
        ),
      ])),
    );
  }

  void _openNote(BuildContext context, Note? note) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)));
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.onTap});

  static const _colors = [Color(0xFF6C63FF), Color(0xFFFF6B6B), Color(0xFF43E97B), Color(0xFFF7971E), Color(0xFF4FACFE)];

  @override
  Widget build(BuildContext context) {
    final accent = _colors[note.id.hashCode % _colors.length];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF18181F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E2E3D)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 28, height: 3, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          Text(note.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          if (note.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8888AA), height: 1.5)),
          ],
          const SizedBox(height: 8),
          Text(DateFormat('EEE, dd MMM yyyy · HH:mm').format(note.updatedAt),
            style: const TextStyle(fontSize: 10, color: Color(0xFF555577), fontFamily: 'monospace')),
        ]),
      ),
    );
  }
}

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  const NoteEditScreen({super.key, this.note});
  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    final provider = context.read<ScheduleProvider>();
    final now = DateTime.now();
    if (widget.note != null) {
      provider.updateNote(widget.note!.copyWith(
        title: _titleCtrl.text.trim(), body: _bodyCtrl.text, updatedAt: now));
    } else {
      provider.addNote(Note(
        id: provider.generateId(),
        title: _titleCtrl.text.trim(), body: _bodyCtrl.text,
        createdAt: now, updatedAt: now,
      ));
    }
    Navigator.pop(context);
  }

  void _delete() {
    if (widget.note != null) {
      context.read<ScheduleProvider>().deleteNote(widget.note!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F13), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.note != null ? 'Edit Note' : 'New Note', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (widget.note != null)
            IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)), onPressed: _delete),
          TextButton(onPressed: _save, child: const Text('Save', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              hintText: 'Note title…',
              hintStyle: TextStyle(color: Color(0xFF8888AA), fontSize: 20, fontWeight: FontWeight.w700),
              border: InputBorder.none,
            ),
          ),
          const Divider(color: Color(0xFF2E2E3D)),
          const SizedBox(height: 8),
          Expanded(child: TextField(
            controller: _bodyCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
            maxLines: null, expands: true,
            decoration: const InputDecoration(
              hintText: 'Start writing…',
              hintStyle: TextStyle(color: Color(0xFF8888AA)),
              border: InputBorder.none,
            ),
          )),
        ]),
      ),
    );
  }
}
