import 'package:flutter/material.dart';

void main() {
  runApp(const CallHistoryApp());
}

enum CallType {
  incoming,
  outgoing,
  missed,
}

class CallEntry {
  CallEntry({
    required this.name,
    required this.number,
    required this.simLabel,
    required this.type,
    required this.time,
    required this.duration,
    this.note,
  });

  final String name;
  final String number;
  final String simLabel;
  final CallType type;
  final DateTime time;
  final Duration duration;
  String? note;
}

class CallHistoryApp extends StatefulWidget {
  const CallHistoryApp({super.key});

  @override
  State<CallHistoryApp> createState() => _CallHistoryAppState();
}

class _CallHistoryAppState extends State<CallHistoryApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final List<CallEntry> _calls = [
    CallEntry(
      name: 'Avery Johnson',
      number: '+1 (312) 555-0182',
      simLabel: 'SIM1',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      duration: const Duration(minutes: 12, seconds: 41),
      note: 'Follow up about contract terms.',
    ),
    CallEntry(
      name: 'Marcus Lee',
      number: '+1 (212) 555-0175',
      simLabel: 'SIM2',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(hours: 2, minutes: 4)),
      duration: const Duration(minutes: 3, seconds: 9),
    ),
    CallEntry(
      name: 'Priya Patel',
      number: '+1 (415) 555-0124',
      simLabel: 'SIM1',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
      duration: Duration.zero,
      note: 'Send product deck.',
    ),
    CallEntry(
      name: 'Noah Kim',
      number: '+1 (646) 555-0199',
      simLabel: 'SIM2',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      duration: const Duration(minutes: 24, seconds: 5),
    ),
    CallEntry(
      name: 'Sofia Martinez',
      number: '+1 (404) 555-0109',
      simLabel: 'SIM1',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      duration: const Duration(minutes: 6, seconds: 42),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call History',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF60A5FA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Call History'),
          actions: [
            Icon(
              _themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : _themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
            ),
            const SizedBox(width: 8),
            Switch(
              value: _themeMode == ThemeMode.dark,
              onChanged: (value) {
                setState(() {
                  _themeMode = value ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnalyticsSection(calls: _calls),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Calls',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    itemCount: _calls.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final call = _calls[index];
                      return _CallCard(
                        call: call,
                        onAction: (label) => _showSnackBar(label, call),
                        onUpdateNote: (note) {
                          setState(() {
                            call.note = note;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnackBar(String label, CallEntry call) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label: ${call.name} (${call.number})'),
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.calls});

  final List<CallEntry> calls;

  @override
  Widget build(BuildContext context) {
    final totalCalls = calls.length;
    final incoming = calls.where((call) => call.type == CallType.incoming).length;
    final outgoing = calls.where((call) => call.type == CallType.outgoing).length;
    final missed = calls.where((call) => call.type == CallType.missed).length;
    final totalDuration = calls.fold<Duration>(
      Duration.zero,
      (sum, call) => sum + call.duration,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Call Analytics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(
              label: 'Total calls',
              value: totalCalls.toString(),
              icon: Icons.call,
            ),
            _StatCard(
              label: 'Incoming',
              value: incoming.toString(),
              icon: Icons.call_received,
            ),
            _StatCard(
              label: 'Outgoing',
              value: outgoing.toString(),
              icon: Icons.call_made,
            ),
            _StatCard(
              label: 'Missed',
              value: missed.toString(),
              icon: Icons.call_missed,
            ),
            _StatCard(
              label: 'Total duration',
              value: _formatDuration(totalDuration),
              icon: Icons.timer,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallCard extends StatelessWidget {
  const _CallCard({
    required this.call,
    required this.onAction,
    required this.onUpdateNote,
  });

  final CallEntry call;
  final void Function(String label) onAction;
  final void Function(String? note) onUpdateNote;

  @override
  Widget build(BuildContext context) {
    final typeLabel = _callTypeLabel(call.type);
    final typeColor = _callTypeColor(call.type, context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(call.name.substring(0, 1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        call.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        call.number,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _SimBadge(label: call.simLabel),
                          Text(
                            typeLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            _formatTimestamp(call.time),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatDuration(call.duration),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.message,
                  label: 'SMS',
                  onPressed: () => onAction('Open SMS'),
                ),
                _ActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  onPressed: () => onAction('Start call'),
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  onPressed: () => onAction('Open WhatsApp'),
                ),
                _ActionButton(
                  icon: Icons.business,
                  label: 'WhatsApp Biz',
                  onPressed: () => onAction('Open WhatsApp Biz'),
                ),
                _ActionButton(
                  icon: Icons.edit_note,
                  label: call.note == null ? 'Add note' : 'Edit note',
                  onPressed: () => _openNoteSheet(context),
                ),
              ],
            ),
            if (call.note != null) ...[
              const SizedBox(height: 12),
              Text(
                call.note!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openNoteSheet(BuildContext context) {
    final controller = TextEditingController(text: call.note ?? '');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note for ${call.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add context for this call...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final value = controller.text.trim();
                      onUpdateNote(value.isEmpty ? null : value);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _callTypeLabel(CallType type) {
    switch (type) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
    }
  }

  Color _callTypeColor(CallType type, BuildContext context) {
    switch (type) {
      case CallType.incoming:
        return Colors.green.shade600;
      case CallType.outgoing:
        return Theme.of(context).colorScheme.primary;
      case CallType.missed:
        return Colors.red.shade600;
    }
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return '0s';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes >= 60) {
      final hours = duration.inHours;
      return '${hours}h ${minutes.remainder(60)}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

class _SimBadge extends StatelessWidget {
  const _SimBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
