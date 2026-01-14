import 'package:flutter/material.dart';

/// 색상 이름 텍스트를 Flutter Color로 변환하는 유틸리티 함수
/// 
/// 이미지 파일명이나 다른 곳에서 추출한 색상 이름(예: 'Black', 'White', 'Red' 등)을
/// 실제 Material Color로 변환합니다.
/// 
/// [colorText] 색상 이름 텍스트 (대소문자 무관)
/// [isSelected] 선택된 상태인지 여부 (선택 시 더 진한 색상 반환)
/// 
/// Returns: Color 객체 (매칭되는 색상이 없으면 회색 반환)
Color colorNameToColor(String colorText, {bool isSelected = false}) {
  if (colorText.isEmpty) {
    return isSelected ? Colors.grey[700]! : Colors.grey.withOpacity(0.6);
  }
  
  // 소문자로 변환하여 비교 (대소문자 무관)
  String lowerColor = colorText.toLowerCase().trim();
  
  // 선택된 상태일 때는 더 진한 색상, 아닐 때는 투명도 적용
  double opacity = isSelected ? 1.0 : 0.6;
  
  // 색상 매핑
  // 데이터베이스 color_category 테이블에 있는 색상: 블랙, 화이트, 그레이, 레드, 블루, 그린, 옐로우
  if (lowerColor.contains('black') || lowerColor.contains('블랙') || lowerColor.contains('검은') || lowerColor.contains('검정')) {
    return Colors.black.withOpacity(opacity);
  } else if (lowerColor.contains('white') || lowerColor.contains('화이트') || lowerColor.contains('흰')) {
    return Colors.white.withOpacity(opacity);
  } else if (lowerColor.contains('gray') || lowerColor.contains('grey') || 
             lowerColor.contains('그레이') || lowerColor.contains('회색')) {
    return Colors.grey.withOpacity(opacity);
  } else if (lowerColor.contains('red') || lowerColor.contains('레드') || lowerColor.contains('빨간') || lowerColor.contains('빨강')) {
    return Colors.red.withOpacity(opacity);
  } else if (lowerColor.contains('blue') || lowerColor.contains('블루') || lowerColor.contains('파란') || lowerColor.contains('파랑')) {
    return Colors.blue.withOpacity(opacity);
  } else if (lowerColor.contains('green') || lowerColor.contains('그린') || lowerColor.contains('초록') || lowerColor.contains('녹색')) {
    return Colors.green.withOpacity(opacity);
  } else if (lowerColor.contains('yellow') || lowerColor.contains('옐로우') || lowerColor.contains('노란') || lowerColor.contains('노랑')) {
    return Colors.yellow.withOpacity(opacity);
  } else if (lowerColor.contains('orange') || lowerColor.contains('주황') || lowerColor.contains('오렌지')) {
    return Colors.orange.withOpacity(opacity);
  } else if (lowerColor.contains('purple') || lowerColor.contains('보라') || lowerColor.contains('퍼플') || lowerColor.contains('바이올렛')) {
    return Colors.purple.withOpacity(opacity);
  } else if (lowerColor.contains('pink') || lowerColor.contains('분홍') || lowerColor.contains('핑크')) {
    return Colors.pink.withOpacity(opacity);
  } else if (lowerColor.contains('brown') || lowerColor.contains('갈색') || lowerColor.contains('브라운')) {
    return Colors.brown.withOpacity(opacity);
  } else if (lowerColor.contains('cyan') || lowerColor.contains('청록') || lowerColor.contains('시안')) {
    return Colors.cyan.withOpacity(opacity);
  } else if (lowerColor.contains('teal') || lowerColor.contains('틸')) {
    return Colors.teal.withOpacity(opacity);
  } else if (lowerColor.contains('indigo') || lowerColor.contains('남색') || lowerColor.contains('인디고')) {
    return Colors.indigo.withOpacity(opacity);
  } else if (lowerColor.contains('amber') || lowerColor.contains('호박') || lowerColor.contains('앰버')) {
    return Colors.amber.withOpacity(opacity);
  } else if (lowerColor.contains('lime') || lowerColor.contains('라임')) {
    return Colors.lime.withOpacity(opacity);
  } else if (lowerColor.contains('lightblue') || lowerColor.contains('라이트블루') || lowerColor.contains('연한파랑')) {
    return Colors.lightBlue.withOpacity(opacity);
  } else if (lowerColor.contains('lightgreen') || lowerColor.contains('라이트그린') || lowerColor.contains('연한초록')) {
    return Colors.lightGreen.withOpacity(opacity);
  } else if (lowerColor.contains('deeporange') || lowerColor.contains('딥오렌지')) {
    return Colors.deepOrange.withOpacity(opacity);
  } else if (lowerColor.contains('deeppurple') || lowerColor.contains('딥퍼플')) {
    return Colors.deepPurple.withOpacity(opacity);
  } else if (lowerColor.contains('deepgreen') || lowerColor.contains('딥그린')) {
    return Colors.green.shade700.withOpacity(opacity);
  } else if (lowerColor.contains('navy') || lowerColor.contains('네이비')) {
    return Colors.blue.shade900.withOpacity(opacity);
  } else if (lowerColor.contains('beige') || lowerColor.contains('베이지')) {
    return const Color(0xFFF5F5DC).withOpacity(opacity);
  } else if (lowerColor.contains('khaki') || lowerColor.contains('카키')) {
    return const Color(0xFFC3B091).withOpacity(opacity);
  } else if (lowerColor.contains('olive') || lowerColor.contains('올리브')) {
    return const Color(0xFF808000).withOpacity(opacity); // 올리브 색상
  } else if (lowerColor.contains('maroon') || lowerColor.contains('마룬') || lowerColor.contains('적갈색')) {
    return const Color(0xFF800000).withOpacity(opacity);
  } else if (lowerColor.contains('turquoise') || lowerColor.contains('터키석') || lowerColor.contains('터콰이즈')) {
    return Colors.teal.shade300.withOpacity(opacity);
  } else if (lowerColor.contains('silver') || lowerColor.contains('은색') || lowerColor.contains('실버')) {
    return Colors.grey.shade400.withOpacity(opacity);
  } else if (lowerColor.contains('gold') || lowerColor.contains('금색') || lowerColor.contains('골드')) {
    return const Color(0xFFFFD700).withOpacity(opacity);
  }
  
  // 매칭되는 색상이 없으면 회색 반환
  return isSelected ? Colors.grey[700]! : Colors.grey.withOpacity(0.6);
}

