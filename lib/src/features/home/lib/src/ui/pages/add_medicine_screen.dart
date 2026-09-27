import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ReminderTime {
  final String? slotId;
  final String time;
  final String? scheduledAt;
  final String? status;

  ReminderTime({
    this.slotId,
    required this.time,
    this.scheduledAt,
    this.status,
  });

  ReminderTime copyWith({
    String? slotId,
    String? time,
    String? scheduledAt,
    String? status,
  }) {
    return ReminderTime(
      slotId: slotId ?? this.slotId,
      time: time ?? this.time,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
    );
  }
}

class Medicine {
  String? id;
  String name;
  String dosage;
  String frequency;
  String? frequencyType;
  String? dayOfWeek;
  String duration;
  List<ReminderTime> reminderTimes;
  bool hasWarning;
  String? warningDetail;

  Medicine({
    this.id,
    this.name = '',
    this.dosage = '',
    this.frequency = 'Once daily',
    this.frequencyType,
    this.dayOfWeek,
    this.duration = '',
    this.reminderTimes = const [],
    this.hasWarning = false,
    this.warningDetail,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? frequencyType,
    String? dayOfWeek,
    String? duration,
    List<ReminderTime>? reminderTimes,
    bool? hasWarning,
    String? warningDetail,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      frequencyType: frequencyType ?? this.frequencyType,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      duration: duration ?? this.duration,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      hasWarning: hasWarning ?? this.hasWarning,
      warningDetail: warningDetail ?? this.warningDetail,
    );
  }
}

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  final bool isEditing;

  const AddMedicineScreen({super.key, this.medicine, this.isEditing = false});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _durationController;
  String _selectedFrequency = 'Once daily';
  List<ReminderTime> _reminderTimes = [ReminderTime(time: '08:00')];

  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice a day',
    'Three times a day',
    'Four times a day',
    'As needed',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name ?? '');
    _dosageController = TextEditingController(
      text: widget.medicine?.dosage ?? '',
    );
    _durationController = TextEditingController(
      text: widget.medicine?.duration ?? '',
    );
    if (widget.medicine != null) {
      _selectedFrequency = widget.medicine!.frequency;
      _reminderTimes = List.from(widget.medicine!.reminderTimes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final time =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (!_reminderTimes.any((r) => r.time == time)) {
          _reminderTimes.add(ReminderTime(time: time));
          _reminderTimes.sort((a, b) => a.time.compareTo(b.time));
        }
      });
    }
  }

  void _removeReminderTime(ReminderTime time) {
    setState(() {
      _reminderTimes.removeWhere((r) => r == time || r.time == time.time);
    });
  }

  void _showFrequencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _frequencyOptions.map((freq) {
            return ListTile(
              title: Text(
                freq,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: _selectedFrequency == freq
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _selectedFrequency == freq
                      ? AppColors.primaryTeal
                      : const Color(0xFF1A2B35),
                ),
              ),
              trailing: _selectedFrequency == freq
                  ? const Icon(Icons.check, color: AppColors.primaryTeal)
                  : null,
              onTap: () {
                setState(() => _selectedFrequency = freq);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _saveMedicine() {
    // When editing, keep id/frequencyType/dayOfWeek so activate-reminders
    // updates the existing medicine instead of deleting and recreating it.
    final existing = widget.medicine;
    final medicine = existing != null
        ? existing.copyWith(
            name: _nameController.text,
            dosage: _dosageController.text,
            frequency: _selectedFrequency,
            duration: _durationController.text,
            reminderTimes: _reminderTimes,
            hasWarning: false,
          )
        : Medicine(
            name: _nameController.text,
            dosage: _dosageController.text,
            frequency: _selectedFrequency,
            duration: _durationController.text,
            reminderTimes: _reminderTimes,
          );
    CcRouteHelper.pop(args: medicine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.8, -0.8),
          end: Alignment(0.8, 0.8),
          colors: [Color(0xFF0D1F2D), Color(0xFF055F58)],
          stops: [0.085, 0.915],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => CcRouteHelper.pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.isEditing ? 'Edit Medicine' : 'Add Medicine',
                style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isEditing
                    ? 'Update the medicine details'
                    : 'Manually add a medicine to your prescription',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7FBFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              'MEDICINE NAME',
              'e.g., Paracetamol',
              _nameController,
            ),
            const SizedBox(height: 18),
            _buildTextField('DOSAGE', 'e.g., 500mg', _dosageController),
            const SizedBox(height: 18),
            _buildFrequencySelector(),
            const SizedBox(height: 18),
            _buildTextField('DURATION', 'e.g., 5 days', _durationController),
            const SizedBox(height: 18),
            _buildReminderTimes(),
            const SizedBox(height: 22),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7A96A4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4EEF2), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D1F2D).withValues(alpha: 0.04),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A2B35),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7A96A4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENCY',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7A96A4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showFrequencyPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4EEF2), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D1F2D).withValues(alpha: 0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFrequency,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A2B35),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF7A96A4),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REMINDER TIMES',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7A96A4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._reminderTimes.map((time) => _buildTimeChip(time)),
            _buildAddTimeChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(ReminderTime reminder) {
    return GestureDetector(
      onLongPress: () => _removeReminderTime(reminder),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentTealDark, width: 1.3),
        ),
        child: Text(
          reminder.time,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildAddTimeChip() {
    return GestureDetector(
      onTap: _addReminderTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7A96A4),
            width: 1.3,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Text(
          '+ Add',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7A96A4),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.8),
          end: Alignment(0.8, 0.8),
          colors: [AppColors.accentTealDark, AppColors.primaryTeal],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentTealDark.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveMedicine,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Confirm',
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
