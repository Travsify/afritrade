import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_client.dart';
import '../../../auth/data/kyc_provider.dart';
import 'dart:async';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _apiClient = ApiClient();
  
  List<Map<String, dynamic>> _messages = [];
  String? _sessionId;
  String _sessionStatus = 'ai'; // ai, pending_human, human
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      final response = await _apiClient.get('${AppApiConfig.supportChat}?action=init');
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _sessionId = response.data!['session_id'];
            _sessionStatus = response.data!['session_status'] ?? 'ai';
            final msgs = response.data!['messages'] as List?;
            if (msgs != null) {
              _messages = List<Map<String, dynamic>>.from(msgs);
            }
            _isLoading = false;
          });
          _scrollToBottom();
          _startPolling();
        }
      } else {
        _showError("Failed to initialize chat");
      }
    } catch (e) {
      _showError("Connection error: $e");
    }
  }

  void _startPolling() {
    // Poll every 5 seconds for new messages if chatting with human or waiting for one
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_sessionId != null) {
        _fetchHistory(silent: true);
      }
    });
  }

  Future<void> _fetchHistory({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('${AppApiConfig.supportChat}?action=history&session_id=$_sessionId');
      if (response.success && response.data != null) {
        if (mounted) {
          final msgs = response.data!['messages'] as List?;
          final newStatus = response.data!['session_status'] ?? _sessionStatus;
          
          setState(() {
            if (msgs != null) {
              _messages = List<Map<String, dynamic>>.from(msgs);
            }
            _sessionStatus = newStatus;
            if (!silent) _isLoading = false;
          });
          
          if (!silent) _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Polling error: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sessionId == null) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      _isSending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await _apiClient.post(
        AppApiConfig.supportChat,
        body: {
          'action': 'send',
          'session_id': _sessionId,
          'message': text,
        },
      );

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            if (response.data!['messages'] != null) {
              _messages = List<Map<String, dynamic>>.from(response.data!['messages']);
            }
            _sessionStatus = response.data!['session_status'] ?? _sessionStatus;
            _isSending = false;
          });
          _scrollToBottom();
        }
      } else {
        _showError("Failed to send message");
        setState(() => _isSending = false);
      }
    } catch (e) {
      _showError("Failed to send message");
      setState(() => _isSending = false);
    }
  }

  Future<void> _requestHandover() async {
    if (_sessionId == null) return;
    
    // Optimistic UI update
    setState(() {
      _messages.add({
        'sender': 'user',
        'message': 'I want to speak to a human',
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    try {
      final response = await _apiClient.post(
        AppApiConfig.supportChat,
        body: {
          'action': 'handover',
          'session_id': _sessionId,
        },
      );
      
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            if (response.data!['messages'] != null) {
              _messages = List<Map<String, dynamic>>.from(response.data!['messages']);
            }
            _sessionStatus = response.data!['session_status'] ?? 'pending_human';
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Handover error: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    _sessionStatus == 'ai' ? Icons.smart_toy : Icons.headset_mic,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sessionStatus == 'ai' ? "Bridget (AI)" : "Support Team",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _sessionStatus == 'ai' 
                    ? "Typically replies instantly" 
                    : (_sessionStatus == 'pending_human' ? "Waiting for agent..." : "Online"),
                  style: GoogleFonts.outfit(
                    color: AppColors.textSelected,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Text(
                            "Send a message to start chatting",
                            style: GoogleFonts.outfit(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isUser = msg['sender'] == 'user';
                            return _buildMessageBubble(msg['message'], isUser);
                          },
                        ),
                ),
                
                // Typing Indicator
                if (_isSending)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 8),
                      child: Text("typing...", style: GoogleFonts.outfit(color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                    ),
                  ),

                // Quick Actions (Escalate)
                if (_sessionStatus == 'ai' && _messages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            label: Text("Speak to human", style: GoogleFonts.outfit(color: Colors.white)),
                            backgroundColor: AppColors.surfaceHighlight,
                            side: const BorderSide(color: Colors.white12),
                            onPressed: _requestHandover,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Message Input Area
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const BorderSide(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isSending ? null : _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surfaceHighlight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
