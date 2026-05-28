import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'services/auth_service.dart';
import 'services/vault_service.dart';
import 'services/photo_service.dart';
import 'services/export_import_service.dart';
import 'app.dart';
import 'app_windows.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (Platform.isWindows) {
    await acrylic.Window.initialize();
  }

  final databaseService = DatabaseService();
  final encryptionService = EncryptionService();
  final authService = AuthService(encryptionService);
  final vaultService = VaultService(databaseService, encryptionService);
  final photoService = PhotoService(encryptionService);
  final exportImportService =
      ExportImportService(databaseService, encryptionService, vaultService);
  authService.setVaultService(vaultService);

  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => vaultService),
        Provider.value(value: photoService),
        Provider.value(value: exportImportService),
      ],
      child: Platform.isWindows
          ? const InfoVaultAppWindows()
          : const InfoVaultApp(),
    ),
  );
}