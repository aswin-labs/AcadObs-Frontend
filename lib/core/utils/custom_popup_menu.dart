import 'package:flutter/material.dart';

class CustomPopupMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEdit;
  final bool showDelete;

  const CustomPopupMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.showEdit = true,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      onSelected: (value) {
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        if (showEdit) {
          items.add(_buildMenuItem('edit', Icons.edit, 'Edit', Colors.blueAccent));
        }
        if (showDelete) {
          items.add(_buildMenuItem('delete', Icons.delete, 'Delete', Colors.redAccent));
        }
        return items;
      },
      icon: const Icon(Icons.more_vert, color: Colors.black54),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, IconData icon, String text, Color iconColor) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
