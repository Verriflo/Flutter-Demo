import 'package:verriflo_classroom/verriflo_classroom.dart';

/*
 * API Service
 * 
 * Handles all network communication with the Verriflo API.
 * Uses the VerrifloClient from the SDK for standardized communication.
 */
class ApiService {
  /*
   * Initialize a Verriflo client for the given organization.
   */
  static VerrifloClient _getClient(String apiUrl, String orgId) {
    return VerrifloClient(
      baseUrl: apiUrl,
      organizationId: orgId,
      debug: true, // Enable for demo clarity
    );
  }

  /*
   * Join an existing classroom room.
   */
  static Future<JoinResult> joinClassroom({
    required String apiUrl,
    required String orgId,
    required String roomId,
    required String name,
    required String uid,
    Customization customization = const Customization(),
  }) async {
    try {
      final client = _getClient(apiUrl, orgId);
      final response = await client.joinRoom(
        roomId,
        JoinRoomRequest(
          participant: Participant(
            uid: uid,
            name: name,
            role: ParticipantRole.student,
          ),
          customization: customization,
        ),
      );

      return JoinResult.success(response.iframeUrl);
    } on VerrifloException catch (e) {
      return JoinResult.error(e.message);
    } catch (e) {
      return JoinResult.error('Connection error: $e');
    }
  }

  /*
   * Create a new classroom room and join as a teacher.
   */
  static Future<JoinResult> createClassroom({
    required String apiUrl,
    required String orgId,
    required String roomId,
    required String title,
    required String name,
    required String uid,
    Customization customization = const Customization(),
  }) async {
    try {
      final client = _getClient(apiUrl, orgId);
      final response = await client.createRoom(
        CreateRoomRequest(
          roomId: roomId,
          title: title,
          participant: Participant(
            uid: uid,
            name: name,
            role: ParticipantRole.teacher,
          ),
          customization: customization,
        ),
      );

      return JoinResult.success(response.iframeUrl);
    } on VerrifloException catch (e) {
      return JoinResult.error(e.message);
    } catch (e) {
      return JoinResult.error('Connection error: $e');
    }
  }
}

/*
 * Result wrapper for classroom operations.
 * Either contains a successful iframe URL or an error message.
 */
class JoinResult {
  final bool success;
  final String? iframeUrl;
  final String? error;

  JoinResult._({
    required this.success,
    this.iframeUrl,
    this.error,
  });

  factory JoinResult.success(String iframeUrl) {
    return JoinResult._(success: true, iframeUrl: iframeUrl);
  }

  factory JoinResult.error(String message) {
    return JoinResult._(success: false, error: message);
  }
}
