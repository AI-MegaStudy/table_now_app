import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/app_colors.dart';

class DevFirebaseTest extends StatefulWidget {
  const DevFirebaseTest({super.key});

  @override
  State<DevFirebaseTest> createState() => _DevFirebaseTestState();
}

class _DevFirebaseTestState extends State<DevFirebaseTest> {
  String _status = '테스트 준비 중...';
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseInit();
  }

  // Firebase 초기화 확인
  void _checkFirebaseInit() {
    try {
      final app = Firebase.app();
      setState(() {
        _status = '✅ Firebase 초기화 성공!';
        _result =
            '프로젝트 ID: ${app.options.projectId}\n'
            '앱 이름: ${app.name}';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase 초기화 실패';
        _result = '오류: $e';
      });
    }
  }

  // Firestore 쓰기 테스트
  Future<void> _testFirestoreWrite() async {
    setState(() {
      _isLoading = true;
      _status = 'Firestore 쓰기 테스트 중...';
      _result = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final timestamp = DateTime.now();

      await firestore.collection('test').doc('connection_test').set({
        'message': 'Firebase 연결 테스트',
        'timestamp': timestamp.toIso8601String(),
        'platform': 'Flutter',
      });

      setState(() {
        _status = '✅ Firestore 쓰기 성공!';
        _result =
            '데이터가 성공적으로 저장되었습니다.\n'
            '시간: ${timestamp.toString()}';
      });
    } catch (e) {
      String errorMessage = '오류: $e';
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission-denied')) {
        errorMessage =
            'Firestore 권한 오류\n'
            'Firebase 콘솔에서 Firestore Database를 생성하고\n'
            '보안 규칙을 설정해주세요.\n\n'
            '오류: $e';
      } else if (e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('unavailable')) {
        errorMessage =
            'Firestore를 사용할 수 없습니다\n'
            'Firebase 콘솔에서 Firestore Database를 생성해주세요.\n\n'
            '오류: $e';
      }
      setState(() {
        _status = '❌ Firestore 쓰기 실패';
        _result = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Firestore 읽기 테스트
  Future<void> _testFirestoreRead() async {
    setState(() {
      _isLoading = true;
      _status = 'Firestore 읽기 테스트 중...';
      _result = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore
          .collection('test')
          .doc('connection_test')
          .get();

      if (doc.exists) {
        setState(() {
          _status = '✅ Firestore 읽기 성공!';
          _result = '데이터:\n${doc.data()}';
        });
      } else {
        setState(() {
          _status = '⚠️ 데이터 없음';
          _result = '먼저 "Firestore 쓰기 테스트"를 실행하세요.';
        });
      }
    } catch (e) {
      String errorMessage = '오류: $e';
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission-denied')) {
        errorMessage =
            'Firestore 권한 오류\n'
            'Firebase 콘솔에서 Firestore Database를 생성하고\n'
            '보안 규칙을 설정해주세요.\n\n'
            '오류: $e';
      } else if (e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('unavailable')) {
        errorMessage =
            'Firestore를 사용할 수 없습니다\n'
            'Firebase 콘솔에서 Firestore Database를 생성해주세요.\n\n'
            '오류: $e';
      }
      setState(() {
        _status = '❌ Firestore 읽기 실패';
        _result = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
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
              'Firebase 연결 테스트',
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
                children: [
                  const SizedBox(height: mainLargeSpacing),

                  // 상태 표시
                  Container(
                    padding: mainDefaultPadding,
                    decoration: BoxDecoration(
                      color: p.cardBackground,
                      borderRadius: mainDefaultBorderRadius,
                      border: Border.all(color: p.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '현재 상태',
                          style: mainMediumTitleStyle.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: mainSmallSpacing),
                        Text(
                          _status,
                          style: mainMediumTextStyle.copyWith(
                            color: _status.contains('✅')
                                ? Colors.green
                                : _status.contains('❌')
                                ? Colors.red
                                : p.textPrimary,
                          ),
                        ),
                        if (_result.isNotEmpty) ...[
                          const SizedBox(height: mainSmallSpacing),
                          Text(
                            _result,
                            style: mainSmallTextStyle.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: mainLargeSpacing),

                  // 테스트 버튼들
                  SizedBox(
                    width: double.infinity,
                    height: mainButtonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkFirebaseInit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: p.textOnPrimary,
                      ),
                      child: Text(
                        'Firebase 초기화 확인',
                        style: mainMediumTextStyle.copyWith(
                          color: p.textOnPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: mainSmallSpacing),

                  SizedBox(
                    width: double.infinity,
                    height: mainButtonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testFirestoreWrite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: p.textOnPrimary,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  p.textOnPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Firestore 쓰기 테스트',
                              style: mainMediumTextStyle.copyWith(
                                color: p.textOnPrimary,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: mainSmallSpacing),

                  SizedBox(
                    width: double.infinity,
                    height: mainButtonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testFirestoreRead,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: p.textOnPrimary,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  p.textOnPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Firestore 읽기 테스트',
                              style: mainMediumTextStyle.copyWith(
                                color: p.textOnPrimary,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: mainLargeSpacing),

                  // 안내 메시지
                  Container(
                    padding: mainDefaultPadding,
                    decoration: BoxDecoration(
                      color: p.cardBackground,
                      borderRadius: mainDefaultBorderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '테스트 방법',
                          style: mainMediumTitleStyle.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: mainSmallSpacing),
                        Text(
                          '1. "Firebase 초기화 확인" 버튼으로 초기화 상태 확인\n'
                          '2. "Firestore 쓰기 테스트"로 데이터 저장\n'
                          '3. "Firestore 읽기 테스트"로 데이터 읽기\n'
                          '4. Firebase 콘솔에서 데이터 확인',
                          style: mainSmallTextStyle.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
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
}
