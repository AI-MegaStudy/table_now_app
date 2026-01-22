/// 예약 유효성 검사 유틸리티 클래스
/// 
/// 주요 기능:
/// 1. 동일 인물의 동일 시간 예약 방지
/// 2. 이미 예약된 테이블 선택 방지
/// 
/// 사용법:
/// ```dart
/// // 동일 인물 예약 체크
/// final hasReservation = ReservationValidator.hasCustomerReservation(
///   customerReservations: customerReservations,
///   date: '2025-01-15',
///   time: '12:00',
/// );
/// 
/// // 테이블 예약 체크
/// final isReserved = ReservationValidator.isTableReserved(
///   tablesData: tablesData,
///   date: '2025-01-15',
///   time: '12:00',
///   tableSeq: '1',
/// );
/// ```
class ReservationValidator {
  
  /// 해당 고객이 특정 날짜/시간에 이미 예약이 있는지 확인
  /// 
  /// [customerReservations] - 고객의 예약 목록 (Map<날짜, List<시간>>)
  /// [date] - 확인할 날짜 (예: '2025-01-15')
  /// [time] - 확인할 시간 (예: '12:00')
  /// 
  /// Returns: 이미 예약이 있으면 true
  static bool hasCustomerReservation({
    required Map<String, List<String>> customerReservations,
    required String date,
    required String time,
  }) {
    final times = customerReservations[date];
    if (times == null || times.isEmpty) {
      return false;
    }
    return times.contains(time);
  }

  /// 해당 시간에 테이블이 이미 예약되었는지 확인
  /// 
  /// [tablesData] - 전체 예약 데이터 (Map<날짜, Map<시간, Map<테이블seq, 정보>>>)
  /// [date] - 확인할 날짜 (예: '2025-01-15')
  /// [time] - 확인할 시간 (예: '12:00')
  /// [tableSeq] - 확인할 테이블 시퀀스 (예: '1')
  /// 
  /// Returns: 이미 예약되었으면 true
  static bool isTableReserved({
    required Map<String, dynamic> tablesData,
    required String date,
    required String time,
    required String tableSeq,
  }) {
    final dateData = tablesData[date];
    if (dateData == null) return false;
    
    final timeData = dateData[time];
    if (timeData == null) return false;
    
    return (timeData as Map).containsKey(tableSeq);
  }

  /// 해당 시간에 예약된 테이블 목록 반환
  /// 
  /// [tablesData] - 전체 예약 데이터
  /// [date] - 확인할 날짜
  /// [time] - 확인할 시간
  /// 
  /// Returns: 예약된 테이블 시퀀스 목록
  static List<String> getReservedTableSeqs({
    required Map<String, dynamic> tablesData,
    required String date,
    required String time,
  }) {
    final dateData = tablesData[date];
    if (dateData == null) return [];
    
    final timeData = dateData[time];
    if (timeData == null) return [];
    
    return (timeData as Map).keys.cast<String>().toList();
  }

  /// 고객의 예약 목록에서 특정 날짜의 예약 시간들 반환
  /// 
  /// [customerReservations] - 고객의 예약 목록
  /// [date] - 확인할 날짜
  /// 
  /// Returns: 해당 날짜에 예약된 시간 목록
  static List<String> getCustomerReservedTimes({
    required Map<String, List<String>> customerReservations,
    required String date,
  }) {
    return customerReservations[date] ?? [];
  }
}
