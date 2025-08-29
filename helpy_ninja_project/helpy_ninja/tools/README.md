# Tools

This directory contains utility scripts for development and maintenance tasks.

## Localization Tools

- `check_duplicates.dart` - Check for duplicate keys in ARB files
- `find_missing_keys.dart` - Find keys that exist in one language but not another
- `count_keys.dart` - Count the number of keys in ARB files
- `count_keys_proper.dart` - Count keys with proper filtering
- `verify_keys.dart` - Verify ARB file integrity and key consistency

## Usage

Run these scripts from the project root directory:

```bash
dart tools/check_duplicates.dart
dart tools/find_missing_keys.dart
dart tools/count_keys.dart
dart tools/count_keys_proper.dart
dart tools/verify_keys.dart
```