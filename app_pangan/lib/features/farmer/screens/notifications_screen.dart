import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pangan_sliver_header.dart';

/// Halaman Notifikasi
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            PanganSliverHeaderSimple(
              expandedHeight: 130,
              collapsedTitle: 'Notifikasi',
              expandedContent: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Notifikasi',
                  style: AppTheme.poppins(
                    fontSize: 24,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList.separated(
                itemCount: _notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _NotificationTile(notification: _notifications[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notification {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color iconColor;

  const _Notification({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
  });
}

final _notifications = [
  _Notification(
    title: 'Harga Cabai Naik',
    message: 'Harga cabai merah keriting naik 15% di Pasar Induk Kramat Jati',
    time: '2 jam lalu',
    icon: Icons.trending_up_rounded,
    iconColor: AppTheme.statusDanger,
  ),
  _Notification(
    title: 'Cuaca Ekstrem',
    message: 'Prakiraan hujan lebat 3 hari ke depan. Siapkan drainase lahan.',
    time: '5 jam lalu',
    icon: Icons.cloud_rounded,
    iconColor: AppTheme.statusWarning,
  ),
  _Notification(
    title: 'Panen Siap Jual',
    message: 'Hasil panen cabai Anda 200kg sudah dicatat. Siap dijual?',
    time: '1 hari lalu',
    isRead: true,
    icon: Icons.inventory_2_rounded,
    iconColor: AppTheme.brandPrimary,
  ),
  _Notification(
    title: 'Pengingat Pupuk',
    message: 'Jadwal pupuk kandang minggu ini. Jangan lupa beli pupuk organik.',
    time: '2 hari lalu',
    isRead: true,
    icon: Icons.schedule_rounded,
    iconColor: AppTheme.statusInfo,
  ),
  _Notification(
    title: 'Promo Pupuk Subsidi',
    message: 'Pupuk urea subsidi tersedia di kios resmi terdekat. Stok terbatas.',
    time: '3 hari lalu',
    isRead: true,
    icon: Icons.local_offer_rounded,
    iconColor: AppTheme.brandSecondary,
  ),
];

class _NotificationTile extends StatelessWidget {
  final _Notification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? AppTheme.surface : AppTheme.brandPrimarySoft.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? AppTheme.neutral200 : AppTheme.brandPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(notification.icon, color: notification.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTheme.poppins(
                          fontSize: 14,
                          weight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Text(
                      notification.time,
                      style: AppTheme.inter(
                        fontSize: 11,
                        color: AppTheme.neutral500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: AppTheme.inter(
                    fontSize: 12,
                    color: notification.isRead ? AppTheme.neutral500 : AppTheme.neutral500,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}