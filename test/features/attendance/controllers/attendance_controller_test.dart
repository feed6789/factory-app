// test/features/attendance/controllers/attendance_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ung_dung_nm/core/services/sync_service.dart';
import 'package:ung_dung_nm/features/attendance/controllers/attendance_controller.dart';
import 'package:ung_dung_nm/features/attendance/repositories/attendance_repository.dart';

// Mock các dependency
class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class MockSyncService extends Mock implements SyncService {}

void main() {
  group('AttendanceController', () {
    late ProviderContainer container;
    late MockAttendanceRepository mockRepo;
    late MockSyncService mockSync;

    setUp(() {
      mockRepo = MockAttendanceRepository();
      mockSync = MockSyncService();

      container = ProviderContainer(
        overrides: [
          attendanceRepositoryProvider.overrideWithValue(mockRepo),
          syncServiceProvider.overrideWithValue(mockSync),
        ],
      );
    });

    test('submitData - online success', () async {
      // Arrange
      when(() => mockSync.hasNetwork()).thenAnswer((_) async => true);
      when(() => mockRepo.upsertTimesheets(any())).thenAnswer((_) async => {});

      // Act
      final result = await container
          .read(attendanceControllerProvider.notifier)
          .submitData('user123');

      // Assert
      expect(result, 'online_success');
      verify(() => mockRepo.upsertTimesheets(any())).called(1);
      verifyNever(() => mockSync.saveOfflineTimesheets(any()));
    });

    test('submitData - offline saves to local', () async {
      // Arrange
      when(() => mockSync.hasNetwork()).thenAnswer((_) async => false);

      // Act
      final result = await container
          .read(attendanceControllerProvider.notifier)
          .submitData('user123');

      // Assert
      expect(result, 'offline_saved');
      verify(() => mockSync.saveOfflineTimesheets(any())).called(1);
    });
  });
}
