import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../theme/app_theme.dart';
import '../utils/brand_icons.dart';

class PlatformIcon extends StatelessWidget {
  final VaultItem item;
  final double size;

  const PlatformIcon({super.key, required this.item, this.size = 36});

  static const _brands = <String, _BrandInfo>{
    '微信': _BrandInfo(FontAwesomeIcons.weixin, Color(0xFF07C160)),
    'wechat': _BrandInfo(FontAwesomeIcons.weixin, Color(0xFF07C160)),
    'WeChat': _BrandInfo(FontAwesomeIcons.weixin, Color(0xFF07C160)),
    '支付宝': _BrandInfo(FontAwesomeIcons.alipay, Color(0xFF1677FF)),
    'alipay': _BrandInfo(FontAwesomeIcons.alipay, Color(0xFF1677FF)),
    'QQ': _BrandInfo(FontAwesomeIcons.qq, Color(0xFF12B7F5)),
    '微博': _BrandInfo(FontAwesomeIcons.weibo, Color(0xFFE6162D)),
    '抖音': _BrandInfo(FontAwesomeIcons.tiktok, Color(0xFF000000)),
    'GitHub': _BrandInfo(FontAwesomeIcons.github, Color(0xFF24292E)),
    'github': _BrandInfo(FontAwesomeIcons.github, Color(0xFF24292E)),
    'GitLab': _BrandInfo(FontAwesomeIcons.gitlab, Color(0xFFFC6D26)),
    'Google': _BrandInfo(FontAwesomeIcons.google, Color(0xFF4285F4)),
    'Gmail': _BrandInfo(Icons.mail_rounded, Color(0xFFEA4335)),
    'Outlook': _BrandInfo(FontAwesomeIcons.microsoft, Color(0xFF0078D4)),
    'Apple': _BrandInfo(FontAwesomeIcons.apple, Color(0xFF000000)),
    'Steam': _BrandInfo(FontAwesomeIcons.steam, Color(0xFF171A21)),
    'YouTube': _BrandInfo(FontAwesomeIcons.youtube, Color(0xFFFF0000)),
    'B站': _BrandInfo(Icons.smart_display_rounded, Color(0xFFFB7299)),
    'bilibili': _BrandInfo(Icons.smart_display_rounded, Color(0xFFFB7299)),
    '淘宝': _BrandInfo(Icons.shopping_bag_rounded, Color(0xFFFF5000)),
    '京东': _BrandInfo(Icons.storefront_rounded, Color(0xFFE2231A)),
    '拼多多': _BrandInfo(Icons.local_offer_rounded, Color(0xFFE02E24)),
    '小红书': _BrandInfo(Icons.auto_stories_rounded, Color(0xFFFF2442)),
    '百度': _BrandInfo(Icons.language_rounded, Color(0xFF4E6EF2)),
    '钉钉': _BrandInfo(Icons.work_rounded, Color(0xFF0089FF)),
    '飞书': _BrandInfo(Icons.forum_rounded, Color(0xFF3370FF)),
    'Notion': _BrandInfo(Icons.text_snippet_rounded, Color(0xFF000000)),
    'Slack': _BrandInfo(FontAwesomeIcons.slack, Color(0xFF4A154B)),
    'Discord': _BrandInfo(FontAwesomeIcons.discord, Color(0xFF5865F2)),
    'Telegram': _BrandInfo(FontAwesomeIcons.telegram, Color(0xFF26A5E4)),
    'WhatsApp': _BrandInfo(FontAwesomeIcons.whatsapp, Color(0xFF25D366)),
    'Spotify': _BrandInfo(FontAwesomeIcons.spotify, Color(0xFF1DB954)),
    'Netflix': _BrandInfo(Icons.movie_rounded, Color(0xFFE50914)),
    'Dropbox': _BrandInfo(FontAwesomeIcons.dropbox, Color(0xFF0061FF)),
    'OneDrive': _BrandInfo(FontAwesomeIcons.microsoft, Color(0xFF0078D4)),
    'Docker': _BrandInfo(FontAwesomeIcons.docker, Color(0xFF2496ED)),
    'Amazon': _BrandInfo(FontAwesomeIcons.amazon, Color(0xFFFF9900)),
    'PayPal': _BrandInfo(FontAwesomeIcons.paypal, Color(0xFF00457C)),
  };

  Color get _typeColor {
    switch (item.type) {
      case ItemType.password:   return AppTheme.passwordAccent;
      case ItemType.bankCard:   return AppTheme.bankAccent;
      case ItemType.idDocument: return AppTheme.idAccent;
      case ItemType.secureNote: return AppTheme.noteAccent;
      case ItemType.apiKey:    return const Color(0xFF7C3AED);
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case ItemType.password:   return Icons.lock_rounded;
      case ItemType.bankCard:   return Icons.credit_card_rounded;
      case ItemType.idDocument: return Icons.badge_rounded;
      case ItemType.secureNote: return Icons.note_alt_rounded;
      case ItemType.apiKey:    return Icons.smart_toy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Try SVG brand icon (banks, AI, ID docs)
    final svgInfo = BrandIcons.lookup(item.title) ??
        (item.type == ItemType.bankCard ? BrandIcons.lookup(item.bankName) : null);
    if (svgInfo != null) {
      return _svgContainer(svgInfo);
    }

    // 2. Try legacy FontAwesome brand icon (WeChat, Alipay, etc.)
    final brand = _brands[item.title] ??
        (item.type == ItemType.bankCard ? _brands[item.bankName] : null);
    if (brand != null) {
      return _iconContainer(brand.icon, brand.color);
    }

    // 3. CJK character fallback
    final firstChar = item.title.isNotEmpty ? item.title.characters.first : '';
    if (firstChar.isNotEmpty && _isCJK(firstChar)) {
      return _charContainer(firstChar, _typeColor);
    }

    // 4. Type icon fallback
    return _iconContainer(_typeIcon, _typeColor);
  }

  Widget _iconContainer(IconData icon, Color iconColor) {
    final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    final effectiveColor = isDark && iconColor.computeLuminance() < 0.2
        ? Colors.white
        : iconColor;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(isDark ? 50 : 25),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, size: size * 0.55, color: effectiveColor),
    );
  }

  Widget _svgContainer(IconInfo info) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: info.color.withAlpha(25),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.22),
        child: SvgPicture.asset(
          info.assetPath,
          width: size * 0.55,
          height: size * 0.55,
          colorFilter: ColorFilter.mode(info.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _charContainer(String char, Color bgColor) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: bgColor.withAlpha(25),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      alignment: Alignment.center,
      child: Text(char, style: TextStyle(
        color: bgColor, fontSize: size * 0.45, fontWeight: FontWeight.w700,
      )),
    );
  }

  bool _isCJK(String s) {
    final code = s.codeUnitAt(0);
    return (code >= 0x4E00 && code <= 0x9FFF) ||
           (code >= 0x3400 && code <= 0x4DBF) ||
           (code >= 0x3040 && code <= 0x309F) ||
           (code >= 0x30A0 && code <= 0x30FF) ||
           (code >= 0xAC00 && code <= 0xD7AF);
  }
}

class _BrandInfo {
  final IconData icon;
  final Color color;
  const _BrandInfo(this.icon, this.color);
}
