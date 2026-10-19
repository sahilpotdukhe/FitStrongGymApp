// A one-off admin script run by hand from a dev machine; the console
// output below is its whole user interface.
// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> fillMissingCheckInOutTimes() async {
  try {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("❌ No user signed in");
      return;
    }

    final uid = currentUser.uid;

    final membersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('members')
        .get();

    int updatedCount = 0;

    for (final doc in membersSnapshot.docs) {
      final data = doc.data();
      final memberRef = doc.reference;

      final String? checkInTime = data['checkInTime']?.toString().trim();
      final String? checkOutTime = data['checkOutTime']?.toString().trim();

      bool needsUpdate = false;
      final Map<String, dynamic> updates = {};

      if (checkInTime == null || checkInTime.isEmpty) {
        updates['checkInTime'] = '5:00 AM';
        needsUpdate = true;
      }

      if (checkOutTime == null || checkOutTime.isEmpty) {
        updates['checkOutTime'] = '6:00 AM';
        needsUpdate = true;
      }

      if (needsUpdate) {
        await memberRef.update(updates);
        print("🛠️ Updated '${data['name']}' with dummy check-in/out time.");
        updatedCount++;
      }
    }

    if (updatedCount == 0) {
      print("✅ All members already have check-in and check-out times.");
    } else {
      print("✅ $updatedCount member(s) updated with default times.");
    }
  } catch (e) {
    print("❌ Error updating check-in/out times: $e");
  }
}
