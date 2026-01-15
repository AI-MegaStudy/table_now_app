/// Customer 모델 클래스
///
/// 고객 정보를 담는 모델입니다.
/// GetStorage에 저장/불러오기 시 JSON 직렬화/역직렬화를 지원합니다.
class Customer {
  final int customerSeq;
  final String customerName;
  final String? customerPhone;
  final String customerEmail;
  final String? customerPw; // 저장하지 않음 (보안)
  final String? createdAt;
  final String provider; // 'local' 또는 'google'
  final String? providerSubject; // 구글 ID (구글 계정인 경우)

  Customer({
    required this.customerSeq,
    required this.customerName,
    this.customerPhone,
    required this.customerEmail,
    this.customerPw,
    this.createdAt,
    required this.provider,
    this.providerSubject,
  });

  /// JSON으로 변환 (GetStorage 저장용)
  Map<String, dynamic> toJson() {
    return {
      'customer_seq': customerSeq,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'created_at': createdAt,
      'provider': provider,
      'provider_subject': providerSubject,
      // customer_pw는 보안상 저장하지 않음
    };
  }

  /// JSON에서 Customer 객체 생성
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerSeq: json['customer_seq'] as int,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String,
      customerPw: null, // 저장하지 않으므로 항상 null
      createdAt: json['created_at'] as String?,
      provider: json['provider'] as String? ?? 'local',
      providerSubject: json['provider_subject'] as String?,
    );
  }

  /// Customer 객체 복사 (일부 필드만 변경)
  Customer copyWith({
    int? customerSeq,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerPw,
    String? createdAt,
    String? provider,
    String? providerSubject,
  }) {
    return Customer(
      customerSeq: customerSeq ?? this.customerSeq,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPw: customerPw ?? this.customerPw,
      createdAt: createdAt ?? this.createdAt,
      provider: provider ?? this.provider,
      providerSubject: providerSubject ?? this.providerSubject,
    );
  }

  /// 구글 계정인지 확인
  bool get isGoogleAccount => provider == 'google';

  /// 로컬 계정인지 확인
  bool get isLocalAccount => provider == 'local';
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: Customer 모델 클래스 - 고객 정보를 담는 모델, GetStorage 저장/불러오기 지원
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - Customer 클래스 생성 (customer_model.dart에서 customer.dart로 이름 변경)
//   - provider 및 provider_subject 필드 추가 (소셜 로그인 지원)
//   - customerPhone, customerPw를 nullable로 변경
//   - toJson, fromJson 메서드 구현 (GetStorage 저장/불러오기)
//   - copyWith 메서드 구현
//   - isGoogleAccount, isLocalAccount getter 추가
