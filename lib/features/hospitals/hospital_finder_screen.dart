import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/hospitals.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';

class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});

  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  final _searchController = TextEditingController();

  String? _selectedCity;
  String? _selectedArea;
  HospitalSpecialty? _selectedSpecialty;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hospital> get _filtered => Hospitals.filter(
        city: _selectedCity,
        area: _selectedArea,
        specialty: _selectedSpecialty,
        query: _query.isEmpty ? null : _query,
      );

  void _clearAll() {
    setState(() {
      _selectedCity = null;
      _selectedArea = null;
      _selectedSpecialty = null;
      _query = '';
      _searchController.clear();
    });
  }

  bool get _hasFilters =>
      _selectedCity != null ||
      _selectedArea != null ||
      _selectedSpecialty != null ||
      _query.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppHeader(
            eyebrow: 'Health',
            title: 'Find Hospitals',
          ),

          // ── Search bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: _SearchBar(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // ── Filter chips row ────────────────────────
          _FilterRow(
            selectedCity: _selectedCity,
            selectedArea: _selectedArea,
            selectedSpecialty: _selectedSpecialty,
            hasFilters: _hasFilters,
            onCityTap: () => _showCitySheet(context),
            onAreaTap: () => _showAreaSheet(context),
            onSpecialtyTap: () => _showSpecialtySheet(context),
            onClear: _clearAll,
          ),

          // ── Result count ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Text(
                  '${results.length} hospital${results.length == 1 ? '' : 's'} found',
                  style: AppText.caption(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.hairline),

          // ── List ────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    headline: 'No hospitals found',
                    body: 'Try adjusting your filters or search term.',
                    drop: AppColors.hairlineStrong,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _HospitalCard(hospital: results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheets ──────────────────────────────────

  void _showCitySheet(BuildContext context) {
    _showPickerSheet(
      context: context,
      title: 'Select City',
      items: Hospitals.cities,
      selected: _selectedCity,
      onSelect: (v) => setState(() {
        _selectedCity = v;
        _selectedArea = null; // reset area when city changes
      }),
    );
  }

  void _showAreaSheet(BuildContext context) {
    final areas = _selectedCity != null
        ? Hospitals.areasForCity(_selectedCity!)
        : <String>[];

    if (areas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a city first to filter by area')),
      );
      return;
    }

    _showPickerSheet(
      context: context,
      title: 'Select Area',
      items: areas,
      selected: _selectedArea,
      onSelect: (v) => setState(() => _selectedArea = v),
    );
  }

  void _showSpecialtySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (_) => _SpecialtySheet(
        selected: _selectedSpecialty,
        onSelect: (s) {
          setState(() => _selectedSpecialty = s);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showPickerSheet({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String? selected,
    required ValueChanged<String?> onSelect,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (_) => _ListPickerSheet(
        title: title,
        items: items,
        selected: selected,
        onSelect: (v) {
          onSelect(v);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  SEARCH BAR
// ════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.hairlineStrong, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search_rounded, size: 18, color: AppColors.inkMuted),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.body(size: 14),
              cursorColor: AppColors.maroon,
              cursorWidth: 1.4,
              decoration: InputDecoration(
                hintText: 'Search by name, area or city…',
                hintStyle: AppText.body(color: AppColors.inkFaint, size: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.inkMuted),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  FILTER CHIPS ROW
//  FIX: chips now truncate long labels; row is horizontally scrollable
// ════════════════════════════════════════════════════

class _FilterRow extends StatelessWidget {
  final String? selectedCity;
  final String? selectedArea;
  final HospitalSpecialty? selectedSpecialty;
  final bool hasFilters;
  final VoidCallback onCityTap;
  final VoidCallback onAreaTap;
  final VoidCallback onSpecialtyTap;
  final VoidCallback onClear;

  const _FilterRow({
    required this.selectedCity,
    required this.selectedArea,
    required this.selectedSpecialty,
    required this.hasFilters,
    required this.onCityTap,
    required this.onAreaTap,
    required this.onSpecialtyTap,
    required this.onClear,
  });

  // Truncate label to avoid chip overflow
  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
        children: [
          if (hasFilters) ...[
            _FilterChip(
              label: 'Clear all',
              icon: Icons.close_rounded,
              active: false,
              isDanger: true,
              onTap: onClear,
            ),
            const SizedBox(width: 8),
          ],
          _FilterChip(
            label: selectedCity != null
                ? _truncate(selectedCity!, 12)
                : 'City',
            icon: Icons.location_city_outlined,
            active: selectedCity != null,
            onTap: onCityTap,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: selectedArea != null
                ? _truncate(selectedArea!.split('/').first.trim(), 14)
                : 'Area',
            icon: Icons.place_outlined,
            active: selectedArea != null,
            onTap: onAreaTap,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: selectedSpecialty != null
                ? _truncate(selectedSpecialty!.label, 16)
                : 'Specialty',
            icon: Icons.medical_services_outlined,
            active: selectedSpecialty != null,
            onTap: onSpecialtyTap,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool isDanger;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;

    if (isDanger) {
      bg = Colors.transparent;
      fg = AppColors.danger;
      border = AppColors.danger;
    } else if (active) {
      bg = AppColors.maroon;
      fg = AppColors.onMaroon;
      border = AppColors.maroon;
    } else {
      bg = Colors.transparent;
      fg = AppColors.ink;
      border = AppColors.hairlineStrong;
    }

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        side: BorderSide(color: border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppText.caption(color: fg, size: 12)
                    .copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              if (!isDanger) ...[
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  HOSPITAL CARD
//  FIX: specialty pills capped at 3 + overflow badge; tight layout
// ════════════════════════════════════════════════════

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    // Cap specialty display at 3 to avoid overflow
    final visibleSpecs = hospital.specialties.take(3).toList();
    final extraCount = hospital.specialties.length - visibleSpecs.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hairline, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header band ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    size: 17,
                    color: AppColors.onMaroon,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: AppText.title(size: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 11, color: AppColors.inkMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${hospital.area}, ${hospital.city}',
                              style: AppText.caption(
                                  color: AppColors.inkMuted, size: 11.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: const Icon(Icons.home_outlined,
                          size: 13, color: AppColors.inkMuted),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style:
                            AppText.body(color: AppColors.inkMuted, size: 12.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 13, color: AppColors.inkMuted),
                    const SizedBox(width: 6),
                    Text(
                      hospital.phone,
                      style:
                          AppText.body(color: AppColors.inkMuted, size: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Specialty pills — max 3 shown + overflow count badge
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...visibleSpecs.map((s) => _SpecialtyPill(specialty: s)),
                    if (extraCount > 0)
                      _MorePill(count: extraCount),
                  ],
                ),

                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.hairline),
                const SizedBox(height: 10),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        onTap: () => _call(hospital.phone),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.map_outlined,
                        label: 'Directions',
                        primary: true,
                        onTap: () => _openMaps(hospital),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens phone dialler
  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens Google Maps — uses a plain web search URL that works on every device
  /// without Firebase Dynamic Links or short URLs.
  Future<void> _openMaps(Hospital h) async {
    // Encode hospital name + city as a Maps search query
    final query = Uri.encodeComponent('${h.name}, ${h.area}, ${h.city}, India');
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Specialty pill ──────────────────────────────────

class _SpecialtyPill extends StatelessWidget {
  final HospitalSpecialty specialty;
  const _SpecialtyPill({required this.specialty});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          border: Border.all(color: AppColors.hairline, width: 1),
        ),
        child: Text(
          specialty.label,
          style: AppText.caption(color: AppColors.ink, size: 11)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      );
}

// ── "+N more" overflow badge ─────────────────────────

class _MorePill extends StatelessWidget {
  final int count;
  const _MorePill({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          border: Border.all(color: AppColors.hairlineStrong, width: 1),
        ),
        child: Text(
          '+$count more',
          style: AppText.caption(color: AppColors.inkMuted, size: 11)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      );
}

// ── Action button ───────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = primary ? AppColors.maroon : Colors.transparent;
    final fg = primary ? AppColors.onMaroon : AppColors.maroon;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        side: BorderSide(color: AppColors.maroon, width: 1.2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppText.button(color: fg, size: 11.5)
                    .copyWith(letterSpacing: 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  BOTTOM SHEETS
// ════════════════════════════════════════════════════

class _ListPickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _ListPickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 38,
            height: 3,
            margin: const EdgeInsets.only(top: 12),
            color: AppColors.hairlineStrong,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text(title, style: AppText.title(size: 17)),
              const Spacer(),
              if (selected != null)
                GestureDetector(
                  onTap: () => onSelect(null),
                  child: Text(
                    'Clear',
                    style: AppText.body(color: AppColors.maroon, size: 13)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.hairline),
            itemBuilder: (_, i) {
              final item = items[i];
              final isSelected = item == selected;
              return InkWell(
                onTap: () => onSelect(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: AppText.body(
                            color: isSelected
                                ? AppColors.maroon
                                : AppColors.ink,
                            size: 14,
                          ).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_rounded,
                            size: 18, color: AppColors.maroon),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ],
    );
  }
}

class _SpecialtySheet extends StatelessWidget {
  final HospitalSpecialty? selected;
  final ValueChanged<HospitalSpecialty?> onSelect;

  const _SpecialtySheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 38,
            height: 3,
            margin: const EdgeInsets.only(top: 12),
            color: AppColors.hairlineStrong,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text('Select Specialty', style: AppText.title(size: 17)),
              const Spacer(),
              if (selected != null)
                GestureDetector(
                  onTap: () => onSelect(null),
                  child: Text(
                    'Clear',
                    style: AppText.body(color: AppColors.maroon, size: 13)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: HospitalSpecialty.values.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.hairline),
            itemBuilder: (_, i) {
              final s = HospitalSpecialty.values[i];
              final isSelected = s == selected;
              return InkWell(
                onTap: () => onSelect(s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.label,
                          style: AppText.body(
                            color: isSelected
                                ? AppColors.maroon
                                : AppColors.ink,
                            size: 14,
                          ).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_rounded,
                            size: 18, color: AppColors.maroon),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ],
    );
  }
}