import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('https://admin.afritradepay.com/api/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _notifications = List<Map<String, dynamic>>.from(data['data'] ?? []);
            _unreadCount = data['meta']?['unread_count'] ?? 0;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Notification Error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markAsRead(int id) async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('https://admin.afritradepay.com/api/notifications/$id/read'),
        headers: headers,
      );
      _loadNotifications();
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('https://admin.afritradepay.com/api/notifications/mark-all-read'),
        headers: headers,
      );
      _loadNotifications();
    } catch (e) {
      debugPrint('Mark all as read error: $e');
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'transaction': return Icons.swap_horiz;
      case 'kyc': return Icons.verified_user;
      case 'security': return Icons.security;
      case 'promo': return Icons.local_offer;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'transaction': return Colors.blue;
      case 'kyc': return Colors.purple;
      case 'security': return Colors.red;
      case 'promo': return Colors.amber;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Notifications", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_unreadCount', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
              ),
            ]
          ],
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text("Mark all read", style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 12)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) => _buildNotificationItem(_notifications[index], index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text("No notifications yet", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 18)),
          const SizedBox(height: 8),
          Text("You're all caught up!", style: GoogleFonts.outfit(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final isRead = notification['is_read'] == true;
    final type = notification['type'] ?? 'default';
    final createdAt = DateTime.tryParse(notification['created_at'] ?? '') ?? DateTime.now();

    return FadeInUp(
      delay: Duration(milliseconds: index * 30),
      child: Dismissible(
        key: Key(notification['id'].toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) async {
          final headers = await _getHeaders();
          await http.delete(
            Uri.parse('https://admin.afritradepay.com/api/notifications/${notification['id']}'),
            headers: headers,
          );
        },
        child: GestureDetector(
          onTap: () {
            if (!isRead) {
              _markAsRead(notification['id']);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? AppColors.surface : AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRead ? AppColors.glassBorder : _getColorForType(type).withOpacity(0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: _getColorForType(type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIconForType(type), color: _getColorForType(type), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? '',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] ?? '',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeago.format(createdAt),
                        style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
