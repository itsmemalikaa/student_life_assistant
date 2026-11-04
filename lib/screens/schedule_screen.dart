import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/schedule_item.dart';
import '../state/schedule_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy.dart';
import '../widgets/state_views.dart';
import 'schedule_detail_screen.dart';
import 'schedule_form_screen.dart';

/// Warna blok jadwal bergantian.
const _blockColors = [
  AppColors.rose,
  AppColors.mustard,
  AppColors.sage,
];

/// Jadwal kuliah model kalender:
/// - pemilih hari (Senin–Jumat) di atas,
/// - timeline blok berwarna di bawah.
/// Layout ADAPTIF: di layar lebar (>= 840 px) detail tampil di samping.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.controller});

  final ScheduleController controller;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late String _selectedDay;
  int _selectedIndex = 0; // item terpilih untuk panel detail (layar lebar)

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday; // 1 = Senin ... 7 = Minggu
    _selectedDay = weekday <= SampleData.days.length
        ? SampleData.days[weekday - 1]
        : SampleData.days.first;
  }

  List<ScheduleItem> get _itemsOfDay =>
      widget.controller.itemsOfDay(_selectedDay);

  /// Buka form tambah jadwal, tunggu hasilnya, lalu simpan.
  Future<void> _addSchedule() async {
    final result = await Navigator.of(context).push<ScheduleItem>(
      MaterialPageRoute(
        builder: (_) => ScheduleFormScreen(initialDay: _selectedDay),
      ),
    );
    if (result == null) return;
    await widget.controller.add(result);
    if (!mounted) return;
    setState(() {
      _selectedDay = result.day; // langsung tampilkan hari jadwal baru
      _selectedIndex = widget.controller
          .itemsOfDay(result.day)
          .indexWhere((i) => i.id == result.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jadwal "${result.course}" ditambahkan')),
    );
  }

  Future<void> _editSchedule(ScheduleItem item) async {
    final result = await Navigator.of(context).push<ScheduleItem>(
      MaterialPageRoute(builder: (_) => ScheduleFormScreen(initial: item)),
    );
    if (result == null) return;
    await widget.controller.update(result);
    if (!mounted) return;
    setState(() => _selectedDay = result.day);
  }

  Future<void> _deleteSchedule(ScheduleItem item) async {
    final ok = await confirmDeleteSchedule(context, item);
    if (!ok) return;
    await widget.controller.delete(item.id);
    if (!mounted) return;
    setState(() => _selectedIndex = 0);
  }

  /// Tanggal untuk hari ke-i minggu ini (0 = Senin).
  DateTime _dateOf(int index) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: index));
  }

  void _selectDay(String day) {
    setState(() {
      _selectedDay = day;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSchedule,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Jadwal'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            if (widget.controller.isLoading) {
              return const LoadingView(message: 'Memuat jadwal...');
            }
            final isWide = constraints.maxWidth >= 840;
            final items = _itemsOfDay;

            final timeline = Column(
              children: [
                _buildDaySelector(),
                const SizedBox(height: 8),
                Expanded(child: _buildTimeline(items, isWide)),
              ],
            );

            if (!isWide) return timeline;

            final safeIndex =
                (_selectedIndex >= 0 && _selectedIndex < items.length)
                    ? _selectedIndex
                    : 0;
            final selected = items.isEmpty ? null : items[safeIndex];

            return Row(
              children: [
                Expanded(flex: 3, child: timeline),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: selected == null
                      ? const EmptyView(
                          icon: Icons.event_available_rounded,
                          title: 'Tidak ada kuliah',
                          subtitle: 'Pilih hari lain.',
                        )
                      : ScheduleDetailView(
                          item: selected,
                          color:
                              _blockColors[safeIndex % _blockColors.length],
                          onEdit: () => _editSchedule(selected),
                          onDelete: () => _deleteSchedule(selected),
                        ),
                ),
              ],
            );
          },
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    const shortNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: SampleData.days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = SampleData.days[index];
          final isSelected = day == _selectedDay;

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _selectDay(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.wine : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? AppColors.wine : AppColors.rose,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_dateOf(index).day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: AppFonts.title,
 fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  Text(
                    shortNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.rose : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(List<ScheduleItem> items, bool isWide) {
    if (items.isEmpty) {
      return const EmptyView(
        icon: Icons.event_available_rounded,
        title: 'Tidak ada kuliah',
        subtitle: 'Hari ini bebas! Tekan "+ Jadwal" untuk menambah.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = _blockColors[index % _blockColors.length];
        final startTime = item.start;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    startTime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: _ScheduleBlock(
                  item: item,
                  color: color,
                  isSelected: isWide && index == _selectedIndex,
                  onTap: () {
                    if (isWide) {
                      setState(() => _selectedIndex = index);
                    } else {
                      // Kirim data jadwal terpilih ke halaman detail.
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ScheduleDetailScreen(
                            item: item,
                            color: color,
                            controller: widget.controller,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleBlock extends StatelessWidget {
  const _ScheduleBlock({
    required this.item,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final ScheduleItem item;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Bouncy(scale: 0.97, child: _content(context));
  }

  Widget _content(BuildContext context) {
    const ink = AppColors.ink;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.wineDark : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.course,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontFamily: AppFonts.title,
 fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: ink),
                        const SizedBox(width: 4),
                        Text(item.time, style: const TextStyle(color: ink)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: ink),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.room,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: ink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0x99FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
