import 'package:flutter/material.dart';

import '../models/schedule_item.dart';
import '../theme/app_theme.dart';

/// Halaman detail jadwal (mode HP). Data diterima lewat constructor.
class ScheduleDetailScreen extends StatelessWidget {
  const ScheduleDetailScreen({
    super.key,
    required this.item,
    this.color = AppColors.strawberry,
  });

  final ScheduleItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Tutup',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(child: ScheduleDetailView(item: item, color: color)),
    );
  }
}

/// Isi detail jadwal. Dipakai ulang oleh halaman detail (HP)
/// dan panel kanan (layar lebar).
class ScheduleDetailView extends StatelessWidget {
  const ScheduleDetailView({
    super.key,
    required this.item,
    this.color = AppColors.strawberry,
  });

  final ScheduleItem item;
  final Color color;

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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            InfoRow(
              color: color,
              label: 'Ruang',
              value: item.room,
              icon: Icons.location_on_outlined,
            ),
            InfoRow(
              color: AppColors.limeade,
              label: 'Dosen',
              value: item.lecturer,
              icon: Icons.person_outline_rounded,
            ),
            InfoRow(
              color: AppColors.blueberry,
              label: 'Hari',
              value: item.day,
              icon: Icons.today_rounded,
            ),
            if (item.note != null)
              InfoRow(
                color: AppColors.strawberry,
                label: 'Catatan',
                value: item.note!,
                icon: Icons.sticky_note_2_outlined,
              ),
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
              style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
