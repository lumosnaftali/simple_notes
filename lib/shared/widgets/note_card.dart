import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../features/notes/data/note_model.dart';
import '../../../features/tags/viewmodel/tags_viewmodel.dart';

class NoteCard extends ConsumerWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(tagsViewModelProvider);
    final noteTags = allTags.where((tag) => note.tagIds.contains(tag.id)).toList();

    final theme = Theme.of(context);
    final dateString = DateFormat.yMMMd().add_jm().format(note.updatedAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : 'Untitled Note',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: note.title.isNotEmpty 
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content.isNotEmpty ? note.content : 'No content',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: note.content.isNotEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontStyle: note.content.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    dateString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              if (noteTags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: noteTags.map((tag) {
                    final color = Color(int.parse(tag.colorHex.replaceFirst('#', '0xff')));
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Color.alphaBlend(color.withValues(alpha: 0.9), theme.colorScheme.onSurface),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
