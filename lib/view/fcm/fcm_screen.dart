// fcm_screen.dart
// FCM 테스트 및 푸시 알림 발송 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';
import '../../vm/fcm_notifier.dart';
import '../../utils/push_notification_service.dart';
import '../../config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmScreen extends ConsumerStatefulWidget {
  const FcmScreen({super.key});

  @override
  ConsumerState<FcmScreen> createState() => _FcmScreenState();
}

class _FcmScreenState extends ConsumerState<FcmScreen> {
  // 고객 리스트 관련 상태
  List<Map<String, dynamic>> _customersWithFcmToken = [];
  int? _selectedCustomerSeq;
  bool _isLoadingCustomers = false;

  @override
  void initState() {
    super.initState();
    _loadCustomersWithFcmToken();
  }

  /// FCM 토큰이 등록된 고객 리스트 불러오기
  Future<void> _loadCustomersWithFcmToken() async {
    setState(() {
      _isLoadingCustomers = true;
    });

    try {
      final apiBaseUrl = getApiBaseUrl();
      final url = Uri.parse('$apiBaseUrl/api/customer/with-fcm-token');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['result'] == 'OK') {
          setState(() {
            _customersWithFcmToken = List<Map<String, dynamic>>.from(
              responseData['results'] ?? [],
            );
            _isLoadingCustomers = false;
          });
        } else {
          setState(() {
            _customersWithFcmToken = [];
            _isLoadingCustomers = false;
          });
        }
      } else {
        setState(() {
          _customersWithFcmToken = [];
          _isLoadingCustomers = false;
        });
      }
    } catch (e) {
      setState(() {
        _customersWithFcmToken = [];
        _isLoadingCustomers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              'FCM 테스트',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: mainDefaultSpacing,
                children: [
                  // FCM 테스트 섹션
                  Text(
                    'FCM 테스트',
                    style: mainTitleStyle.copyWith(color: p.textPrimary),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final fcmState = ref.watch(fcmNotifierProvider);
                      final fcmToken = fcmState.token;
                      final isInitialized = fcmState.isInitialized;
                      final errorMessage = fcmState.errorMessage;

                      return Container(
                        padding: mainDefaultPadding,
                        decoration: BoxDecoration(
                          color: p.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: mainSmallSpacing,
                          children: [
                            // 초기화 상태
                            Row(
                              spacing: 8,
                              children: [
                                Icon(
                                  isInitialized
                                      ? Icons.check_circle
                                      : Icons.error_outline,
                                  color: isInitialized
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                Text(
                                  'FCM 초기화 상태: ${isInitialized ? "완료" : "미완료"}',
                                  style: mainSmallTextStyle.copyWith(
                                    color: isInitialized
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // 에러 메시지 표시
                            if (errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: mainSmallTextStyle.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // FCM 토큰
                            Row(
                              spacing: 8,
                              children: [
                                Icon(Icons.notifications, color: p.primary),
                                Text(
                                  'FCM 토큰',
                                  style: mainSmallTextStyle.copyWith(
                                    color: p.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (fcmToken != null) ...[
                              SelectableText(
                                fcmToken,
                                style: mainSmallTextStyle.copyWith(
                                  color: p.textPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              SizedBox(height: mainDefaultSpacing),
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: mainButtonMaxWidth,
                                      height: mainButtonHeight,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _sendTestPush(fcmToken),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          '포그라운드 테스트 푸시 발송',
                                          style: mainMediumTitleStyle.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: mainSmallSpacing),
                                    SizedBox(
                                      width: mainButtonMaxWidth,
                                      height: mainButtonHeight,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // FCM 토큰 수동 새로고침
                                          await ref
                                              .read(
                                                fcmNotifierProvider.notifier,
                                              )
                                              .refreshToken();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          'FCM 토큰 새로고침',
                                          style: mainMediumTitleStyle.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Text(
                                'FCM 토큰이 없습니다.',
                                style: mainSmallTextStyle.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                              SizedBox(height: mainDefaultSpacing),
                              // 에러 메시지가 있으면 설정 안내
                              if (errorMessage != null &&
                                  errorMessage.contains('설정')) ...[
                                Text(
                                  '알림 권한이 필요합니다.\n설정 > TableNow > 알림에서 권한을 활성화하세요.',
                                  style: mainSmallTextStyle.copyWith(
                                    color: Colors.orange,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: mainSmallSpacing),
                              ],
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: mainButtonMaxWidth,
                                      height: mainButtonHeight,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // FCM 초기화 재시도 (권한 확인 포함)
                                          await ref
                                              .read(
                                                fcmNotifierProvider.notifier,
                                              )
                                              .retryInitialization();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: p.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          'FCM 초기화 재시도',
                                          style: mainMediumTitleStyle.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: mainSmallSpacing),
                                    SizedBox(
                                      width: mainButtonMaxWidth,
                                      height: mainButtonHeight,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // FCM 토큰 수동 새로고침
                                          await ref
                                              .read(
                                                fcmNotifierProvider.notifier,
                                              )
                                              .refreshToken();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          'FCM 토큰 새로고침',
                                          style: mainMediumTitleStyle.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  // 푸시 알림 발송 예시 섹션
                  Text(
                    '푸시 알림 발송 예시',
                    style: mainTitleStyle.copyWith(color: p.textPrimary),
                  ),
                  Container(
                    padding: mainDefaultPadding,
                    decoration: BoxDecoration(
                      color: p.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: mainSmallSpacing,
                      children: [
                        // 고객 선택 Dropdown
                        Row(
                          spacing: 8,
                          children: [
                            Icon(Icons.person, color: p.primary),
                            Text(
                              '고객 선택',
                              style: mainSmallTextStyle.copyWith(
                                color: p.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (_isLoadingCustomers) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ] else if (_customersWithFcmToken.isEmpty) ...[
                          Text(
                            'FCM 토큰이 등록된 고객이 없습니다.',
                            style: mainSmallTextStyle.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                          SizedBox(height: mainSmallSpacing),
                          SizedBox(
                            width: double.infinity,
                            height: mainButtonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _loadCustomersWithFcmToken,
                              icon: const Icon(Icons.refresh),
                              label: const Text('새로고침'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: p.primary,
                                foregroundColor: p.textOnPrimary,
                              ),
                            ),
                          ),
                        ] else ...[
                          DropdownButtonFormField<int>(
                            initialValue: _selectedCustomerSeq,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: Text(
                              '고객을 선택하세요',
                              style: mainSmallTextStyle.copyWith(
                                color: p.textSecondary,
                              ),
                            ),
                            items: _customersWithFcmToken.map((customer) {
                              final customerSeq =
                                  customer['customer_seq'] as int;
                              final customerName =
                                  customer['customer_name'] as String? ??
                                  '이름 없음';
                              final customerEmail =
                                  customer['customer_email'] as String? ?? '';
                              final deviceCount =
                                  customer['device_count'] as int? ?? 0;

                              return DropdownMenuItem<int>(
                                value: customerSeq,
                                child: Text(
                                  '$customerName ($customerEmail) - $deviceCount개 기기',
                                  style: mainSmallTextStyle.copyWith(
                                    color: p.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCustomerSeq = value;
                              });
                            },
                          ),
                          SizedBox(height: mainDefaultSpacing),

                          // 선택한 고객에게 알림 발송 버튼
                          SizedBox(
                            width: double.infinity,
                            height: mainButtonHeight,
                            child: ElevatedButton(
                              onPressed: _selectedCustomerSeq != null
                                  ? () => _sendPushToSelectedCustomer()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                '선택한 고객에게 알림 발송',
                                style: mainMediumTitleStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: mainSmallSpacing),

                          // 전체 고객에게 알림 발송 버튼
                          SizedBox(
                            width: double.infinity,
                            height: mainButtonHeight,
                            child: ElevatedButton(
                              onPressed: _customersWithFcmToken.isNotEmpty
                                  ? () => _sendPushToAllCustomers()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                '전체 고객에게 알림 발송',
                                style: mainMediumTitleStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: mainSmallSpacing),

                          // 시나리오별 예시 버튼들
                          Text(
                            '시나리오별 예시',
                            style: mainSmallTextStyle.copyWith(
                              color: p.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: mainButtonHeight,
                            child: ElevatedButton(
                              onPressed: _selectedCustomerSeq != null
                                  ? () => _sendReservationCompleteScenario()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                '예약 완료 시나리오',
                                style: mainMediumTitleStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: mainSmallSpacing),
                          SizedBox(
                            width: double.infinity,
                            height: mainButtonHeight,
                            child: ElevatedButton(
                              onPressed: _selectedCustomerSeq != null
                                  ? () => _sendReservationCancelledScenario()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                '예약 취소 시나리오',
                                style: mainMediumTitleStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 테스트 푸시 발송
  Future<void> _sendTestPush(String token) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시 발송 중...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // PushNotificationService를 사용하여 푸시 알림 발송
    final messageId = await PushNotificationService.sendToToken(
      token: token,
      title: '포그라운드 테스트 알림',
      body: '앱이 포그라운드에 있을 때 로컬 알림이 표시됩니다.',
      data: {
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
        'message': '이것은 포그라운드 테스트 메시지입니다.',
      },
    );

    if (mounted) {
      if (messageId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('푸시 발송 성공!\nmessage_id: $messageId'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('푸시 발송 실패'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 선택한 고객에게 푸시 알림 발송
  Future<void> _sendPushToSelectedCustomer() async {
    if (_selectedCustomerSeq == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('고객을 선택해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시 발송 중...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // await로 순차 처리하여 네트워크 충돌 방지
    final successCount = await PushNotificationService.sendToCustomer(
      customerSeq: _selectedCustomerSeq!,
      title: '테스트 알림',
      body: '선택한 고객에게 발송된 테스트 알림입니다.',
      data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
    );

    if (mounted) {
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('푸시 발송 성공! $successCount개 기기에 발송되었습니다.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('푸시 발송 실패'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 전체 고객에게 푸시 알림 발송
  /// await로 순차 처리하여 네트워크 충돌 방지
  Future<void> _sendPushToAllCustomers() async {
    if (_customersWithFcmToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('발송할 고객이 없습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('전체 ${_customersWithFcmToken.length}명에게 푸시 발송 중...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    int totalSuccessCount = 0;
    int totalFailedCount = 0;

    // await로 순차 처리하여 네트워크 충돌 방지
    for (final customer in _customersWithFcmToken) {
      final customerSeq = customer['customer_seq'] as int;

      final successCount = await PushNotificationService.sendToCustomer(
        customerSeq: customerSeq,
        title: '테스트 알림',
        body: '전체 고객에게 발송된 테스트 알림입니다.',
        data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
      );

      if (successCount > 0) {
        totalSuccessCount += successCount;
      } else {
        totalFailedCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '전체 발송 완료!\n성공: ${_customersWithFcmToken.length - totalFailedCount}명 ($totalSuccessCount개 기기)\n실패: $totalFailedCount명',
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: totalFailedCount == 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  /// 예약 완료 시나리오 푸시 발송
  Future<void> _sendReservationCompleteScenario() async {
    if (_selectedCustomerSeq == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시 발송 중...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    final successCount = await PushNotificationService.sendToCustomer(
      customerSeq: _selectedCustomerSeq!,
      title: '예약 완료',
      body: '예약이 완료되었습니다.',
      data: {
        'type': 'reservation_complete',
        'reserve_seq': '123',
        'screen': 'reservation_detail',
      },
    );

    if (mounted) {
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예약 완료 알림 발송 성공! $successCount개 기기'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('푸시 발송 실패'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 예약 취소 시나리오 푸시 발송
  Future<void> _sendReservationCancelledScenario() async {
    if (_selectedCustomerSeq == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시 발송 중...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    final successCount = await PushNotificationService.sendToCustomer(
      customerSeq: _selectedCustomerSeq!,
      title: '예약 취소',
      body: '예약이 취소되었습니다.',
      data: {
        'type': 'reservation_cancelled',
        'reserve_seq': '123',
        'screen': 'reservation_list',
      },
    );

    if (mounted) {
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예약 취소 알림 발송 성공! $successCount개 기기'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('푸시 발송 실패'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
