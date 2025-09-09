import 'dart:convert';
import 'dart:io';

void main() {
  // Count keys in English ARB file
  final enFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_en.arb');
  final enContent = json.decode(enFile.readAsStringSync());
  
  // Count keys in Vietnamese ARB file
  final viFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_vi.arb');
  final viContent = json.decode(viFile.readAsStringSync());
  
  // Filter out metadata keys (those starting with @)
  final enKeys = enContent.keys.where((key) => !key.startsWith('@')).toList();
  final viKeys = viContent.keys.where((key) => !key.startsWith('@')).toList();
  
  print('English ARB file has ${enKeys.length} keys');
  print('Vietnamese ARB file has ${viKeys.length} keys');
  
  // Find keys that are in English but not in Vietnamese
  final missingInVi = enKeys.where((key) => !viKeys.contains(key)).toList();
  print('Keys in English but not in Vietnamese: ${missingInVi.length}');
  print('Missing keys: $missingInVi');
  
  // Find keys that are in Vietnamese but not in English
  final missingInEn = viKeys.where((key) => !enKeys.contains(key)).toList();
  print('Keys in Vietnamese but not in English: ${missingInEn.length}');
  print('Extra keys: $missingInEn');
}