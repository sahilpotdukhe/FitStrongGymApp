import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands the gym owner their member list as a spreadsheet they keep.
///
/// Everything otherwise lives only in Firebase. A file the owner holds means
/// the records survive a lost phone, a closed account or a change of app, and
/// it opens in Excel, Numbers, Google Sheets or anything else they already
/// use.
class MemberCsvExport {
  const MemberCsvExport._();

  /// The heading row, and the order every row below follows.
  static const List<String> columns = [
    'Name',
    'Mobile number',
    'Gender',
    'Date of birth',
    'Address',
    'Height (cm)',
    'Weight (kg)',
    'Plan',
    'Trainer',
    'Joined on',
    'Renewal date',
    'Expiry date',
    'Status',
    'Check in',
    'Check out',
  ];

  /// Dates go out in year-month-day order. It is the one format spreadsheets
  /// read the same way everywhere, where "03/04/2026" is read as March in one
  /// country and April in another.
  static final DateFormat _date = DateFormat('yyyy-MM-dd');

  /// Builds the whole spreadsheet as text.
  ///
  /// Plans and trainers are passed in so each row can show the name the owner
  /// knows rather than the id stored against the member. Anything since
  /// deleted is left blank instead of holding the export up.
  ///
  /// Kept free of files and screens so it can be checked by tests on its own.
  static String build({
    required List<MemberModel> members,
    required List<GymPlanModel> plans,
    required List<TrainerModel> trainers,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final planNames = {for (final plan in plans) plan.id: plan.name};
    final trainerNames = {
      for (final trainer in trainers) trainer.id: trainer.name
    };

    final rows = <List<String>>[columns];

    for (final member in members) {
      rows.add([
        member.name,
        member.mobileNumber,
        member.gender,
        _date.format(member.dateOfBirth),
        member.address,
        _measurement(member.height),
        _measurement(member.weight),
        planNames[member.planId] ?? '',
        trainerNames[member.trainerId] ?? '',
        _date.format(member.dateOfAdmission),
        _date.format(member.renewalDate),
        _date.format(member.expiryDate),
        now.isAfter(member.expiryDate) ? 'Expired' : 'Active',
        ClockTime.label(member.checkInTime),
        ClockTime.label(member.checkOutTime),
      ]);
    }

    // Rows end with a carriage return and a line feed, which is what the
    // spreadsheet format asks for and what Excel on Windows expects.
    return rows.map((row) => row.map(_field).join(',')).join('\r\n');
  }

  /// A height or weight without the trailing ".0" on a whole number, so the
  /// column reads 70 rather than 70.0.
  static String _measurement(double value) {
    if (value == 0) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  /// Prepares one value to sit in the file.
  ///
  /// Anything holding a comma, a quote or a line break is wrapped in quotes,
  /// with quotes inside it doubled — otherwise an address with a comma in it
  /// would split into two columns and shift the whole row along.
  static String _field(String value) {
    final safe = _defuseFormula(value);
    if (safe.contains(RegExp(r'[",\r\n]'))) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }

  /// Keeps a spreadsheet from treating a stored value as a formula.
  ///
  /// Excel runs a cell starting with =, + or @ as a calculation, so a member
  /// whose name or address began with one of those could make the owner's
  /// spreadsheet do something they never asked for when they opened the file.
  /// A leading apostrophe marks the cell as plain text; spreadsheets hide it
  /// and show the value as written.
  ///
  /// Numbers are left alone deliberately: this is only ever given free text
  /// such as a name or an address, never a date or a measurement the app
  /// produced itself.
  static String _defuseFormula(String value) {
    if (value.isEmpty) return value;
    return RegExp(r'^[=+@]').hasMatch(value) ? "'$value" : value;
  }

  /// Writes the spreadsheet to a file on the phone and returns it.
  ///
  /// The file opens with a byte order mark so that Excel shows names and the
  /// rupee sign correctly rather than as mangled characters.
  static Future<File> writeFile(String csv, {String gymName = ''}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName(gymName: gymName)}');
    return file.writeAsString('﻿$csv');
  }

  /// A name the owner can recognise months later, e.g.
  /// "fitstrong-members-2026-10-21.csv".
  static String fileName({String gymName = '', DateTime? asOf}) {
    final stamp = _date.format(asOf ?? DateTime.now());
    final slug = gymName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'members-$stamp.csv' : '$slug-members-$stamp.csv';
  }

  /// Gathers everything the file needs, writes it and opens the phone's share
  /// sheet so the owner can put it wherever they keep their records.
  ///
  /// Nothing leaves the phone on its own: the owner picks the destination,
  /// whether that is email, a messaging app or their own files.
  ///
  /// Returns false when there was nothing to export or it could not be
  /// written, having already explained why on screen.
  static Future<bool> run(BuildContext context) async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final planProvider = Provider.of<GymPlanProvider>(context, listen: false);
    final trainerProvider =
        Provider.of<TrainerProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Opening the account tab straight after signing in means some of these
      // lists have not been fetched yet, and an export missing every plan
      // name would look broken rather than empty.
      if (memberProvider.members.isEmpty) await memberProvider.getAllMembers();
      if (planProvider.plans.isEmpty) await planProvider.fetchPlans();
      if (trainerProvider.trainers.isEmpty) {
        await trainerProvider.fetchTrainers();
      }

      final members = memberProvider.members;
      if (members.isEmpty) {
        if (!context.mounted) return false;
        showErrorToast(
          context,
          'No members to export',
          description: 'Add a member first, then try again.',
        );
        return false;
      }

      final csv = build(
        members: members,
        plans: planProvider.plans,
        trainers: trainerProvider.trainers,
      );
      final file = await writeFile(
        csv,
        gymName: userProvider.getUser?.name ?? '',
      );

      if (!context.mounted) return false;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Member list',
          text: '${members.length} members, exported on '
              '${DateFormat('d MMM yyyy').format(DateTime.now())}.',
        ),
      );
      return true;
    } catch (error) {
      debugPrint('Could not export members: $error');
      if (!context.mounted) return false;
      showErrorToast(
        context,
        'Could not export the member list',
        description: 'Check your connection and try again.',
      );
      return false;
    }
  }
}
