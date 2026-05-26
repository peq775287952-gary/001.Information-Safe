import 'dart:io';

Future<void> main() async {
  final assetsDir = Directory('assets/icons');
  if (!assetsDir.existsSync()) {
    assetsDir.createSync(recursive: true);
  }

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 15);

  int downloaded = 0;
  int generated = 0;

  // ── AI Providers: Lobe Icons CDN ──
  // Correct URL: refs/heads/master/packages/static-svg/light/{name}.svg
  final aiBrands = <String, _Brand>{
    'openai':    _Brand('OpenAI',    ['openai'],     0xFF00A67E),
    'chatgpt':   _Brand('ChatGPT',   ['openai'],     0xFF00A67E),
    'anthropic': _Brand('Anthropic', ['anthropic'],  0xFFD97757),
    'claude':    _Brand('Claude',    ['anthropic'],  0xFFD97757),
    'deepseek':  _Brand('DeepSeek',  ['deepseek'],   0xFF4D6BFE),
    'gemini':    _Brand('Gemini',    ['gemini','google'], 0xFF4285F4),
    'qwen':      _Brand('通义千问',  ['qwen'],        0xFFFF6A00),
    'zhipu':     _Brand('智谱',     ['zhipu'],       0xFF2563EB),
    'glm':       _Brand('GLM',      ['zhipu'],       0xFF2563EB),
    'minimax':   _Brand('MiniMax',  ['minimax'],     0xFF7C3AED),
    'kimi':      _Brand('Kimi',     ['moonshot'],    0xFF6C5CE7),
    'moonshot':  _Brand('月之暗面', ['moonshot'],    0xFF6C5CE7),
    'ernie':     _Brand('文心一言', ['ernie'],        0xFF2468E6),
    'hunyuan':   _Brand('混元',     ['hunyuan'],      0xFF00C3B1),
    'spark':     _Brand('讯飞星火', ['spark'],        0xFF2B65F5),
    'sensenova': _Brand('SenseNove',['sensenova','sensetime'], 0xFF1E40AF),
    'sensetime': _Brand('商汤',     ['sensenova','sensetime'], 0xFF1E40AF),
  };

  // URL patterns to try (in order)
  final aiSources = [
    (String name) => 'https://raw.githubusercontent.com/lobehub/lobe-icons/refs/heads/master/packages/static-svg/light/$name.svg',
    (String name) => 'https://unpkg.com/@lobehub/icons-static-svg@latest/icons/$name.svg',
    (String name) => 'https://registry.npmmirror.com/@lobehub/icons-static-svg/latest/files/icons/$name.svg',
  ];

  print('── Downloading AI icons ──');
  for (final entry in aiBrands.entries) {
    final tag = entry.key;
    final brand = entry.value;
    final file = File('${assetsDir.path}/$tag.svg');
    if (file.existsSync()) {
      print('  · $tag (already exists, skipping)');
      downloaded++;
      continue;
    }

    bool success = false;
    for (final svgName in brand.svgNames) {
      for (final src in aiSources) {
        if (await _tryDownload(client, src(svgName), file)) {
          print('  ✓ $tag ← $svgName.svg');
          downloaded++;
          success = true;
          break;
        }
      }
      if (success) break;
    }
    if (!success) {
      _generateBadge(file, brand.firstChar, brand.color);
      print('  ⚡ $tag (badge fallback)');
      generated++;
    }
  }

  // ── Banks ──
  final bankCodes = {
    'icbc': _Bank('工商银行', 'icbc', 0xFFCC0000),
    'abc':  _Bank('农业银行', 'abc',  0xFF009B72),
    'boc':  _Bank('中国银行', 'boc',  0xFFCE0000),
    'ccb':  _Bank('建设银行', 'ccb',  0xFF0066CC),
    'bocom':_Bank('交通银行', 'bocom',0xFF005BAB),
    'psbc': _Bank('邮储银行', 'psbc', 0xFF007A3D),
    'cmb':  _Bank('招商银行', 'cmb',  0xFFCE0000),
    'spd':  _Bank('浦发银行', 'spd',  0xFF003399),
  };

  final bankSources = [
    (String code) => 'https://raw.githubusercontent.com/orzFly/payment-webfont-cn/refs/heads/master/svg/$code.svg',
    (String code) => 'https://raw.githubusercontent.com/orzFly/payment-webfont-cn/master/svg/$code.svg',
    (String code) => 'https://cdn.jsdelivr.net/gh/orzFly/payment-webfont-cn@master/svg/$code.svg',
  ];

  print('\n── Downloading Bank icons ──');
  for (final entry in bankCodes.entries) {
    final code = entry.key;
    final bank = entry.value;
    final file = File('${assetsDir.path}/bank_$code.svg');
    if (file.existsSync()) {
      print('  · ${bank.name} (already exists, skipping)');
      downloaded++;
      continue;
    }
    bool success = false;
    for (final src in bankSources) {
      if (await _tryDownload(client, src(code), file)) {
        print('  ✓ ${bank.name} ($code)');
        downloaded++;
        success = true;
        break;
      }
    }
    if (!success) {
      _generateBadge(file, bank.firstChar, bank.color);
      print('  ⚡ ${bank.name} (badge fallback)');
      generated++;
    }
  }

  // ── ID document badges ──
  final idBrands = {
    'id_身份证': _Brand('身份证', const [], 0xFF2563EB),
    'id_护照':   _Brand('护照',   const [], 0xFF059669),
    'id_驾照':   _Brand('驾照',   const [], 0xFFD97706),
    'id_社保卡': _Brand('社保卡', const [], 0xFFDC2626),
    'id_户口本': _Brand('户口本', const [], 0xFF7C3AED),
  };

  print('\n── Generating ID document badges ──');
  for (final entry in idBrands.entries) {
    final file = File('${assetsDir.path}/${entry.key}.svg');
    if (file.existsSync()) {
      print('  · ${entry.value.name} (already exists, skipping)');
      continue;
    }
    _generateBadge(file, entry.value.firstChar, entry.value.color);
    print('  ⚡ ${entry.value.name}');
    generated++;
  }

  // ── Generate Dart mapping ──
  print('\n── Generating Dart mapping ──');
  final buf = StringBuffer();
  buf.writeln('// AUTO-GENERATED by scripts/download_brand_icons.dart');
  buf.writeln('// DO NOT EDIT MANUALLY');
  buf.writeln('import \'package:flutter/material.dart\';');
  buf.writeln();
  buf.writeln('class BrandIcons {');

  void writeAiGroup() {
    buf.writeln('  static const aiBrands = <String, IconInfo>{');
    for (final entry in aiBrands.entries) {
      final file = File('${assetsDir.path}/${entry.key}.svg');
      if (file.existsSync()) {
        buf.writeln("    '${entry.value.name}': IconInfo('assets/icons/${entry.key}.svg', Color(${_hexColor(entry.value.color)})),");
      }
    }
    buf.writeln('  };');
  }

  void writeBankGroup() {
    buf.writeln('  static const bankBrands = <String, IconInfo>{');
    for (final entry in bankCodes.entries) {
      final file = File('${assetsDir.path}/bank_${entry.key}.svg');
      if (file.existsSync()) {
        buf.writeln("    '${entry.value.name}': IconInfo('assets/icons/bank_${entry.key}.svg', Color(${_hexColor(entry.value.color)})),");
      }
    }
    buf.writeln('  };');
  }

  void writeIdGroup() {
    buf.writeln('  static const idBrands = <String, IconInfo>{');
    for (final entry in idBrands.entries) {
      final file = File('${assetsDir.path}/${entry.key}.svg');
      if (file.existsSync()) {
        buf.writeln("    '${entry.value.name}': IconInfo('assets/icons/${entry.key}.svg', Color(${_hexColor(entry.value.color)})),");
      }
    }
    buf.writeln('  };');
  }

  writeAiGroup();
  writeBankGroup();
  writeIdGroup();

  buf.writeln();
  buf.writeln('  static IconInfo? lookup(String? name) {');
  buf.writeln('    if (name == null || name.isEmpty) return null;');
  buf.writeln('    return aiBrands[name] ?? bankBrands[name] ?? idBrands[name];');
  buf.writeln('  }');
  buf.writeln('}');
  buf.writeln();
  buf.writeln('class IconInfo {');
  buf.writeln('  final String assetPath;');
  buf.writeln('  final Color color;');
  buf.writeln('  const IconInfo(this.assetPath, this.color);');
  buf.writeln('}');

  final mappingFile = File('lib/utils/brand_icons.dart');
  mappingFile.writeAsStringSync(buf.toString());
  print('  → lib/utils/brand_icons.dart');

  print('\nDone: $downloaded downloaded/cached, $generated generated.');
  client.close();
}

