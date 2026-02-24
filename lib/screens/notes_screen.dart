import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/schedule_provider.dart';
import '../services/purchase_service.dart';
import 'paywall_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _search = '';

  void _openNote(BuildContext context, {Note? note}) {
    final purchase = context.read<PurchaseService>();
    final provider = context.read<ScheduleProvider>();

    if (note == null && !purchase.isPremium && provider.notes.length >= 1) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const PaywallScreen(reason: 'Free users can only have 1 note. Upgrade to add unlimited notes.')));
      return;
    }

    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final bodyCtrl = TextEditingController(text: note?.body ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subColor = isDark ? const Color(0xFF8888AA) : const Color(0xFF666688);
        final fieldBg = isDark ? const Color(0xFF0F0F13) : const Color(0xFFF0F0F5);

        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Text(note == null ? 'New Note' : 'Edit Note',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                const Spacer(),
                if (note != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                    onPressed: () {
                      provider.deleteNote(note.id);
                      Navigator.pop(ctx);
                    },
                  ),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: subColor),
                  filled: true, fillColor: fieldBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyCtrl,
                style: TextStyle(color: textColor),
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  hintStyle: TextStyle(color: subColor),
                  filled: true, fillColor: fieldBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    if (note == null) {
                      provider.addNote(Note(
                        id: provider.generateId(),
                        title: titleCtrl.text.trim(),
                        body: bodyCtrl.text.trim(),
                        createdAt: DateTime.now(),
                      ));
                    } else {
                      provider.updateNote(note.copyWith(
                        title: titleCtrl.text.trim(),
                        body: bodyCtrl.text.trim(),
                      ));
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final purchase = context.watch<PurchaseService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F13) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? const Color(0xFF8888AA) : const Color(0xFF666688);
    final surface = isDark ? const Color(0xFF18181F) : const Color(0xFFF5F5F5);
    final border = isDark ? const Color(0xFF2E2E3D) : const Color(0xFFE0E0E0);

    final filtered = provider.notes.where((n) =>
      _search.isEmpty ||
      n.title.toLowerCase().contains(_search.toLowerCase()) ||
      n.body.toLowerCase().contains(_search.toLowerCase())).toList();

    final canAddNote = purchase.isPremium || provider.notes.isEmpty;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                Text('Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor)),
                const Spacer(),
                if (!purchase.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${provider.notes.length}/1 free',
                      style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: subColor),
                  prefixIcon: Icon(Icons.search, color: subColor),
                  filled: true, fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.note_outlined, color: subColor, size: 48),
                    const SizedBox(height: 12),
                    Text('No notes yet', style: TextStyle(color: subColor)),
                    const SizedBox(height: 8),
                    Text('Tap + to create your first note', style: TextStyle(color: subColor, fontSize: 12)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final note = filtered[i];
                      return GestureDetector(
                        onTap: () => _openNote(context, note: note),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(note.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                            if (note.body.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: subColor, fontSize: 13)),
                            ],
                          ]),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(context),
        backgroundColor: canAddNote ? const Color(0xFF6C63FF) : Colors.grey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
