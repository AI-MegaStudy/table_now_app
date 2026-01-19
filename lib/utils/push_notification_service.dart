import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/config.dart';

/// 푸시 알림 발송 서비스
///
/// Flutter 앱에서 백엔드 API를 통해 푸시 알림을 발송하는 유틸리티 클래스입니다.
class PushNotificationService {
  /// 특정 FCM 토큰에 푸시 알림 발송
  ///
  /// [token] FCM 토큰
  /// [title] 알림 제목
  /// [body] 알림 내용
  /// [data] 추가 데이터 (선택사항)
  ///
  /// 반환값: 성공 시 message_id, 실패 시 null
  static Future<String?> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final apiBaseUrl = getApiBaseUrl();
      final url = Uri.parse('$apiBaseUrl/api/debug/push');

      final requestBody = {
        'token': token,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
      };

      if (kDebugMode) {
        print('📤 푸시 알림 발송 중...');
        print('   Token: ${token.substring(0, 20)}...');
        print('   Title: $title');
        print('   Body: $body');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messageId = responseData['message_id'] as String?;

        if (kDebugMode) {
          print('✅ 푸시 알림 발송 성공: $messageId');
        }

        return messageId;
      } else {
        if (kDebugMode) {
          print('❌ 푸시 알림 발송 실패: ${response.statusCode}');
          print('   Response: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 푸시 알림 발송 중 오류 발생: $e');
      }
      return null;
    }
  }

  /// 고객의 모든 기기에 푸시 알림 발송
  ///
  /// [customerSeq] 고객 번호
  /// [title] 알림 제목
  /// [body] 알림 내용
  /// [data] 추가 데이터 (선택사항)
  ///
  /// 반환값: 성공 시 발송된 기기 수, 실패 시 0
  static Future<int> sendToCustomer({
    required int customerSeq,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final apiBaseUrl = getApiBaseUrl();
      final url = Uri.parse('$apiBaseUrl/api/customer/$customerSeq/push');

      final requestBody = {
        'title': title,
        'body': body,
        if (data != null) 'data': data,
      };

      if (kDebugMode) {
        print('📤 고객에게 푸시 알림 발송 중...');
        print('   Customer Seq: $customerSeq');
        print('   Title: $title');
        print('   Body: $body');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final successCount = responseData['success_count'] as int? ?? 0;

        if (kDebugMode) {
          print('✅ 푸시 알림 발송 성공: $successCount개 기기');
        }

        return successCount;
      } else {
        if (kDebugMode) {
          print('❌ 푸시 알림 발송 실패: ${response.statusCode}');
          print('   Response: ${response.body}');
        }
        return 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 푸시 알림 발송 중 오류 발생: $e');
      }
      return 0;
    }
  }
}
