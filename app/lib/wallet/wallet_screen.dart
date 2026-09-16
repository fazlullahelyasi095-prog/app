import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../core/app_theme.dart';

/// Monetary amounts are displayed as returned by the server; no conversion,
/// balance mutation or earnings calculation takes place in this client.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, this.liveId});
  final int? liveId;
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _api = ApiClient.instance.dio;
  Map<String, dynamic>? _summary;
  List<dynamic> _rows = [];
  String? _error;
  int _page = 1;
  bool _busy = false, _hasNext = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = widget.liveId;
      final summary = await _api.get(
        id == null ? '/wallet/me' : '/creator-earnings/$id/earnings',
      );
      final history = await _api.get(
        id == null ? '/transactions/me' : '/creator-earnings/$id/history',
        queryParameters: id == null ? {'page': page, 'pageSize': 20} : null,
      );
      if (!mounted) return;
      setState(() {
        _summary = Map<String, dynamic>.from(summary.data);
        _rows = id == null
            ? history.data['data'] as List
            : history.data as List;
        _page = page;
        _hasNext = id == null && history.data['pagination']['hasNext'] == true;
      });
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.light,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.liveId == null ? 'Balance' : 'Live earnings'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              ListTile(
                title: Text(_error!),
                trailing: IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            if (_summary case final summary?) ...[
              if (widget.liveId == null) ...[
                _BalanceCard(
                  label: 'Available cash (USD)',
                  value: '${summary['cash_balance']}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _BalanceCard(
                  label: 'Coins',
                  value: '${summary['coin_balance']}',
                  icon: Icons.monetization_on_outlined,
                ),
                ListTile(
                  title: const Text('Pending cash (USD)'),
                  trailing: Text('${summary['pending_cash_balance']}'),
                ),
              ] else ...[
                ListTile(
                  title: const Text('Gifts'),
                  trailing: Text('${summary['totalGifts']}'),
                ),
                ListTile(
                  title: const Text('Coins received'),
                  trailing: Text('${summary['totalCoins']}'),
                ),
                ListTile(
                  title: const Text('Estimated cash (USD)'),
                  trailing: Text('${summary['estimatedCash']}'),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Transaction history',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 28),
              if (_rows.isEmpty) const Text('No transactions yet'),
              for (final row in _rows)
                ListTile(
                  title: Text('${row['type'] ?? row['name'] ?? 'Gift'}'),
                  subtitle: Text(
                    '${row['created_at'] ?? ''}\n${row['status'] ?? row['sender'] ?? ''}',
                  ),
                  trailing: Text(
                    '${row['direction'] ?? ''} ${row['amount'] ?? row['coins']} ${row['currency'] ?? 'COIN'}',
                  ),
                ),
              if (widget.liveId == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: !_busy && _page > 1
                          ? () => _load(page: _page - 1)
                          : null,
                      child: const Text('Previous'),
                    ),
                    Text('Page $_page'),
                    TextButton(
                      onPressed: !_busy && _hasNext
                          ? () => _load(page: _page + 1)
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
    decoration: BoxDecoration(
      color: const Color(0xfff7f7f7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.black54, size: 26),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
