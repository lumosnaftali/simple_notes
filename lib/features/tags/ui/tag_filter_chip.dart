import 'package:flutter/material.dart';
import '../data/tag_model.dart';

class TagFilterChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const TagFilterChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(tag.colorHex.replaceFirst('#', '0xff')));
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected 
            ? Color.alphaBlend(color.withValues(alpha: 0.9), theme.colorScheme.onSurface)
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : theme.colorScheme.outlineVariant,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
