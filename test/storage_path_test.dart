import 'package:flutter_test/flutter_test.dart';
import 'package:fitstrong_gym/provider/member_provider.dart';

void main() {
  group('MemberProvider.storagePathFromUrl', () {
    test('pulls the bucket path out of a public photo url', () {
      const url =
          'https://abc.supabase.co/storage/v1/object/public/fitstrong%20photos/uploads/member_photos/uid123/photo.jpg';
      expect(
        MemberProvider.storagePathFromUrl(url),
        'uploads/member_photos/uid123/photo.jpg',
      );
    });

    test('returns null for an empty url', () {
      expect(MemberProvider.storagePathFromUrl(''), isNull);
    });

    test('returns null for a url that is not one of our uploads', () {
      expect(
        MemberProvider.storagePathFromUrl('https://example.com/some/photo.jpg'),
        isNull,
      );
    });

    test('returns null when the bucket name is the last segment', () {
      expect(
        MemberProvider.storagePathFromUrl(
            'https://abc.supabase.co/storage/v1/object/public/fitstrong%20photos'),
        isNull,
      );
    });
  });
}
