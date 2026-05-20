import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enlace Google Calendar (Web) y lanzador nativo vía [url_launcher].
class CalendarLinkBuilder {
  const CalendarLinkBuilder._();

  static String googleCalendarUrl({
    required String title,
    required String description,
    required String location,
    required DateTime start,
    required DateTime end,
  }) {
    final startLocal = start.toLocal();
    final endLocal = end.toLocal();
    final dates =
        '${_formatGoogleDate(startLocal)}/${_formatGoogleDate(endLocal)}';

    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': title,
      'details': description,
      'location': location,
      'dates': dates,
    }).toString();
  }

  static String _formatGoogleDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}${two(dt.month)}${two(dt.day)}T'
        '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}';
  }

  static Future<bool> openGoogleCalendarInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  static bool get useGoogleCalendarWeb => kIsWeb;
}
