class SmartCategoryService {
  final Map<String, String> _platformCategoryMap = {
    // 社交
    '微信': '社交', 'wechat': '社交', 'QQ': '社交',
    '微博': '社交', 'weibo': '社交', '抖音': '社交',
    'tiktok': '社交', '小红书': '社交', 'telegram': '社交',
    'discord': '社交', 'slack': '社交', 'whatsapp': '社交',
    'line': '社交', 'signal': '社交',

    // 金融
    '支付宝': '金融', 'alipay': '金融', '微信支付': '金融',
    '招商银行': '金融', '工商银行': '金融', '建设银行': '金融',
    '农业银行': '金融', '中国银行': '金融', '交通银行': '金融',
    'paypal': '金融', 'stripe': '金融',

    // 邮箱
    'gmail': '邮箱', 'outlook': '邮箱', 'qq邮箱': '邮箱',
    '163邮箱': '邮箱', '126邮箱': '邮箱', 'yahoo': '邮箱',
    'protonmail': '邮箱',

    // 开发
    'github': '开发', 'gitlab': '开发', 'bitbucket': '开发',
    'stackoverflow': '开发', 'docker': '开发', 'npm': '开发',
    'vercel': '开发', 'aws': '开发', 'azure': '开发',
    'google cloud': '开发', 'cloudflare': '开发',

    // 购物
    '淘宝': '购物', 'taobao': '购物', '天猫': '购物',
    '京东': '购物', 'jd': '购物', '拼多多': '购物',
    'amazon': '购物', 'ebay': '购物',

    // 娱乐
    'netflix': '娱乐', 'spotify': '娱乐', 'youtube': '娱乐',
    'bilibili': '娱乐', 'b站': '娱乐', 'steam': '娱乐',
    'epic': '娱乐', 'nintendo': '娱乐',

    // 办公
    'notion': '办公', '飞书': '办公', '钉钉': '办公',
    '企业微信': '办公', 'google drive': '办公', 'dropbox': '办公',
    'onedrive': '办公', 'figma': '办公', 'canva': '办公',

    // 证件
    '身份证': '证件', '护照': '证件', '驾照': '证件',
    '社保卡': '证件', '户口本': '证件',
  };

  final Map<String, String> _urlCategoryMap = {
    'weixin': '社交', 'wechat': '社交', 'qq.com': '社交',
    'weibo.com': '社交', 'douyin.com': '社交',
    'alipay.com': '金融', 'paypal.com': '金融',
    'github.com': '开发', 'gitlab.com': '开发',
    'taobao.com': '购物', 'jd.com': '购物', 'amazon.com': '购物',
    'gmail.com': '邮箱', 'outlook.com': '邮箱',
    'youtube.com': '娱乐', 'bilibili.com': '娱乐', 'steam.com': '娱乐',
    'notion.so': '办公', 'feishu.cn': '办公',
  };

  /// Suggest a category based on platform name or URL. Returns null if no match.
  String? suggest(String platformNameOrUrl) {
    final lower = platformNameOrUrl.toLowerCase().trim();

    // Exact match with platform name
    if (_platformCategoryMap.containsKey(lower)) {
      return _platformCategoryMap[lower];
    }

    // Fuzzy match
    for (final entry in _platformCategoryMap.entries) {
      if (lower.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(lower)) {
        return entry.value;
      }
    }

    // Try URL matching
    return suggestByUrl(lower);
  }

  /// Suggest a category based on URL patterns.
  String? suggestByUrl(String url) {
    final lower = url.toLowerCase().trim();

    for (final entry in _urlCategoryMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Heuristic based on TLD/keywords
    if (lower.endsWith('.com.cn')) return '购物';
    if (lower.contains('bank') || lower.contains('银行')) return '金融';
    if (lower.contains('mail') || lower.contains('邮箱')) return '邮箱';
    if (lower.contains('gov')) return '证件';

    return null;
  }
}
