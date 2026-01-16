String generateReservationNumber({
  required int reserveSeq,
  required int storeSeq,
  required int customerSeq,
  required int capacity,
  required DateTime dateTime,
}) {
  final mm = dateTime.month.toString().padLeft(2, '0');
  final dd = dateTime.day.toString().padLeft(2, '0');

  return 'CUR'
      '$reserveSeq'
      '$storeSeq'
      '$customerSeq'
      '$mm$dd'
      '$capacity';
}
/// 예약 번호 생성 함수