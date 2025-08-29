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
  
  print('English ARB file has ${enKeys.length} localization keys');
  print('Vietnamese ARB file has ${viKeys.length} localization keys');
  
  // Check if they have the same keys
  if (enKeys.length == viKeys.length) {
    final missingInEn = viKeys.difference(enKeys);
    final missingInVi = enKeys.difference(viKeys);
    
    if (missingInEn.isEmpty && missingInVi.isEmpty) {
      print('Both files have the same keys! ✅');
    } else {
      print('Keys in Vietnamese but not in English: ${missingInEn.length}');
      print('Keys in English but not in Vietnamese: ${missingInVi.length}');
    }
  } else {
    print('Files have different number of keys ❌');
    final missingInEn = viKeys.difference(enKeys);
    final missingInVi = enKeys.difference(viKeys);
    
    print('Keys in Vietnamese but not in English: ${missingInEn.length}');
    if (missingInEn.isNotEmpty) {
      print('Missing in English: ${missingInEn.toList()..sort()}');
    }
    
    print('Keys in English but not in Vietnamese: ${missingInVi.length}');
    if (missingInVi.isNotEmpty) {
      print('Missing in Vietnamese: ${missingInVi.toList()..sort()}');
    }
  }
}