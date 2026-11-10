import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final AgencySettings currentSettings;
  final ValueChanged<AgencySettings> onSettingsUpdated;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
    required this.onSettingsUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _baseRateController;
  late final TextEditingController _agencyNameController;
  late final TextEditingController _founderNameController;
  late final TextEditingController _taglineController;
  late Currency _selectedCurrency;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _baseRateController = TextEditingController(
      text: widget.currentSettings.baseRateINR.toStringAsFixed(0),
    );
    _agencyNameController = TextEditingController(
      text: widget.currentSettings.agencyName,
    );
    _founderNameController = TextEditingController(
      text: widget.currentSettings.founderName,
    );
    _taglineController = TextEditingController(
      text: widget.currentSettings.tagline,
    );
    _selectedCurrency = widget.currentSettings.currency;
  }

  @override
  void dispose() {
    _baseRateController.dispose();
    _agencyNameController.dispose();
    _founderNameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final double? parsedRate = double.tryParse(_baseRateController.text.trim());
    if (parsedRate == null || parsedRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive base rate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = AgencySettings(
      baseRateINR: parsedRate,
      currency: _selectedCurrency,
      agencyName: _agencyNameController.text.trim().isEmpty
          ? 'CraftStudio Digital'
          : _agencyNameController.text.trim(),
      founderName: _founderNameController.text.trim().isEmpty
          ? 'Alex Morgan'
          : _founderNameController.text.trim(),
      tagline: _taglineController.text.trim().isEmpty
          ? 'High-Performance Web Solutions'
          : _taglineController.text.trim(),
    );

    await StorageService.saveSettings(updated);
    widget.onSettingsUpdated(updated);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings and Agency Profile saved successfully!'),
          backgroundColor: AppTheme.accentEmeraldDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency & Pricing Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Commercial Baseline Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.currency_exchange_rounded, color: AppTheme.primarySky, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pricing Baseline & Currency',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Set your base 5-page standard project rate in INR. Foreign currency proposals are auto-converted.',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.slate600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _baseRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Base Project Rate (INR ₹)',
                      hintText: '15000',
                      prefixText: '₹ ',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Active Proposal Currency',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate800),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<Currency>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: Currency.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Text(
                              '${c.symbol} ${c.code}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              c == Currency.inr
                                  ? '(1.0x Base Anchor)'
                                  : '(${c.multiplier}x conversion factor)',
                              style: const TextStyle(color: AppTheme.slate500, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Agency Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.business_center_outlined, color: AppTheme.primarySky, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Agency Profile & Letterhead',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Appears on official A4 PDF proposals, WhatsApp signoffs, and milestones.',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.slate600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _agencyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Agency / Studio Name',
                      hintText: 'e.g. CraftStudio Digital',
                      prefixIcon: Icon(Icons.domain_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _founderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Founder / Lead Engineer Name',
                      hintText: 'e.g. Alex Morgan',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _taglineController,
                    decoration: const InputDecoration(
                      labelText: 'Tagline / Value Proposition',
                      hintText: 'e.g. High-Performance Web Solutions',
                      prefixIcon: Icon(Icons.auto_awesome_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // System Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security_outlined, color: AppTheme.accentEmerald, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '100% Offline & Private',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'QuoteCraft stores all client names, quotations, and agency data 100% locally on your device in secure SharedPreferences. No analytics, tracking, or cloud database dependencies.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? 'Saving...' : 'Save Settings to Device'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primarySky,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
