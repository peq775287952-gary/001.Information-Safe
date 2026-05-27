import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../widgets/item_list_tile.dart';
import 'item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<VaultItem> _results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _results = context.read<VaultService>().searchDetailed(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByType(_results);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: '搜索平台名、用户名、卡号、证件号...',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _search('');
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _searchController.text.isEmpty
            ? Center(child: Text('输入关键词开始搜索', style: Theme.of(context).textTheme.bodyLarge))
            : _results.isEmpty
                ? const Center(child: Text('没有找到结果'))
                : ListView(
                    children: [
                      for (final entry in grouped.entries)
                        if (entry.value.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              '${entry.key.icon} ${entry.key.label} (${entry.value.length})',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          for (final item in entry.value)
                            ItemListTile(
                              item: item,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id)),
                                );
                              },
                            ),
                        ],
                    ],
                  ),
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
