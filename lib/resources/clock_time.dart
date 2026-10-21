import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// How a time of day — a member's check in and check out, a trainer's shift —
/// is written down and read back.
///
/// Everything is stored on a 24 hour clock as "HH:mm", so "17:30" and never
/// "5:30 PM". Times used to be saved exactly the way the phone happened to
/// draw them, which on a phone set to a 12 hour clock meant "5:30 PM" went
/// into the database. Reading that back split the text at the colon and tried
/// to turn "30 PM" into a number, so opening a saved trainer to edit their
/// shift threw an error the moment the screen appeared — but only on a 12
/// hour phone, which is why it could sit there unnoticed.
///
/// Keeping one fixed format in the database and only prettying it up at the
/// moment it is drawn keeps saving and reading in step on every phone.
class ClockTime {
  const ClockTime._();

  /// What goes into the database.
  ///
  /// A time nobody picked is stored as an empty string rather than throwing.
  /// Check in and check out are optional on the add member form, so a blank
  /// one is an ordinary thing to save, not a mistake.
  static String toStorage(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Reads a stored time back.
  ///
  /// Understands both the "HH:mm" written today and the "5:30 PM" left behind
  /// by older versions of the app, because records saved before this change
  /// are still sitting in the database. Anything blank or unreadable comes
  /// back as null instead of throwing.
  static TimeOfDay? parse(String? stored) {
    final text = stored?.trim() ?? '';
    if (text.isEmpty) return null;

    // The gap before AM/PM is not always a plain space: some locales use a
    // non-breaking or narrow one, which a bare \s would miss.
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:[\s  ]*([AaPp])\.?[Mm]\.?)?$',
    ).firstMatch(text);
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final halfOfDay = match.group(3)?.toUpperCase();

    if (halfOfDay != null) {
      // On a 12 hour clock only 1 to 12 mean anything.
      if (hour < 1 || hour > 12) return null;
      hour = hour % 12; // 12 AM is midnight, hour 0.
      if (halfOfDay == 'P') hour += 12; // 12 PM is noon, hour 12.
    }

    if (hour > 23 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Rewrites an old stored value into today's format.
  ///
  /// Anything it cannot make sense of is handed back exactly as it was found,
  /// so opening a record can never quietly wipe a time it failed to read.
  static String normalize(String stored) {
    final time = parse(stored);
    return time == null ? stored : toStorage(time);
  }

  /// A stored time written out for people to read, such as "5:30 PM".
  ///
  /// For the places that have no [BuildContext] to hand, like building a
  /// trainer's shift line inside the model. An empty or unreadable value is
  /// passed straight through so nothing invents a time that was never set.
  static String label(String stored) {
    final time = parse(stored);
    if (time == null) return stored;
    final text =
        DateFormat.jm().format(DateTime(2000, 1, 1, time.hour, time.minute));
    // Recent date formatting puts a narrow no-break space before AM/PM. It
    // looks like an ordinary space but is not one, and a font that has no
    // glyph for it draws an empty box instead, so it is swapped for a plain
    // space before the text goes anywhere near a card or a PDF.
    return text.replaceAll(RegExp(r'[  ]'), ' ');
  }

  /// The same as [label], but following the phone's own 12 or 24 hour
  /// setting. Preferred on screen, where a [BuildContext] is available.
  static String display(BuildContext context, String stored) {
    final time = parse(stored);
    if (time == null) return stored;
    return time.format(context);
  }
}
