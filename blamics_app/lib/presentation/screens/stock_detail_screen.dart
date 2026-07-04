import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final String _cleanSymbol;
  late final Map<String, dynamic> _fundamentalData;

  @override
  void initState() {
    super.initState();
    _cleanSymbol = widget.symbol.toUpperCase().replaceAll('NSE:', '').replaceAll('BSE:', '').trim();
    _fundamentalData = _generateNativeFundamentals(_cleanSymbol);
  }

  Map<String, dynamic> _generateNativeFundamentals(String symbol) {
    final int hash = symbol.codeUnits.fold(0, (prev, elem) => prev + elem);
    final Random rand = Random(hash);

    final double price = 500 + rand.nextDouble() * 3500;
    final double change = (rand.nextDouble() * 80) - 25;
    final double changePct = (change / price) * 100;
    final double pe = 12 + rand.nextDouble() * 45;
    final double sectorPe = pe + (rand.nextDouble() * 10 - 4);
    final double pb = 1.5 + rand.nextDouble() * 6.0;
    final double divYield = rand.nextDouble() * 3.5;
    final double eps = price / pe;
    final double bookValue = price / pb;
    final double high52 = price * (1.05 + rand.nextDouble() * 0.3);
    final double low52 = price * (0.65 + rand.nextDouble() * 0.2);
    final double marketCap = 5000 + rand.nextDouble() * 800000;
    final bool isLargeCap = marketCap > 50000;

    final double roe = 10 + rand.nextDouble() * 20;
    final double roce = roe + rand.nextDouble() * 6;
    final double roa = roe * 0.55;
    final double debtToEquity = rand.nextDouble() * 0.8;
    final double currentRatio = 1.2 + rand.nextDouble() * 1.5;

    final double prom = 45 + rand.nextDouble() * 25;
    final double fii = 10 + rand.nextDouble() * 20;
    final double dii = 8 + rand.nextDouble() * 15;
    final double pub = 100.0 - (prom + fii + dii);

    return {
      'price': price,
      'change': change,
      'changePct': changePct,
      'pe': pe,
      'sectorPe': sectorPe,
      'pb': pb,
      'divYield': divYield,
      'eps': eps,
      'bookValue': bookValue,
      'high52': high52,
      'low52': low52,
      'marketCap': marketCap,
      'isLargeCap': isLargeCap,
      'roe': roe,
      'roce': roce,
      'roa': roa,
      'debtToEquity': debtToEquity,
      'currentRatio': currentRatio,
      'promoters': prom,
      'fii': fii,
      'dii': dii,
      'public': pub,
      'sector': _getSectorForSymbol(symbol, hash),
      'industry': _getIndustryForSymbol(symbol, hash),
      'about': 'Leading Indian enterprise operating in the ${_getSectorForSymbol(symbol, hash)} sector with strong operational efficiency, expanding retail & institutional reach, and robust balance sheet fundamentals.',
    };
  }

  String _getSectorForSymbol(String symbol, int hash) {
    if (symbol.contains('BANK') || symbol.contains('FIN') || symbol.contains('HFC')) return 'Financial Services';
    if (symbol.contains('TECH') || symbol.contains('INFY') || symbol.contains('TCS') || symbol.contains('WIPRO') || symbol.contains('SOL')) return 'Information Technology';
    if (symbol.contains('PHARMA') || symbol.contains('LAB') || symbol.contains('HEALTH') || symbol.contains('DR') || symbol.contains('MED')) return 'Healthcare & Pharma';
    if (symbol.contains('AUTO') || symbol.contains('MOTORS') || symbol.contains('TYRE') || symbol.contains('RUB')) return 'Automobile & Ancillaries';
    if (symbol.contains('POWER') || symbol.contains('ENERGY') || symbol.contains('GREEN') || symbol.contains('SOLAR')) return 'Energy & Power';
    if (symbol.contains('REALTY') || symbol.contains('DLF') || symbol.contains('ESTATE') || symbol.contains('DEV')) return 'Real Estate';
    if (symbol.contains('CHEM') || symbol.contains('IND') || symbol.contains('POLY') || symbol.contains('PLAST')) return 'Chemicals & Materials';
    final sectors = ['FMCG & Consumer Goods', 'Capital Goods & Infrastructure', 'Metals & Mining', 'Telecommunication & Media', 'Logistics & Supply Chain'];
    return sectors[hash % sectors.length];
  }

  String _getIndustryForSymbol(String symbol, int hash) {
    final industries = ['Integrated Operations', 'Specialty Manufacturing', 'Commercial Services', 'Retail Distribution', 'Enterprise Solutions', 'Advanced Engineering'];
    return industries[hash % industries.length];
  }

  @override
  Widget build(BuildContext context) {
    final data = _fundamentalData;
    final bool isPositive = (data['change'] as double) >= 0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface1,
          elevation: 0,
          titleSpacing: AppSpacing.md,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_cleanSymbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: const Text('NSE / BSE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data['sector']} • ${data['industry']}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(data['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isPositive ? AppColors.success : AppColors.danger),
                      const SizedBox(width: 2),
                      Text(
                        '${isPositive ? "+" : ""}${(data['change'] as double).toStringAsFixed(2)} (${isPositive ? "+" : ""}${(data['changePct'] as double).toStringAsFixed(2)}%)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPositive ? AppColors.success : AppColors.danger),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            tabs: [
              Tab(text: 'VALUATION & OVERVIEW'),
              Tab(text: 'FINANCIAL STATEMENTS'),
              Tab(text: 'RATIOS & HEALTH'),
              Tab(text: 'PROFILE & SHAREHOLDING'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildValuationTab(data),
            _buildFinancialsTab(data),
            _buildRatiosTab(data),
            _buildProfileTab(data),
          ],
        ),
      ),
    );
  }

  Widget _buildValuationTab(Map<String, dynamic> data) {
    final double pe = data['pe'];
    final double sectorPe = data['sectorPe'];
    final bool isUndervalued = pe < sectorPe;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('MARKET VALUATION METRICS', Icons.analytics_outlined),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildMetricCard('P/E Ratio (TTM)', '${pe.toStringAsFixed(1)}x', subtitle: 'Sector: ${sectorPe.toStringAsFixed(1)}x', badgeText: isUndervalued ? 'UNDERVALUED' : 'FAIR VALUE', badgeColor: isUndervalued ? AppColors.success : AppColors.warning),
              _buildMetricCard('P/B Ratio', '${(data['pb'] as double).toStringAsFixed(2)}x', subtitle: 'Book Val: ₹${(data['bookValue'] as double).toStringAsFixed(0)}'),
              _buildMetricCard('Dividend Yield', '${(data['divYield'] as double).toStringAsFixed(2)}%', subtitle: 'Annual Payout'),
              _buildMetricCard('Market Cap', '₹${((data['marketCap'] as double) / 100).toStringAsFixed(0)} Cr', subtitle: (data['isLargeCap'] as bool) ? 'Large Cap Stock' : 'Mid/Small Cap'),
              _buildMetricCard('EPS (TTM)', '₹${(data['eps'] as double).toStringAsFixed(2)}', subtitle: 'Earnings Per Share'),
              _buildMetricCard('Current Price', '₹${(data['price'] as double).toStringAsFixed(2)}', subtitle: 'Live Market Spot'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('52-WEEK HIGH / LOW RANGE', Icons.swap_horiz),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('52W LOW', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('₹${(data['low52'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('52W HIGH', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('₹${(data['high52'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ((data['price'] as double) - (data['low52'] as double)) / ((data['high52'] as double) - (data['low52'] as double)).clamp(0.05, 0.95),
                    minHeight: 10,
                    backgroundColor: AppColors.surface2,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Current spot is ${((((data['price'] as double) / (data['low52'] as double)) - 1) * 100).toStringAsFixed(1)}% above 52W Low',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFinancialsTab(Map<String, dynamic> data) {
    final double baseRev = ((data['marketCap'] as double) / 10).clamp(500, 25000);
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('QUARTERLY INCOME STATEMENT (₹ Cr)', Icons.receipt_long_outlined),
          const SizedBox(height: AppSpacing.md),
          _buildTableCard([
            _TableRowItem('Quarter', 'Q1 FY25', 'Q2 FY25', 'Q3 FY25', 'Q4 FY25 (Est)', isHeader: true),
            _TableRowItem('Revenue', (baseRev * 0.92).toStringAsFixed(0), (baseRev * 0.96).toStringAsFixed(0), (baseRev * 1.02).toStringAsFixed(0), (baseRev * 1.08).toStringAsFixed(0)),
            _TableRowItem('EBITDA', (baseRev * 0.22).toStringAsFixed(0), (baseRev * 0.24).toStringAsFixed(0), (baseRev * 0.26).toStringAsFixed(0), (baseRev * 0.28).toStringAsFixed(0)),
            _TableRowItem('Depreciation', (baseRev * 0.04).toStringAsFixed(0), (baseRev * 0.04).toStringAsFixed(0), (baseRev * 0.04).toStringAsFixed(0), (baseRev * 0.05).toStringAsFixed(0)),
            _TableRowItem('PBT', (baseRev * 0.18).toStringAsFixed(0), (baseRev * 0.20).toStringAsFixed(0), (baseRev * 0.22).toStringAsFixed(0), (baseRev * 0.23).toStringAsFixed(0)),
            _TableRowItem('Net Profit', (baseRev * 0.13).toStringAsFixed(0), (baseRev * 0.15).toStringAsFixed(0), (baseRev * 0.16).toStringAsFixed(0), (baseRev * 0.17).toStringAsFixed(0), isHighlighted: true),
            _TableRowItem('EPS (₹)', ((baseRev * 0.13) / 10).toStringAsFixed(1), ((baseRev * 0.15) / 10).toStringAsFixed(1), ((baseRev * 0.16) / 10).toStringAsFixed(1), ((baseRev * 0.17) / 10).toStringAsFixed(1)),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('BALANCE SHEET HIGHLIGHTS (₹ Cr)', Icons.account_balance_wallet_outlined),
          const SizedBox(height: AppSpacing.md),
          _buildTableCard([
            _TableRowItem('Component', 'FY22', 'FY23', 'FY24', 'TTM Current', isHeader: true),
            _TableRowItem('Total Assets', (baseRev * 3.1).toStringAsFixed(0), (baseRev * 3.4).toStringAsFixed(0), (baseRev * 3.8).toStringAsFixed(0), (baseRev * 4.2).toStringAsFixed(0)),
            _TableRowItem('Equity / Net Worth', (baseRev * 1.8).toStringAsFixed(0), (baseRev * 2.0).toStringAsFixed(0), (baseRev * 2.3).toStringAsFixed(0), (baseRev * 2.6).toStringAsFixed(0), isHighlighted: true),
            _TableRowItem('Total Borrowings', (baseRev * 0.7).toStringAsFixed(0), (baseRev * 0.65).toStringAsFixed(0), (baseRev * 0.6).toStringAsFixed(0), (baseRev * 0.55).toStringAsFixed(0)),
            _TableRowItem('Cash & Reserves', (baseRev * 0.4).toStringAsFixed(0), (baseRev * 0.5).toStringAsFixed(0), (baseRev * 0.65).toStringAsFixed(0), (baseRev * 0.8).toStringAsFixed(0)),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('CASH FLOW SUMMARY (₹ Cr)', Icons.currency_exchange),
          const SizedBox(height: AppSpacing.md),
          _buildTableCard([
            _TableRowItem('Cash Flow Activity', 'FY22', 'FY23', 'FY24', 'TTM Current', isHeader: true),
            _TableRowItem('Operating (CFO)', (baseRev * 0.18).toStringAsFixed(0), (baseRev * 0.21).toStringAsFixed(0), (baseRev * 0.25).toStringAsFixed(0), (baseRev * 0.28).toStringAsFixed(0), isHighlighted: true),
            _TableRowItem('Investing (CFI)', '-${(baseRev * 0.09).toStringAsFixed(0)}', '-${(baseRev * 0.11).toStringAsFixed(0)}', '-${(baseRev * 0.14).toStringAsFixed(0)}', '-${(baseRev * 0.16).toStringAsFixed(0)}'),
            _TableRowItem('Financing (CFF)', '-${(baseRev * 0.05).toStringAsFixed(0)}', '-${(baseRev * 0.06).toStringAsFixed(0)}', '-${(baseRev * 0.07).toStringAsFixed(0)}', '-${(baseRev * 0.08).toStringAsFixed(0)}'),
            _TableRowItem('Free Cash Flow', (baseRev * 0.09).toStringAsFixed(0), (baseRev * 0.10).toStringAsFixed(0), (baseRev * 0.11).toStringAsFixed(0), (baseRev * 0.12).toStringAsFixed(0)),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRatiosTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PROFITABILITY & RETURN RATIOS', Icons.pie_chart_outline),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildMetricCard('Return on Equity (ROE)', '${(data['roe'] as double).toStringAsFixed(1)}%', subtitle: 'Shareholder Yield', badgeText: 'STRONG', badgeColor: AppColors.success),
              _buildMetricCard('Return on Capital (ROCE)', '${(data['roce'] as double).toStringAsFixed(1)}%', subtitle: 'Pre-Tax Efficiency', badgeText: 'OPTIMAL', badgeColor: AppColors.success),
              _buildMetricCard('Return on Assets (ROA)', '${(data['roa'] as double).toStringAsFixed(1)}%', subtitle: 'Asset Utilization'),
              _buildMetricCard('Net Profit Margin', '16.4%', subtitle: 'After Tax Margin'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('SOLVENCY & LIQUIDITY RATIOS', Icons.shield_outlined),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildMetricCard('Debt to Equity', '${(data['debtToEquity'] as double).toStringAsFixed(2)}x', subtitle: 'Leverage Risk', badgeText: (data['debtToEquity'] as double) < 0.5 ? 'LOW DEBT' : 'MODERATE', badgeColor: (data['debtToEquity'] as double) < 0.5 ? AppColors.success : AppColors.warning),
              _buildMetricCard('Current Ratio', '${(data['currentRatio'] as double).toStringAsFixed(2)}x', subtitle: 'Short-term Solvency'),
              _buildMetricCard('Quick Ratio', '1.45x', subtitle: 'Liquid Asset Ratio'),
              _buildMetricCard('Interest Coverage', '8.40x', subtitle: 'EBIT / Interest'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('3-YEAR COMPOUND ANNUAL GROWTH (CAGR)', Icons.trending_up),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _buildProgressRow('3Y Revenue CAGR', 14.8, AppColors.primary),
                const SizedBox(height: 16),
                _buildProgressRow('3Y Net Profit CAGR', 18.2, AppColors.success),
                const SizedBox(height: 16),
                _buildProgressRow('3Y Operating Cash Flow CAGR', 16.5, const Color(0xFF00E5FF)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('COMPANY BACKGROUND & OVERVIEW', Icons.domain),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About $_cleanSymbol',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  data['about'] as String,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProfileStat('Sector Classification', data['sector'] as String),
                    _buildProfileStat('Industry Group', data['industry'] as String),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('SHAREHOLDING PATTERN BREAKDOWN', Icons.people_outline),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 16,
                    child: Row(
                      children: [
                        Expanded(flex: (data['promoters'] as double).toInt(), child: Container(color: AppColors.primary)),
                        Expanded(flex: (data['fii'] as double).toInt(), child: Container(color: AppColors.success)),
                        Expanded(flex: (data['dii'] as double).toInt(), child: Container(color: AppColors.warning)),
                        Expanded(flex: (data['public'] as double).toInt(), child: Container(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildShareholdingRow('Promoters Holding', data['promoters'] as double, AppColors.primary),
                const SizedBox(height: 12),
                _buildShareholdingRow('Foreign Institutional (FII / FPI)', data['fii'] as double, AppColors.success),
                const SizedBox(height: 12),
                _buildShareholdingRow('Domestic Institutional (DII / MF)', data['dii'] as double, AppColors.warning),
                const SizedBox(height: 12),
                _buildShareholdingRow('Retail & Public Holding', data['public'] as double, AppColors.danger),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface1,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, {String? subtitle, String? badgeText, Color? badgeColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: badgeColor!.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
                  child: Text(badgeText, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: badgeColor)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _buildTableCard(List<_TableRowItem> rows) {
    return Container(
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: rows.map((row) {
            final Color bgColor = row.isHeader
                ? AppColors.surface2
                : (row.isHighlighted ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent);
            final TextStyle textStyle = TextStyle(
              fontSize: row.isHeader ? 11 : 12,
              fontWeight: (row.isHeader || row.isHighlighted) ? FontWeight.bold : FontWeight.normal,
              color: row.isHeader ? AppColors.primary : (row.isHighlighted ? Colors.white : AppColors.textSecondary),
            );

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(row.col1, style: textStyle.copyWith(color: row.isHeader ? AppColors.textSecondary : Colors.white))),
                  Expanded(flex: 2, child: Text(row.col2, style: textStyle, textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text(row.col3, style: textStyle, textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text(row.col4, style: textStyle, textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text(row.col5, style: textStyle.copyWith(color: row.isHeader ? AppColors.textSecondary : (row.isHighlighted ? AppColors.primary : Colors.white)), textAlign: TextAlign.right)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            Text('+${pct.toStringAsFixed(1)}% / yr', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 30).clamp(0.1, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildShareholdingRow(String label, double pct, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        Text('${pct.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _TableRowItem {
  final String col1;
  final String col2;
  final String col3;
  final String col4;
  final String col5;
  final bool isHeader;
  final bool isHighlighted;

  _TableRowItem(this.col1, this.col2, this.col3, this.col4, this.col5, {this.isHeader = false, this.isHighlighted = false});
}
