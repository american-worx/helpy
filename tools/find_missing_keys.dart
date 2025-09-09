import 'dart:convert';
import 'dart:io';

void main() {
  // Read English ARB file
  final enFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_en.arb');
  final enContent = json.decode(enFile.readAsStringSync());
  
  // Read Vietnamese ARB file
  final viFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_vi.arb');
  final viContent = json.decode(viFile.readAsStringSync());
  
  // Get actual localization keys (not metadata)
  final enKeys = enContent.keys.where((key) => !key.startsWith('@') && key != '@@locale').toSet();
  final viKeys = viContent.keys.where((key) => !key.startsWith('@') && key != '@@locale').toSet();
  
  // Find keys that are in Vietnamese but not in English
  final missingInEn = viKeys.difference(enKeys);
  
  print('Keys in Vietnamese but not in English (${missingInEn.length}):');
  for (var key in missingInEn.toList()..sort()) {
    print('  $key');
  }
}