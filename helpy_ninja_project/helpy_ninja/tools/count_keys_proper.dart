import 'dart:convert';
import 'dart:io';

void main() {
  // Read English ARB file
  final enFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_en.arb');
  final enContent = json.decode(enFile.readAsStringSync());
  
  // Read Vietnamese ARB file
  final viFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_vi.arb');
  final viContent = json.decode(viFile.readAsStringSync());
  
  // Count actual localization keys (not metadata)
  final enKeys = enContent.keys.where((key) => !key.startsWith('@') && key != '@@locale').toList();
  final viKeys = viContent.keys.where((key) => !key.startsWith('@') && key != '@@locale').toList();
  
  print('English ARB file has ${enKeys.length} localization keys');
  print('Vietnamese ARB file has ${viKeys.length} localization keys');
  
  // Find keys that are in English but not in Vietnamese
  final missingInVi = enKeys.where((key) => !viKeys.contains(key)).toList();
  print('\nKeys in English but not in Vietnamese: ${missingInVi.length}');
  
  // Find keys that are in Vietnamese but not in English
  final missingInEn = viKeys.where((key) => !enKeys.contains(key)).toList();
  print('Keys in Vietnamese but not in English: ${missingInEn.length}');
  
  // Check for duplicates in English file
  final enKeySet = <String>{};
  final enDuplicates = <String>[];
  for (var key in enKeys) {
    if (enKeySet.contains(key)) {
      enDuplicates.add(key);
    } else {
      enKeySet.add(key);
    }
  }
  
  // Check for duplicates in Vietnamese file
  final viKeySet = <String>{};
  final viDuplicates = <String>[];
  for (var key in viKeys) {
    if (viKeySet.contains(key)) {
      viDuplicates.add(key);
    } else {
      viKeySet.add(key);
    }
  }
  
  print('\nDuplicate keys in English file: ${enDuplicates.length}');
  if (enDuplicates.isNotEmpty) {
    print('Duplicates: ${enDuplicates.join(', ')}');
  }
  
  print('Duplicate keys in Vietnamese file: ${viDuplicates.length}');
  if (viDuplicates.isNotEmpty) {
    print('Duplicates: ${viDuplicates.join(', ')}');
  }
}