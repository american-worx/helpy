import 'dart:convert';
import 'dart:io';

void main() {
  // Read English ARB file
  final enFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_en.arb');
  final enContent = json.decode(enFile.readAsStringSync());
  
  // Read Vietnamese ARB file
  final viFile = File('helpy_ninja_project/helpy_ninja/lib/l10n/app_vi.arb');
  final viContent = json.decode(viFile.readAsStringSync());
  
  // Find duplicate keys in English file
  final enKeys = enContent.keys.where((key) => !key.startsWith('@')).toList();
  final enKeyCounts = <String, int>{};
  for (var key in enKeys) {
    enKeyCounts[key] = (enKeyCounts[key] ?? 0) + 1;
  }
  final enDuplicates = enKeyCounts.entries.where((entry) => entry.value > 1).toList();
  
  // Find duplicate keys in Vietnamese file
  final viKeys = viContent.keys.where((key) => !key.startsWith('@')).toList();
  final viKeyCounts = <String, int>{};
  for (var key in viKeys) {
    viKeyCounts[key] = (viKeyCounts[key] ?? 0) + 1;
  }
  final viDuplicates = viKeyCounts.entries.where((entry) => entry.value > 1).toList();
  
  print('English ARB file has ${enKeys.length} keys');
  print('English duplicates: ${enDuplicates.length}');
  if (enDuplicates.isNotEmpty) {
    print('Duplicate keys in English file:');
    for (var dup in enDuplicates) {
      print('  ${dup.key}: ${dup.value} times');
    }
  }
  
  print('\nVietnamese ARB file has ${viKeys.length} keys');
  print('Vietnamese duplicates: ${viDuplicates.length}');
  if (viDuplicates.isNotEmpty) {
    print('Duplicate keys in Vietnamese file:');
    for (var dup in viDuplicates) {
      print('  ${dup.key}: ${dup.value} times');
    }
  }
  
  // Check if both files have the same keys
  final enKeySet = enKeys.toSet();
  final viKeySet = viKeys.toSet();
  
  final missingInVi = enKeySet.difference(viKeySet);
  final missingInEn = viKeySet.difference(enKeySet);
  
  print('\nKeys in English but not in Vietnamese: ${missingInVi.length}');
  if (missingInVi.isNotEmpty) {
    print('Missing in Vietnamese: $missingInVi');
  }
  
  print('Keys in Vietnamese but not in English: ${missingInEn.length}');
  if (missingInEn.isNotEmpty) {
    print('Missing in English: $missingInEn');
  }
}