Future<bool> _tryDownload(HttpClient client, String url, File file) async {
  try {
    final uri = Uri.parse(url);
    final req = await client.getUrl(uri);
    final res = await req.close();
    if (res.statusCode == 200) {
      final bytes = await res.fold<List<int>>([], (prev, b) => prev..addAll(b));
      file.writeAsBytesSync(bytes);
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

void _generateBadge(File file, String char, int color) {
  final hex = _hexStr(color);
  final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">\n'
      '  <rect x="4" y="4" width="40" height="40" rx="10" fill="$hex"/>\n'
      '  <text x="24" y="24" text-anchor="middle" dy="0.35em"\n'
      '        font-family="sans-serif" font-size="22" font-weight="bold" fill="white">$char</text>\n'
      '</svg>';
  file.writeAsStringSync(svg);
}

String _hexStr(int color) =>
    '#${color.toRadixString(16).padLeft(8, '0').substring(2)}';

String _hexColor(int color) =>
    '0x${color.toRadixString(16).padLeft(8, '0').toUpperCase()}';

class _Brand {
  final String name;
  final List<String> svgNames;
  final int color;
  _Brand(this.name, this.svgNames, this.color);
  String get firstChar => name[0];
}

class _Bank {
  final String name;
  final String code;
  final int color;
  _Bank(this.name, this.code, this.color);
  String get firstChar => name[0];
}
