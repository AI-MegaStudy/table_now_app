import 'package:flutter/material.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/map/map_google/destination_input_screen.dart';
import 'package:table_now_app/view/map/map_google/map_screen.dart';
import 'package:table_now_app/view/reservepage/reserve_page01.dart';

class DestinationArguments {
  final double latitude;

  final double longitude;

  final String? name;

  DestinationArguments({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  factory DestinationArguments.fromMap(
    Map<String, dynamic> map,
  ) {
    return DestinationArguments(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (name != null) 'name': name,
    };
  }
}

class StoreDetailSheet extends StatelessWidget {
  final Store store;
  final String? distance;

  const StoreDetailSheet(
    this.store, {
    super.key,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
      ' [StoreDetailSheet] 받은 distance: $distance',
    );
    final p = context.palette;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.store_description ?? "매장 이름 없음",
            style: mainLargeTitleStyle.copyWith(
              color: p.primary,
            ),
          ),
          SizedBox(height: 12),
          if (distance != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.near_me,
                    size: 18,
                    color: p.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "내 위치에서 $distance",
                    style: mainBodyTextStyle.copyWith(
                      color: p.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          _buildInfoRow(
            context,
            Icons.location_on_outlined,
            store.store_address,
          ),
          _buildInfoRow(
            context,
            Icons.phone_outlined,
            store.store_phone,
          ),
          _buildInfoRow(
            context,
            Icons.access_time_outlined,
            "${store.store_open_time ?? "-"} ~ ${store.store_close_time ?? "-"}",
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    CustomNavigationUtil.to(
                      context,
                      const ReservePage01(),
                      settings: RouteSettings(
                        arguments: {
                          'store_seq': store.store_seq,
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: Text("매장 예약"),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _onFindRoute(context);
                  },
                  icon: Icon(Icons.directions),
                  label: Text("길찾기"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: p.textSecondary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: mainBodyTextStyle.copyWith(
                color: p.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //----------------Function ----------------
  void _onFindRoute(BuildContext context) {
    CustomNavigationUtil.to(
      context,
      const MapScreen(),
      settings: RouteSettings(
        arguments: DestinationArguments(
          latitude: store.store_lat,
          longitude: store.store_lng,
          name:
              store.store_description ??
              store.store_address,
        ),
      ),
    );
  }

  //--------------------------------------------
}
