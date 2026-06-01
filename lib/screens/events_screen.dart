import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:provider/provider.dart';
import 'package:quetame_turismo/core/calendar_link_builder.dart';
import 'package:quetame_turismo/models/event_model.dart';
import 'package:quetame_turismo/providers/event_provider.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>().events;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _TimelineEventTile(
          event: events[index],
          isLast: index == events.length - 1,
        );
      },
    );
  }
}

class _TimelineEventTile extends StatelessWidget {
  const _TimelineEventTile({
    required this.event,
    required this.isLast,
  });

  final EventModel event;
  final bool isLast;

  Future<void> _addToCalendar(BuildContext context) async {
    final title = event.title.trim();
    final description = event.description.trim();
    final location = event.location.trim();
    final start = event.startDateTime.toLocal();
    final end = event.endDateTime.isAfter(start)
        ? event.endDateTime.toLocal()
        : start.add(const Duration(hours: 1));

    if (CalendarLinkBuilder.useGoogleCalendarWeb) {
      final url = CalendarLinkBuilder.googleCalendarUrl(
        title: title,
        description: description,
        location: location,
        start: start,
        end: end,
      );
      await CalendarLinkBuilder.openGoogleCalendarInBrowser(url);
      return;
    }

    await a2c.Add2Calendar.addEvent2Cal(
      a2c.Event(
        title: title,
        description: description,
        location: location,
        startDate: start,
        endDate: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.goldPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: AppColors.goldPrimary.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.time,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.dayOfWeek} · ${event.day} ${event.month} · ${event.location}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _addToCalendar(context),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Añadir a mi calendario'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
