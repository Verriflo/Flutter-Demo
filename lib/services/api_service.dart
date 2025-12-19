import 'dart:convert';
import 'package:http/http.dart' as http;

/*
 * API Service
 * 
 * Handles all network communication with the Verriflo API.
 * Currently supports joining classrooms via the SDK join endpoint.
 */
class ApiService {
  /*
   * Join a classroom and retrieve the streaming URL.
   * 
   * Makes a POST request to /v1/live/sdk/join with organization context.
   * Returns JoinResult with either a join URL on success or error message.
   * 
   * Parameters:
   * - apiUrl: Base API URL (e.g., https://api.verriflo.com)
   * - orgId: Organization identifier from dashboard
   * - roomId: Classroom room identifier
   * - name: Display name for the participant
   * - email: Participant email (used as identity)
   */
  static Future<JoinResult> joinClassroom({
    required String apiUrl,
    required String orgId,
    required String roomId,
    required String name,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/live/sdk/join'),
        headers: {
          'Content-Type': 'application/json',
          'VF-ORG-ID': orgId,
        },
        body: jsonEncode({
          'roomId': roomId,
          'name': name,
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        // Extract error message from response
        final message = data['message'] ?? 'Request failed (${response.statusCode})';
        return JoinResult.error(message);
      }

      // Extract token
      final token = data['data']?['streamToken'];
      if (token == null) {
        return JoinResult.error('Invalid response: missing token');
      }

      return JoinResult.success(token);
    } on FormatException {
      return JoinResult.error('Invalid response format');
    } catch (e) {
      return JoinResult.error('Network error: ${e.toString()}');
    }
  }
}

/*
 * Result wrapper for join operation.
 * Either contains a successful join URL or an error message.
 */
class JoinResult {
  final bool success;
  final String? token;
  final String? error;

  JoinResult._({
    required this.success,
    this.token,
    this.error,
  });

  factory JoinResult.success(String token) {
    return JoinResult._(success: true, token: token);
  }

  factory JoinResult.error(String message) {
    return JoinResult._(success: false, error: message);
  }
}
