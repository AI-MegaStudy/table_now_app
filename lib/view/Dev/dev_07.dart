// dev_07.dart (작업자: 프로젝트 관리자)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../config.dart';
import '../../config/ui_config.dart';
import '../../model/customer.dart';
import '../../theme/app_colors.dart';
import '../../custom/util/navigation/custom_navigation_util.dart';
import '../../utils/custom_common_util.dart';
import '../auth/auth_screen.dart';
import '../auth/profile_edit_screen.dart';

class Dev_07 extends ConsumerStatefulWidget {
  const Dev_07({super.key});

  @override
  ConsumerState<Dev_07> createState() => _Dev_07State();
}

class _Dev_07State extends ConsumerState<Dev_07> {
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  /// GetStorage에서 회원 정보 로드
  void _loadCustomerData() {
    final storage = GetStorage();
    final customerData = storage.read<Map<String, dynamic>>(storageKeyCustomer);

    if (customerData != null &&
        customerData['customer_name'] != null &&
        customerData['customer_email'] != null) {
      try {
        setState(() {
          _customer = Customer.fromJson(customerData);
        });
      } catch (e) {
        CustomCommonUtil.logError(functionName: '_loadCustomerData', error: e);
        setState(() {
          _customer = null;
        });
      }
    } else {
      setState(() {
        _customer = null;
      });
    }
  }

  /// 로그아웃 처리
  void _handleLogout() {
    final storage = GetStorage();
    storage.remove(storageKeyCustomer);
    _loadCustomerData(); // 화면 재실행
  }

  @override
  void dispose() {
    super.dispose();
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
              '프로젝트 관리자 페이지',
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
                spacing: mainLargeSpacing,
                children: [
                  // 회원 정보 섹션
                  Text(
                    '회원 정보',
                    style: mainTitleStyle.copyWith(color: p.textPrimary),
                  ),
                  if (_customer != null) ...[
                    // 회원 정보가 있는 경우
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
                          Row(
                            children: [
                              Icon(Icons.person, color: p.primary),
                              const SizedBox(width: 8),
                              Text(
                                '이름',
                                style: mainSmallTextStyle.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _customer!.customerName,
                                  style: mainMediumTextStyle.copyWith(
                                    color: p.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.email, color: p.primary),
                              const SizedBox(width: 8),
                              Text(
                                '이메일',
                                style: mainSmallTextStyle.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _customer!.customerEmail,
                                  style: mainMediumTextStyle.copyWith(
                                    color: p.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_customer!.customerPhone != null &&
                              _customer!.customerPhone!.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.phone, color: p.primary),
                                const SizedBox(width: 8),
                                Text(
                                  '전화번호',
                                  style: mainSmallTextStyle.copyWith(
                                    color: p.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _customer!.customerPhone!,
                                    style: mainMediumTextStyle.copyWith(
                                      color: p.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              Icon(
                                _customer!.isGoogleAccount
                                    ? Icons.account_circle
                                    : Icons.lock,
                                color: p.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '계정 타입',
                                style: mainSmallTextStyle.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _customer!.isGoogleAccount
                                      ? '구글 로그인'
                                      : '일반 로그인',
                                  style: mainMediumTextStyle.copyWith(
                                    color: p.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 로그아웃 버튼
                    Center(
                      child: SizedBox(
                        width: mainButtonMaxWidth,
                        height: mainButtonHeight,
                        child: ElevatedButton(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            '로그아웃',
                            style: mainMediumTitleStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 회원 정보 수정 버튼
                    Center(
                      child: SizedBox(
                        width: mainButtonMaxWidth,
                        height: mainButtonHeight,
                        child: ElevatedButton(
                          onPressed: () => _navigateToProfileEdit(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p.primary,
                            foregroundColor: p.textOnPrimary,
                          ),
                          child: Text(
                            '회원 정보 수정',
                            style: mainMediumTitleStyle.copyWith(
                              color: p.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 회원 정보가 없는 경우
                    Container(
                      padding: mainDefaultPadding,
                      decoration: BoxDecoration(
                        color: p.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: p.divider),
                      ),
                      child: Center(
                        child: Text(
                          '회원 정보가 없습니다',
                          style: mainMediumTextStyle.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 인증 관련 페이지
                  Text(
                    '인증 관련',
                    style: mainTitleStyle.copyWith(color: p.textPrimary),
                  ),
                  Center(
                    child: SizedBox(
                      width: mainButtonMaxWidth,
                      height: mainButtonHeight,
                      child: ElevatedButton(
                        onPressed: () => _navigateToAuthScreen(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.primary,
                          foregroundColor: p.textOnPrimary,
                        ),
                        child: Text(
                          '로그인/회원가입 화면',
                          style: mainMediumTitleStyle.copyWith(
                            color: p.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 여기에 추가 페이지 연결 버튼 추가 가능
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //--------Functions ------------

  /// 로그인/회원가입 화면으로 이동
  void _navigateToAuthScreen() async {
    await CustomNavigationUtil.to(context, const AuthScreen());
  }

  /// 회원 정보 수정 화면으로 이동
  /// GetStorage에서 로그인 정보를 확인하여 이동
  void _navigateToProfileEdit() {
    // GetStorage에서 로그인 정보 확인
    final storage = GetStorage();
    final customerData = storage.read<Map<String, dynamic>>(storageKeyCustomer);

    if (customerData == null) {
      // 로그인 정보가 없으면 로그인 화면으로 이동
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        _navigateToAuthScreen();
      }
      return;
    }

    CustomNavigationUtil.to(context, const ProfileEditScreen()).then((result) {
      // 수정 완료 시 처리
      if (result == true && mounted) {
        // 회원 정보 다시 로드
        _loadCustomerData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원 정보가 수정되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  //------------------------------
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 개발 페이지 (dev_07) - 프로젝트 관리자용 개발 페이지
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 프로젝트 관리자용 개발 페이지 생성
//   - GetStorage에서 회원 정보 로드 및 표시 기능 구현
//   - 로그인 화면으로 이동 버튼 추가
//   - 프로필 수정 화면으로 이동 버튼 추가
//   - 로그아웃 기능 구현 (GetStorage에서 customer 키 삭제)
//   - 프로필 수정 후 회원 정보 자동 갱신 기능 구현 (.then() 사용)
//
// 2026-01-15 김택권: GetStorage 키 상수화
//   - 'customer' 문자열을 config.dart의 storageKeyCustomer 상수로 변경
//   - 오타 방지 및 일관성 유지
