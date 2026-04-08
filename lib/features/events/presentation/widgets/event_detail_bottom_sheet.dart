import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/event_model.dart';
import 'package:quetame_turismo/theme/app_theme.dart';

/// Modal inferior con detalle completo del evento y acción de calendario.
class EventDetailBottomSheet extends StatelessWidget {
  final EventModel event;

  const EventDetailBottomSheet({
    super.key,
    required this.event,
  });

  static void show(BuildContext context, EventModel event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EventDetailBottomSheet(event: event),
    );
  }

  String _fullDateLabel() {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final d = event.startDateTime.toLocal();
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  void _showCalendarError(BuildContext context, Object error) {
    if (!context.mounted) return;
    final message = error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _addToCalendar(BuildContext context) async {
    final title = event.title.trim();
    final description = event.description.trim();
    final location = event.location.trim();

    if (title.isEmpty) {
      _showCalendarError(context, 'El título del evento no puede estar vacío.');
      return;
    }

    final start = event.startDateTime.toLocal();
    var end = event.endDateTime.toLocal();

    if (!end.isAfter(start)) {
      end = start.add(const Duration(hours: 1));
    } else if (end.difference(start) < const Duration(hours: 1)) {
      end = start.add(const Duration(hours: 1));
    }

    final calEvent = a2c.Event(
      title: title,
      description: description.isEmpty ? 'Evento — Quetame Turismo' : description,
      location: location.isEmpty ? 'Quetame, Cundinamarca' : location,
      startDate: start,
      endDate: end,
    );

    try {
      final ok = await a2c.Add2Calendar.addEvent2Cal(calEvent);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Evento añadido al calendario'
                : 'No se pudo abrir el calendario (ninguna app respondió)',
          ),
        ),
      );
    } catch (e) {
      _showCalendarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.topSheet,
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                      borderRadius: AppRadii.md,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                  children: [
                    ClipRRect(
                      borderRadius: AppRadii.lg,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.event_outlined,
                              size: 64,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Chip(
                      label: Text(event.category.label),
                      backgroundColor:
                          event.category.color.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: event.category.color,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide.none,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: _fullDateLabel(),
                      scheme: scheme,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.schedule_outlined,
                      label: 'Hora',
                      value: event.time,
                      scheme: scheme,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: 'Ubicación',
                      value: event.location,
                      scheme: scheme,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Resumen',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: scheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _addToCalendar(context),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Añadir a mi Calendario'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.md,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
