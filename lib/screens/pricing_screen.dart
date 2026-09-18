import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String get apiUrl => ApiConfig.baseUrl;
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final productNameController = TextEditingController();
  final categoryController = TextEditingController(text: 'Handicraft');
  final costController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String selectedQuality = 'standard';
  String selectedDemand = 'normal';

  bool calculating = false;

  double? suggestedPrice;
  double? minimumPrice;
  double? premiumPrice;

  String? aiExplanation;
  String? errorMessage;

  // ============================================================
  // FASTAPI
  // ============================================================

  // ============================================================
  // CALCULATE PRICE
  // ============================================================

  Future<void> calculatePrice() async {
    FocusScope.of(context).unfocus();

    final name = productNameController.text.trim();
    final category = categoryController.text.trim();
    final costText = costController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter a product name.');
      return;
    }

    if (costText.isEmpty) {
      showMessage('Please enter the production cost.');
      return;
    }

    final cost = double.tryParse(costText);

    if (cost == null || cost <= 0) {
      showMessage('Please enter a valid production cost.');
      return;
    }

    setState(() {
      calculating = true;
      errorMessage = null;

      suggestedPrice = null;
      minimumPrice = null;
      premiumPrice = null;
      aiExplanation = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl/ai/recommend-price'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'category': category.isEmpty ? 'Handicraft' : category,
              'cost': cost,
              'quality': selectedQuality,
              'demand': selectedDemand,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('PRICING STATUS: ${response.statusCode}');

      debugPrint('PRICING RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Pricing server returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(
          data['error']?.toString() ?? 'Could not calculate price.',
        );
      }

      if (!mounted) return;

      final suggested = double.tryParse(data['suggested_price'].toString());

      final minimum = double.tryParse(data['minimum_price'].toString());

      final premium = double.tryParse(data['premium_price'].toString());

      setState(() {
        suggestedPrice = suggested;
        minimumPrice = minimum;
        premiumPrice = premium;

        aiExplanation =
            data['explanation']?.toString() ??
            _buildLocalExplanation(
              cost: cost,
              quality: selectedQuality,
              demand: selectedDemand,
            );
      });

      showMessage('AI price recommendation generated ✨');
    } catch (e) {
      debugPrint('PRICING ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not connect to AI pricing server.\n\n$e';
      });

      showMessage('Could not connect to pricing server.');
    } finally {
      if (mounted) {
        setState(() {
          calculating = false;
        });
      }
    }
  }

  // ============================================================
  // FALLBACK EXPLANATION
  // ============================================================

  String _buildLocalExplanation({
    required double cost,
    required String quality,
    required String demand,
  }) {
    String qualityText;

    switch (quality) {
      case 'basic':
        qualityText = 'basic quality';
        break;

      case 'high':
        qualityText = 'high quality';
        break;

      case 'premium':
        qualityText = 'premium quality';
        break;

      default:
        qualityText = 'standard quality';
    }

    String demandText;

    switch (demand) {
      case 'low':
        demandText = 'low market demand';
        break;

      case 'high':
        demandText = 'high market demand';
        break;

      default:
        demandText = 'normal market demand';
    }

    return 'The recommendation considers your production cost, '
        '$qualityText and $demandText to create a practical '
        'selling-price range.';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetPricing() {
    setState(() {
      productNameController.clear();

      categoryController.text = 'Handicraft';

      costController.clear();

      selectedQuality = 'standard';

      selectedDemand = 'normal';

      suggestedPrice = null;
      minimumPrice = null;
      premiumPrice = null;

      aiExplanation = null;
      errorMessage = null;
    });
  }

  // ============================================================
  // QUALITY CHIP
  // ============================================================

  Widget qualityChip({required String value, required String label}) {
    final selected = selectedQuality == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: calculating
          ? null
          : (_) {
              setState(() {
                selectedQuality = value;
              });
            },
    );
  }

  // ============================================================
  // DEMAND CHIP
  // ============================================================

  Widget demandChip({required String value, required String label}) {
    final selected = selectedDemand == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: calculating
          ? null
          : (_) {
              setState(() {
                selectedDemand = value;
              });
            },
    );
  }

  // ============================================================
  // PRICE CARD
  // ============================================================

  Widget priceCard({
    required String title,
    required String subtitle,
    required double? price,
    required IconData icon,
    bool highlighted = false,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: highlighted
            ? primary.withValues(alpha: 0.07)
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: highlighted
              ? primary.withValues(alpha: 0.45)
              : Colors.grey.withValues(alpha: 0.22),
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 0,
                  color: primary.withValues(alpha: 0.08),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: primary),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            price == null ? '—' : '₹${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: highlighted ? primary : null,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFIT CARD
  // ============================================================

  Widget buildProfitCard() {
    if (suggestedPrice == null) {
      return const SizedBox.shrink();
    }

    final cost = double.tryParse(costController.text.trim()) ?? 0;

    final profit = suggestedPrice! - cost;

    final margin = suggestedPrice! > 0 ? (profit / suggestedPrice!) * 100 : 0;

    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.10),
            primary.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: primary),

              const SizedBox(width: 10),

              const Text(
                'Estimated Profit',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _statItem(
                  title: 'Production Cost',
                  value: '₹${cost.toStringAsFixed(0)}',
                ),
              ),

              Expanded(
                child: _statItem(
                  title: 'Estimated Profit',
                  value: '₹${profit.toStringAsFixed(0)}',
                ),
              ),

              Expanded(
                child: _statItem(
                  title: 'Margin',
                  value: '${margin.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _statItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ============================================================
  // AI EXPLANATION
  // ============================================================

  Widget buildExplanationCard() {
    if (aiExplanation == null) {
      return const SizedBox.shrink();
    }

    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary.withValues(alpha: 0.10),
            ),
            child: Icon(Icons.auto_awesome, color: primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why this price?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),

                const SizedBox(height: 6),

                Text(
                  aiExplanation!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget buildHeader() {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.13),
            primary.withValues(alpha: 0.035),
          ],
        ),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: primary.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.auto_awesome, size: 31, color: primary),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Pricing Assistant',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 6),

                Text(
                  'Calculate a smart selling price using production cost, quality and market demand.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Pricing Assistant'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: calculating ? null : resetPricing,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                buildHeader(),

                const SizedBox(height: 28),

                // ==================================================
                // PRODUCT INFORMATION
                // ==================================================
                const Text(
                  'Product Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: productNameController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !calculating,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Example: Sambalpuri Kurta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: categoryController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !calculating,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Handicraft',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: costController,
                  enabled: !calculating,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Production Cost',
                    hintText: 'Example: 800',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // QUALITY
                // ==================================================
                const Text(
                  'Product Quality',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    qualityChip(value: 'basic', label: 'Basic'),
                    qualityChip(value: 'standard', label: 'Standard'),
                    qualityChip(value: 'high', label: 'High'),
                    qualityChip(value: 'premium', label: 'Premium'),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // DEMAND
                // ==================================================
                const Text(
                  'Market Demand',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    demandChip(value: 'low', label: 'Low'),
                    demandChip(value: 'normal', label: 'Normal'),
                    demandChip(value: 'high', label: 'High'),
                  ],
                ),

                const SizedBox(height: 30),

                // ==================================================
                // CALCULATE BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: calculating ? null : calculatePrice,
                    icon: calculating
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      calculating
                          ? 'Calculating...'
                          : 'Get AI Price Recommendation',
                    ),
                  ),
                ),

                // ==================================================
                // ERROR
                // ==================================================
                if (errorMessage != null) ...[
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red.withValues(alpha: 0.04),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ==================================================
                // RESULTS
                // ==================================================
                if (suggestedPrice != null) ...[
                  const SizedBox(height: 38),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'AI Recommendation',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.08),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'AI Generated',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  priceCard(
                    title: 'Recommended Selling Price',
                    subtitle: 'Best balance between value and affordability',
                    price: suggestedPrice,
                    icon: Icons.auto_awesome,
                    highlighted: true,
                  ),

                  const SizedBox(height: 12),

                  priceCard(
                    title: 'Minimum Suggested Price',
                    subtitle: 'Safer lower selling point',
                    price: minimumPrice,
                    icon: Icons.arrow_downward,
                  ),

                  const SizedBox(height: 12),

                  priceCard(
                    title: 'Premium Price',
                    subtitle: 'Higher-value positioning and margins',
                    price: premiumPrice,
                    icon: Icons.trending_up,
                  ),

                  const SizedBox(height: 15),

                  buildProfitCard(),

                  const SizedBox(height: 15),

                  buildExplanationCard(),

                  const SizedBox(height: 18),

                  // ==================================================
                  // TIP
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Premium quality and high market demand can justify a higher selling price. Always consider your craftsmanship, materials and customer segment.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    productNameController.dispose();
    categoryController.dispose();
    costController.dispose();

    super.dispose();
  }
}
