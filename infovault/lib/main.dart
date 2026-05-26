import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'services/auth_service.dart';
import 'services/vault_service.dart';
import 'services/photo_service.dart';
import 'services/export_import_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final databaseService = DatabaseService();
  final encryptionService = EncryptionService();
  final authService = AuthService(encryptionService);
  final vaultService = VaultService(databaseService, encryptionService);
  final photoService = PhotoService(encryptionService);
  final exportImportService = ExportImportService(databaseService, encryptionService, vaultService);

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
      child: const InfoVaultApp(),
    ),
  );
}
