import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ClipboardService {
  static final ClipboardService instance = ClipboardService._();
  ClipboardService._();

  Timer? _clearTimer;
  String? _lastCopiedValue;

  String? get lastCopiedValue => _lastCopiedValue;
  bool get hasPendingClear => _clearTimer != null && _clearTimer!.isActive;

  void copy(String value) {
    _clearTimer?.cancel();
    _lastCopiedValue = value;
    Clipboard.setData(ClipboardData(text: value));

    _clearTimer = Timer(
      const Duration(seconds: AppConstants.clipboardClearSeconds),
      () {
        _tryClear();
      },
    );
  }

  Future<void> _tryClear() async {
    if (_lastCopiedValue == null) return;

    try {
      final currentContent = await Clipboard.getData(Clipboard.kTextPlain);
      if (currentContent?.text == _lastCopiedValue) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {
      // Silently ignore clipboard read errors
    } finally {
      _lastCopiedValue = null;
      _clearTimer = null;
    }
  }

  void dispose() {
    _clearTimer?.cancel();
    _lastCopiedValue = null;
  }
}
