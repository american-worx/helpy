import 'package:flutter/material.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import 'package:helpy_ninja/presentation/widgets/dashboard/components/subject_progress_item.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/learning_stats.dart';
import '../../../widgets/layout/modern_layout.dart';

/// Subject progress section showing progress in different subjects
class SubjectProgressSection extends StatelessWidget {
  const SubjectProgressSection({super.key, required this.subjectProgress});

  final Map<String, SubjectProgress> subjectProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (subjectProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    return ModernSection(
      title: l10n.subjectProgress,
      subtitle: l10n.yourProgressInDifferentSubjects,
      showGlassmorphism: true,
      child: Column(
        children: subjectProgress.values
            .map((subject) => SubjectProgressItem(subject: subject))
            .toList(),
      ),
    );
  }
}
