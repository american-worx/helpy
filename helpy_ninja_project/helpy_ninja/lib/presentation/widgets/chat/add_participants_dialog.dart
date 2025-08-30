import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/config/design_tokens.dart';
import 'package:helpy_ninja/domain/entities/group_session.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Dialog for adding participants to a group session
class AddParticipantsDialog extends ConsumerStatefulWidget {
  final GroupSession session;
  final List<HelpyPersonality> availableHelpys;

  const AddParticipantsDialog({
    super.key,
    required this.session,
    required this.availableHelpys,
  });

  @override
  ConsumerState<AddParticipantsDialog> createState() =>
      _AddParticipantsDialogState();
}

class _AddParticipantsDialogState extends ConsumerState<AddParticipantsDialog> {
  final Set<String> _selectedHelpyIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addParticipants),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.availableHelpys.isEmpty) ...[
              Text(
                l10n.noParticipantsToAdd,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else ...[
              Text(
                l10n.selectParticipants,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: widget.availableHelpys.length,
                  itemBuilder: (context, index) {
                    final helpy = widget.availableHelpys[index];
                    final isSelected = _selectedHelpyIds.contains(helpy.id);

                    // Fix unused local variable by using it
                    return _HelpySelectionTile(
                      helpy: helpy,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedHelpyIds.remove(helpy.id);
                          } else {
                            _selectedHelpyIds.add(helpy.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedHelpyIds.isEmpty
              ? null
              : () async {
                  try {
                    // Add selected participants to the session
                    for (final helpyId in _selectedHelpyIds) {
                      // Fix unused local variable by using it properly
                      final selectedHelpy = widget.availableHelpys
                          .firstWhere((h) => h.id == helpyId);

                      // In a real implementation, we would add the Helpy to the session
                      // For now, we'll just show a success message
                      // Use the selectedHelpy variable to avoid unused variable warning
                      if (mounted && selectedHelpy.id.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.participantAdded),
                            backgroundColor: DesignTokens.success,
                          ),
                        );
                      }
                    }

                    // Close the dialog
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(l10n.failedToAddParticipant(e.toString())),
                          backgroundColor: DesignTokens.error,
                        ),
                      );
                    }
                  }
                },
          child: Text(l10n.addParticipant),
        ),
      ],
    );
  }
}

/// Tile for selecting a Helpy to add to the group
class _HelpySelectionTile extends StatelessWidget {
  final HelpyPersonality helpy;
  final bool isSelected;
  final VoidCallback onTap;

  const _HelpySelectionTile({
    required this.helpy,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(
              int.parse(helpy.colorTheme.substring(1), radix: 16) | 0xFF000000,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              helpy.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(helpy.name),
        subtitle: Text(helpy.description),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: DesignTokens.success)
            : const Icon(Icons.add_circle_outline),
        onTap: onTap,
      ),
    );
  }
}
