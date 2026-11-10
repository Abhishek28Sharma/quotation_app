import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../models/settings_model.dart';
import '../services/pricing_engine.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../services/sharing_service.dart';
import '../theme/app_theme.dart';

class GeneratorScreen extends StatefulWidget {
  final AgencySettings settings;
  final VoidCallback onQuoteSaved;

  const GeneratorScreen({
    super.key,
    required this.settings,
    required this.onQuoteSaved,
  });

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();

  WebsiteCategory _selectedCategory = WebsiteCategory.business;
  double _pageCount = 5;
  final Set<String> _selectedAddons = {
    'responsive',
    'whatsapp_leads',
    'seo',
    'post_launch_support',
  };
  ClientBudgetSensitivity _selectedSensitivity = ClientBudgetSensitivity.balanced;
  DeliveryUrgency _selectedUrgency = DeliveryUrgency.standard;

  bool _isSaving = false;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    super.dispose();
  }

  QuoteCalculationResult _getCalculation() {
    return PricingEngine.calculate(
      baseRateINR: widget.settings.baseRateINR,
      category: _selectedCategory,
      pageCount: _pageCount.round(),
      selectedAddonIds: _selectedAddons.toList(),
      sensitivity: _selectedSensitivity,
      urgency: _selectedUrgency,
      currency: widget.settings.currency,
    );
  }

  QuoteRecord _buildQuoteRecord({String? id, String? refCode}) {
    final calc = _getCalculation();
    return QuoteRecord(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      refCode: refCode ?? 'QC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}',
      clientName: _clientNameController.text.trim().isEmpty
          ? 'Valued Client'
          : _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      clientEmail: _clientEmailController.text.trim(),
      category: _selectedCategory,
      pageCount: _pageCount.round(),
      selectedAddonIds: _selectedAddons.toList(),
      sensitivity: _selectedSensitivity,
      urgency: _selectedUrgency,
      calculation: calc,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _handleSaveQuote() async {
    setState(() => _isSaving = true);
    final ref = await StorageService.generateNextRefCode();
    final quote = _buildQuoteRecord(refCode: ref);
    final success = await StorageService.saveQuote(quote);
    setState(() => _isSaving = false);

    if (mounted) {
      widget.onQuoteSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Quote ${quote.refCode} saved to offline history!' : 'Failed to save quote.',
          ),
          backgroundColor: success ? AppTheme.accentEmeraldDark : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleWhatsAppQuote() async {
    final quote = _buildQuoteRecord();
    await SharingService.sendWhatsAppQuote(
      quote: quote,
      settings: widget.settings,
    );
  }

  Future<void> _handlePdfProposal() async {
    final quote = _buildQuoteRecord();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Commercial Proposal Deliverable',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate client-ready A4 PDF with itemized milestones and 3-tier package options.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    PdfService.printOrPreviewProposal(
                      quote: quote,
                      settings: widget.settings,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('View & Print PDF (Offline A4)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primarySky,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    PdfService.shareProposalPdf(
                      quote: quote,
                      settings: widget.settings,
                    );
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share PDF Directly via App / Email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primarySky,
                    side: const BorderSide(color: AppTheme.primarySky),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calc = _getCalculation();
    final currency = widget.settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calculate_rounded, color: AppTheme.primarySky, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('QuoteCraft Engine'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Save Quote',
            onPressed: _isSaving ? null : _handleSaveQuote,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined, color: AppTheme.primarySky),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. LIVE RECOMMENDATION CARD
          _buildLiveRecommendationCard(calc, currency),

          const SizedBox(height: 16),

          // 2. CLIENT INFORMATION CARD
          _buildClientCard(),

          const SizedBox(height: 16),

          // 3. WEBSITE CATEGORY SELECTOR
          _buildCategorySelector(),

          const SizedBox(height: 16),

          // 4. PAGE COUNT SLIDER
          _buildPageSlider(),

          const SizedBox(height: 16),

          // 5. ADD-ON FEATURE MATRIX
          _buildAddonFeatureMatrix(),

          const SizedBox(height: 16),

          // 6. STRATEGY & URGENCY CONTROLS
          _buildStrategyAndUrgencyCard(),

          const SizedBox(height: 24),

          // 7. PRIMARY ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleWhatsAppQuote,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  label: const Text('WhatsApp Quote'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handlePdfProposal,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primarySky,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _isSaving ? null : _handleSaveQuote,
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Save Quote to Offline History'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: const BorderSide(color: AppTheme.borderSubtle),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLiveRecommendationCard(QuoteCalculationResult calc, Currency currency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RECOMMENDED TARGET PRICE',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primarySky.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primarySky.withOpacity(0.4)),
                ),
                child: Text(
                  currency.code,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Price
          Text(
            PricingEngine.formatAmount(calc.targetPrice, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 16),

          // 3-Tier Outputs & Metrics
          Row(
            children: [
              Expanded(
                child: _buildTierStat(
                  'Starter (Floor)',
                  PricingEngine.formatAmount(calc.starterPrice, currency),
                  '80% Safety Min',
                  const Color(0xFFFBBF24),
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF334155)),
              Expanded(
                child: _buildTierStat(
                  'Enterprise (Upsell)',
                  PricingEngine.formatAmount(calc.enterprisePrice, currency),
                  '132% Suite',
                  AppTheme.accentEmerald,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),

          // Dev Hours & Delivery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFF94A3B8), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '~${calc.totalDevHours} Dev Hours',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${calc.deliveryDays} Working Days',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierStat(String title, String price, String sub, Color accent) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 3),
        Text(
          price,
          style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildClientCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin_rounded, color: AppTheme.primarySky, size: 20),
                SizedBox(width: 8),
                Text(
                  'Client Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Client or Company Name',
                hintText: 'e.g. Acme Health Corp',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clientPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact / WhatsApp',
                      hintText: '+91 98765 43210',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _clientEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Client Email (Optional)',
                      hintText: 'client@domain.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.layers_outlined, color: AppTheme.primarySky, size: 20),
                SizedBox(width: 8),
                Text(
                  'Website Architecture Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select project scope baseline multiplier & architecture pattern:',
              style: TextStyle(fontSize: 13, color: AppTheme.slate600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WebsiteCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text('${cat.displayName} (${cat.multiplier}x)'),
                  selected: isSelected,
                  selectedColor: AppTheme.primarySky,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.slate900,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                        // For landing page, default to 1 page if user hasn't changed it
                        if (cat == WebsiteCategory.landingPage && _pageCount > 3) {
                          _pageCount = 1;
                        } else if (cat != WebsiteCategory.landingPage && _pageCount == 1) {
                          _pageCount = 5;
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.slate600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCategory.description,
                      style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSlider() {
    final int count = _pageCount.round();
    String pageBadge;
    Color badgeColor;

    if (count < 5) {
      pageBadge = 'Single / Sub-5 Page (-₹2,000 discount)';
      badgeColor = AppTheme.accentEmeraldDark;
    } else if (count == 5) {
      pageBadge = 'Standard 5-Page Baseline';
      badgeColor = AppTheme.primarySky;
    } else {
      final extra = count - 5;
      pageBadge = '+$extra Additional Pages (+₹${extra * 1200})';
      badgeColor = const Color(0xFFD97706);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_stories_outlined, color: AppTheme.primarySky, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Page Count Scaling',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count Pages',
                    style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _pageCount,
              min: 1,
              max: 25,
              divisions: 24,
              label: '$count Pages',
              activeColor: AppTheme.primarySky,
              onChanged: (val) {
                setState(() => _pageCount = val);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1 Page (Landing)', style: TextStyle(fontSize: 11, color: AppTheme.slate500)),
                Text(
                  pageBadge,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                ),
                const Text('25 Pages (Portal)', style: TextStyle(fontSize: 11, color: AppTheme.slate500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonFeatureMatrix() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.extension_outlined, color: AppTheme.primarySky, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add-on Feature Matrix',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '${_selectedAddons.length} Selected',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primarySky,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select client deliverables to automatically calculate dev hours & pricing:',
              style: TextStyle(fontSize: 12, color: AppTheme.slate600),
            ),
            const SizedBox(height: 10),
            ...FeatureAddon.allAddons.map((addon) {
              final isChecked = _selectedAddons.contains(addon.id);
              final priceInCurr = PricingEngine.formatAmount(
                addon.priceINR * widget.settings.currency.multiplier,
                widget.settings.currency,
              );

              return CheckboxListTile(
                value: isChecked,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                dense: true,
                activeColor: AppTheme.primarySky,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        addon.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '+$priceInCurr',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentEmeraldDark,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${addon.description} (~${addon.devHours} hrs)',
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.slate500),
                ),
                onChanged: (bool? val) {
                  setState(() {
                    if (val == true) {
                      _selectedAddons.add(addon.id);
                    } else {
                      _selectedAddons.remove(addon.id);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyAndUrgencyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune_rounded, color: AppTheme.primarySky, size: 20),
                SizedBox(width: 8),
                Text(
                  'Commercial Strategy & Urgency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Sensitivity
            const Text(
              'Client Budget Sensitivity (Win-Rate Guard)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate800),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<ClientBudgetSensitivity>(
              value: _selectedSensitivity,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: ClientBudgetSensitivity.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(
                    '${s.title} (${s.multiplier}x)',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSensitivity = val);
              },
            ),

            const SizedBox(height: 14),

            // Urgency
            const Text(
              'Delivery Timeline & Urgency',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate800),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<DeliveryUrgency>(
              value: _selectedUrgency,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: DeliveryUrgency.values.map((u) {
                return DropdownMenuItem(
                  value: u,
                  child: Text(
                    u.title,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedUrgency = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
