import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote_model.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';
import '../services/pricing_engine.dart';
import '../services/pdf_service.dart';
import '../services/sharing_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final AgencySettings settings;

  const HistoryScreen({
    super.key,
    required this.settings,
  });

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<QuoteRecord> _quotes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadQuotes();
  }

  Future<void> loadQuotes() async {
    setState(() => _isLoading = true);
    final list = await StorageService.loadQuotes();
    if (mounted) {
      setState(() {
        _quotes = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuote(QuoteRecord quote) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quote'),
        content: Text('Are you sure you want to delete proposal ${quote.refCode} for ${quote.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteQuote(quote.id);
      await loadQuotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showQuoteDetailsModal(QuoteRecord quote) {
    final currency = quote.calculation.currency;
    final targetPriceStr = PricingEngine.formatAmount(quote.calculation.targetPrice, currency);
    final starterPriceStr = PricingEngine.formatAmount(quote.calculation.starterPrice, currency);
    final enterprisePriceStr = PricingEngine.formatAmount(quote.calculation.enterprisePrice, currency);
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(quote.createdAt);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quote.refCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primarySky,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quote.clientName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (quote.clientPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('📞 ${quote.clientPhone}', style: const TextStyle(color: AppTheme.slate600)),
                ],
                const SizedBox(height: 16),

                // Investment Highlights
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Target Recommended Price',
                        style: TextStyle(fontSize: 12, color: AppTheme.slate600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        targetPriceStr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _detailStat('Starter Floor', starterPriceStr),
                          _detailStat('Enterprise Upsell', enterprisePriceStr),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                _specRow('Project Scope', '${quote.category.displayName} (${quote.pageCount} Pages)'),
                _specRow('Delivery Timeline', '${quote.calculation.deliveryDays} Working Days (${quote.urgency.title})'),
                _specRow('Effort Scope', '~${quote.calculation.totalDevHours} Dev Hours'),
                _specRow('Client Strategy', quote.sensitivity.title),

                const SizedBox(height: 16),
                const Text(
                  'Included Deliverables & Add-ons',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...quote.selectedAddonIds.map((addonId) {
                  final addon = FeatureAddon.allAddons.firstWhere(
                    (a) => a.id == addonId,
                    orElse: () => FeatureAddon(
                      id: addonId,
                      name: addonId,
                      description: '',
                      priceINR: 0,
                      devHours: 0,
                    ),
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.accentEmerald, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(addon.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),
                // Actions inside modal
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          SharingService.sendWhatsAppQuote(quote: quote, settings: widget.settings);
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          PdfService.printOrPreviewProposal(quote: quote, settings: widget.settings);
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: const Text('View PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primarySky,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    PdfService.shareProposalPdf(quote: quote, settings: widget.settings);
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share PDF File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.slate500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slate800)),
      ],
    );
  }

  Widget _specRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.slate600)),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuotes = _quotes.where((q) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return q.clientName.toLowerCase().contains(query) ||
          q.refCode.toLowerCase().contains(query) ||
          q.category.displayName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Quotes History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadQuotes,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by client, ref code, or category...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),

                // Content
                Expanded(
                  child: filteredQuotes.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: loadQuotes,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredQuotes.length,
                            itemBuilder: (context, index) {
                              final quote = filteredQuotes[index];
                              return _buildQuoteCard(quote);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_open_outlined, size: 48, color: AppTheme.primarySky),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Saved Quotes Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No quotes match "$_searchQuery". Try a different search term.'
                  : 'Generate and save commercial quotes from the Quote Generator tab.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.slate500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(QuoteRecord quote) {
    final currency = quote.calculation.currency;
    final formattedAmount = PricingEngine.formatAmount(quote.calculation.targetPrice, currency);
    final dateStr = DateFormat('dd MMM yyyy').format(quote.createdAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showQuoteDetailsModal(quote),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      quote.refCode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote.clientName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${quote.category.displayName} • ${quote.pageCount} Pages',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formattedAmount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentEmeraldDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.borderSubtle, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppTheme.slate500),
                      const SizedBox(width: 4),
                      Text(
                        '${quote.calculation.deliveryDays}d delivery',
                        style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.layers_outlined, size: 14, color: AppTheme.slate500),
                      const SizedBox(width: 4),
                      Text(
                        '${quote.selectedAddonIds.length} add-ons',
                        style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: Color(0xFF25D366)),
                        tooltip: 'Send WhatsApp',
                        onPressed: () => SharingService.sendWhatsAppQuote(
                          quote: quote,
                          settings: widget.settings,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 20, color: AppTheme.primarySky),
                        tooltip: 'View PDF Proposal',
                        onPressed: () => PdfService.printOrPreviewProposal(
                          quote: quote,
                          settings: widget.settings,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () => _deleteQuote(quote),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
