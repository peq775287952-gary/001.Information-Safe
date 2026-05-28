import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/item_type.dart';
import '../theme/app_theme.dart';
import '../utils/brand_icons.dart';

class QuickFillChips extends StatelessWidget {
  final ItemType type;
  final ValueChanged<String> onSelected;
  final String? currentValue;

  const QuickFillChips({
    super.key,
    required this.type,
    required this.onSelected,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final options = _options;
    if (options.isEmpty) return const SizedBox.shrink();

    final brightness = fluent.FluentTheme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final mutedColor = isLight ? AppTheme.lightTextSecondary : AppTheme.darkTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('快捷填入',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: mutedColor,
              )),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < options.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _buildChip(options[i], isLight, mutedColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(_QuickOption opt, bool isLight, Color mutedColor) {
    final isSelected = currentValue == opt.name;
    final iconColor = !isLight && opt.color.computeLuminance() < 0.3
        ? Colors.white
        : opt.color;
    return GestureDetector(
      onTap: () => onSelected(opt.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.surfaceBlue
              : (isLight ? const Color(0xFFF1F5F9) : const Color(0xFF2D2D2D)),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppTheme.brandBlue.withAlpha(60))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (opt.svgAsset != null)
              SvgPicture.asset(opt.svgAsset!, width: 14, height: 14,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn))
            else if (opt.iconData != null)
              Icon(opt.iconData, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(opt.name, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.brandBlue : mutedColor,
            )),
          ],
        ),
      ),
    );
  }

  List<_QuickOption> get _options {
    switch (type) {
      case ItemType.password:
        return [
          const _QuickOption('微信', FontAwesomeIcons.weixin, Color(0xFF07C160)),
          const _QuickOption('支付宝', FontAwesomeIcons.alipay, Color(0xFF1677FF)),
          const _QuickOption('QQ', FontAwesomeIcons.qq, Color(0xFF12B7F5)),
          const _QuickOption('微博', FontAwesomeIcons.weibo, Color(0xFFE6162D)),
          const _QuickOption('抖音', FontAwesomeIcons.tiktok, Color(0xFF000000)),
          const _QuickOption('GitHub', FontAwesomeIcons.github, Color(0xFF24292E)),
          const _QuickOption('Google', FontAwesomeIcons.google, Color(0xFF4285F4)),
          const _QuickOption('Apple', FontAwesomeIcons.apple, Color(0xFF000000)),
          const _QuickOption('淘宝', Icons.shopping_bag_outlined, Color(0xFFFF5000)),
          const _QuickOption('京东', Icons.storefront_outlined, Color(0xFFE2231A)),
          const _QuickOption('Steam', FontAwesomeIcons.steam, Color(0xFF171A21)),
          const _QuickOption('Outlook', FontAwesomeIcons.microsoft, Color(0xFF0078D4)),
          const _QuickOption('Gmail', Icons.mail_outline, Color(0xFFEA4335)),
          const _QuickOption('百度', Icons.language, Color(0xFF4E6EF2)),
          const _QuickOption('钉钉', Icons.work_outline, Color(0xFF0089FF)),
          const _QuickOption('Notion', Icons.text_snippet_outlined, Color(0xFF000000)),
          const _QuickOption('飞书', Icons.forum_outlined, Color(0xFF3370FF)),
          const _QuickOption('拼多多', Icons.local_offer_outlined, Color(0xFFE02E24)),
          const _QuickOption('小红书', Icons.auto_stories, Color(0xFFFF2442)),
          const _QuickOption('B站', Icons.smart_display_outlined, Color(0xFFFB7299)),
        ];
      case ItemType.bankCard:
        return [
          _bankQuick('工商银行', const Color(0xFFCC0000)),
          _bankQuick('农业银行', const Color(0xFF009B72)),
          _bankQuick('中国银行', const Color(0xFFCE0000)),
          _bankQuick('建设银行', const Color(0xFF0066CC)),
          _bankQuick('交通银行', const Color(0xFF005BAB)),
          _bankQuick('邮储银行', const Color(0xFF007A3D)),
          _bankQuick('招商银行', const Color(0xFFCE0000)),
          _bankQuick('浦发银行', const Color(0xFF003399)),
        ];
      case ItemType.idDocument:
        return [
          const _QuickOption('身份证', Icons.badge_outlined, AppTheme.idAccent),
          const _QuickOption('护照', Icons.flight_outlined, AppTheme.idAccent),
          const _QuickOption('驾照', Icons.directions_car_outlined, AppTheme.idAccent),
          const _QuickOption('社保卡', Icons.health_and_safety_outlined, AppTheme.idAccent),
          const _QuickOption('户口本', Icons.book_outlined, AppTheme.idAccent),
          const _QuickOption('港澳通行证', Icons.card_travel, AppTheme.idAccent),
          const _QuickOption('居住证', Icons.home_outlined, AppTheme.idAccent),
        ];
      case ItemType.secureNote:
        return const [];
      case ItemType.apiKey:
        return [
          _aiQuick('OpenAI', const Color(0xFF00A67E)),
          _aiQuick('ChatGPT', const Color(0xFF00A67E)),
          _aiQuick('Anthropic', const Color(0xFFD97757)),
          _aiQuick('Claude', const Color(0xFFD97757)),
          _aiQuick('DeepSeek', const Color(0xFF4D6BFE)),
          _aiQuick('通义千问', const Color(0xFFFF6A00)),
          _aiQuick('Kimi', const Color(0xFF6C5CE7)),
          _aiQuick('GLM', const Color(0xFF2563EB)),
          _aiQuick('智谱', const Color(0xFF2563EB)),
          _aiQuick('MiniMax', const Color(0xFF7C3AED)),
          _aiQuick('商汤', const Color(0xFF1E40AF)),
        ];
    }
  }
}

_QuickOption _bankQuick(String name, Color color) {
  final info = BrandIcons.bankBrands[name];
  return _QuickOption(name, null, color, svgAsset: info?.assetPath);
}

_QuickOption _aiQuick(String name, Color color) {
  final info = BrandIcons.aiBrands[name];
  return _QuickOption(name, null, color, svgAsset: info?.assetPath);
}

class _QuickOption {
  final String name;
  final IconData? iconData;
  final String? svgAsset;
  final Color color;

  const _QuickOption(this.name, this.iconData, this.color, {this.svgAsset});
}
