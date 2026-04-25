import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/journal_provider.dart';

class JournalInputField extends StatefulWidget {
  const JournalInputField({super.key});

  @override
  State<JournalInputField> createState() => _JournalInputFieldState();
}

class _JournalInputFieldState extends State<JournalInputField> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      context.read<JournalProvider>().addEntry(text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "What's on your mind today?",
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              border: InputBorder.none,
            ),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Consumer<JournalProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text("Save"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
