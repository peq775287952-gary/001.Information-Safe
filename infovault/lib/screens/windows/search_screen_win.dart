import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../services/vault_service.dart';
import '../../models/vault_item.dart';
import '../../models/item_type.dart';
import '../../widgets/type_icon.dart';
import 'item_detail_screen_win.dart';

class SearchScreenWin extends StatefulWidget {
  const SearchScreenWin({super.key});
  @override
  State<SearchScreenWin> createState() => _SearchScreenWinState();
}

class _SearchScreenWinState extends State<SearchScreenWin> {
  final _searchController = fluent.TextEditingController();
  List<VaultItem> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _results = context.read<VaultService>().searchDetailed(query);
      _hasSearched = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByType(_results);
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;

    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: const Text('搜索'),
      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: fluent.TextBox(
              controller: _searchController,
              placeholder: '搜索平台名、用户名、卡号、证件号...',
              onChanged: _search,
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(fluent.FluentIcons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    )
                  : null,
            ),
          ),
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Text('输入关键词开始搜索',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey[500])))
                : _results.isEmpty
                    ? const Center(child: Text('没有找到结果'))
                    : ListView(
                        children: [
                          for (final entry in grouped.entries)
                            if (entry.value.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Text(
                                  '${entry.key.icon} ${entry.key.label} (${entry.value.length})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              for (final item in entry.value)
                                _SearchResultItem(
                                  item: item,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ItemDetailScreenWin(
                                            itemId: item.id),
                                      ),
                                    );
                                  },
                                ),
                            ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Map<ItemType, List<VaultItem>> _groupByType(List<VaultItem> items) {
    final map = <ItemType, List<VaultItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.type, () => []).add(item);
    }
    return map;
  }
}

class _SearchResultItem extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onTap;

  const _SearchResultItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: fluent.Card(
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                TypeIcon(type: item.type, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          )),
                      if (item.username != null &&
                          item.username!.isNotEmpty)
                        Text(item.username!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            )),
                    ],
                  ),
                ),
                const Icon(fluent.FluentIcons.chevron_right, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
