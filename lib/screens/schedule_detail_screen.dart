import 'package:flutter/material.dart';

import '../models/schedule_item.dart';
import '../state/schedule_controller.dart';
import '../theme/app_theme.dart';
import 'schedule_form_screen.dart';

/// Dialog konfirmasi hapus jadwal (dipakai di HP dan laptop).
Future<bool> confirmDeleteSchedule(BuildContext context, ScheduleItem item) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus jadwal?'),
      content: Text('Jadwal "${item.course}" hari ${item.day} akan dihapus.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Halaman detail jadwal (mode HP). Data diterima lewat constructor.
class ScheduleDetailScreen extends StatefulWidget {
  const ScheduleDetailScreen({
    super.key,
    required this.item,
    required this.controller,
    this.color = AppColors.rose,
  });

  final ScheduleItem item;
  final ScheduleController controller;
  final Color color;

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  late ScheduleItem _item = widget.item;

  Future<void> _edit() async {
    // Data hasil edit dikirim balik dari form lewat Navigator.pop.
    final updated = await Navigator.of(context).push<ScheduleItem>(
      MaterialPageRoute(builder: (_) => ScheduleFormScreen(initial: _item)),
    );
    if (updated == null) return;
    await widget.controller.update(updated);
    if (!mounted) return;
    setState(() => _item = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal diperbarui')),
    );
  }

  Future<void> _delete() async {
    final ok = await confirmDeleteSchedule(context, _item);
    if (!ok) return;
    await widget.controller.delete(_item.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Tutup',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton.outlined(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _delete,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: ScheduleDetailView(item: _item, color: widget.color),
      ),
    );
  }
}

/// Isi detail jadwal. Dipakai ulang oleh halaman detail (HP)
/// dan panel kanan (layar lebar).
class ScheduleDetailView extends StatelessWidget {
  const ScheduleDetailView({
    super.key,
    required this.item,
    this.color = AppColors.rose,
    this.onEdit,
    this.onDelete,
  });

  final ScheduleItem item;
  final Color color;
  final VoidCallback? onEdit; // tombol edit (dipakai di panel layar lebar)
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: DarkPill(text: item.time)),
            const SizedBox(height: 20),
            Text(
              item.course,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontFamily: AppFonts.title,
 fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Kuliah hari ${item.day}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            const Text(
              'Info Kelas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontFamily: AppFonts.title,
 fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            InfoRow(
              color: color,
              label: 'Ruang',
              value: item.room,
              icon: Icons.location_on_outlined,
            ),
            InfoRow(
              color: AppColors.mustard,
              label: 'Dosen',
              value: item.lecturer,
              icon: Icons.person_outline_rounded,
            ),
            InfoRow(
              color: AppColors.sage,
              label: 'Hari',
              value: item.day,
              icon: Icons.today_rounded,
            ),
            if (item.note != null)
              InfoRow(
                color: AppColors.rose,
                label: 'Catatan',
                value: item.note!,
                icon: Icons.sticky_note_2_outlined,
              ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 12),
                  if (onDelete != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Hapus'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pill gelap berisi teks (contoh: jam kuliah / deadline).
class DarkPill extends StatelessWidget {
  const DarkPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Baris info berwarna (label kiri, nilai kanan).
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.icon,
  });

  final Color color;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.ink;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ink, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: ink, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: ink, fontFamily: AppFonts.title,
 fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
