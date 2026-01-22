import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/view/map/notification_service.dart';
import 'package:table_now_app/view/map_google/map_screen.dart';

class Screen extends ConsumerStatefulWidget {
  const Screen({super.key});

  @override
  ConsumerState<Screen> createState() => _ScreenState();
}

class _ScreenState extends ConsumerState<Screen> {
  DestinationArguments? _destination;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _destination =
          ModalRoute.of(context)?.settings.arguments
              as DestinationArguments?;
      _loaded = true;

      if (_destination != null) {
        NotificationService().show(
          title: '길찾기 시작',
          body: '${_destination!.name ?? "목적지"}로 이동합니다',
        );
      }
    }
  }

  /// 목적지 도착 임박 체크 예시
  void _checkArrival(double distanceMeter) {
    if (distanceMeter < 100) {
      NotificationService().show(
        title: '도착 임박',
        body: '${_destination?.name ?? "목적지"}까지 100m 남았습니다',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_destination == null) {
      return const Scaffold(
        body: Center(child: Text('목적지가 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('길찾기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '목적지: ${_destination!.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 테스트용: 도착 임박 알림
                _checkArrival(80);
              },
              child: const Text('도착 임박 알림 테스트'),
            ),
          ],
        ),
      ),
    );
  }
}
