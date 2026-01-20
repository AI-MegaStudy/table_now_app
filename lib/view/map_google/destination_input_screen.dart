import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';
import '../../vm/store_notifier.dart';
import '../../model/store.dart';
import 'map_screen.dart';

/// 목적지 좌표를 입력받는 화면
class DestinationInputScreen extends ConsumerStatefulWidget {
  const DestinationInputScreen({super.key});

  @override
  ConsumerState<DestinationInputScreen> createState() => _DestinationInputScreenState();
}

class _DestinationInputScreenState extends ConsumerState<DestinationInputScreen> {
  /// 드로워 호출용 글로벌키
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  /// 선택된 Store
  Store? _selectedStore;

  /// 경로 찾기 버튼 클릭 처리
  void _onFindRoute() {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('매장을 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // MapScreen으로 이동 (Route Arguments 사용)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
        settings: RouteSettings(
          arguments: DestinationArguments(
            latitude: _selectedStore!.store_lat,
            longitude: _selectedStore!.store_lng,
            name: _selectedStore!.store_description ?? _selectedStore!.store_address,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: p.background,
          drawer: const ProfileDrawer(),
          appBar: CommonAppBar(
            title: Text(
              '목적지 입력',
              style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: p.textOnPrimary,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: mainDefaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목
                Text(
                  '목적지 매장 선택',
                  style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '매장을 선택하면 해당 매장으로의 경로를 찾을 수 있습니다.',
                  style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                ),
                const SizedBox(height: 24),

                // Store 목록 가져오기
                ref.watch(storeNotifierProvider).when(
                  data: (stores) {
                    if (stores.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '등록된 매장이 없습니다.',
                          style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 매장 선택 드롭다운
                        DropdownButtonFormField<Store>(
                          initialValue: _selectedStore,
                          isExpanded: true, // 텍스트가 길어도 잘리지 않도록
                          menuMaxHeight: 400, // 드롭다운 메뉴 최대 높이
                          decoration: InputDecoration(
                            labelText: '매장 선택',
                            hintText: '매장을 선택하세요',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.store),
                            filled: true,
                            fillColor: p.cardBackground,
                          ),
                          // 닫힌 상태: 매장명 (주소) 한 줄로 표시
                          selectedItemBuilder: (BuildContext context) {
                            return stores.map<Widget>((Store store) {
                              final name = store.store_description ?? '';
                              final addr = store.store_address;
                              // 매장명과 주소를 한 줄로 결합
                              final displayText = name.isNotEmpty 
                                  ? '$name ($addr)' 
                                  : addr;
                              return Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  displayText,
                                  style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList();
                          },
                          // 메뉴 열린 상태: 두 줄로 표시
                          items: stores.map((store) {
                            return DropdownMenuItem<Store>(
                              value: store,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      store.store_description ?? store.store_address,
                                      style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    if (store.store_address.isNotEmpty)
                                      Text(
                                        store.store_address,
                                        style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Store? value) {
                            setState(() {
                              _selectedStore = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return '매장을 선택해주세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 경로 찾기 버튼
                        ElevatedButton.icon(
                          onPressed: _onFindRoute,
                          icon: const Icon(Icons.directions),
                          label: const Text(
                            '경로 찾기',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p.primary,
                            foregroundColor: p.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          '매장 목록을 불러오는데 실패했습니다.',
                          style: mainBodyTextStyle.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
