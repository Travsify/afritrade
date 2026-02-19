import 'dart:async';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_config.dart';

class SupportAssistantScreen extends StatefulWidget {
  const SupportAssistantScreen({super.key});

  @override
  State<SupportAssistantScreen> createState() => _SupportAssistantScreenState();
}

class _SupportAssistantScreenState extends State<SupportAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  Timer? _pollingTimer;

  // Production URL
  static const String _baseUrl = AppApiConfig.supportChat;
  
  String? _sessionId;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initChatSession();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChatSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSessionId = prefs.getString('support_session_id');

      final res = await http.post(
        Uri.parse('$_baseUrl?action=init'),
        body: jsonEncode({
          'user_id': prefs.getString('user_id') ?? 'mobile_user',
          'session_id': savedSessionId,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _sessionId = data['session_id'];
        await prefs.setString('support_session_id', _sessionId!);
        
        setState(() {
          _isInit = true;
        });

        if (savedSessionId != null) {
          await _fetchHistory();
        } else {
          setState(() {
            _messages.add(ChatMessage(
              text: "Hello! I'm Bridget, your Afritrade assistant. How can I help you today?",
              isUser: false,
            ));
          });
        }
        
        _startPolling();
      }
    } catch (e) {
      debugPrint("Chat Init Error: $e");
      setState(() {
         _messages.add(ChatMessage(
            text: "Hello! I'm Bridget. (Offline Mode - Check Server Connection)",
            isUser: false,
          ));
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _sessionId != null) {
        _fetchHistory(silent: true);
      }
    });
  }

  Future<void> _fetchHistory({bool silent = false}) async {
    if (_sessionId == null) return;

    try {
      final res = await http.get(
        Uri.parse('$_baseUrl?action=fetch&session_id=$_sessionId'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final List<dynamic> history = data['messages'];
          final List<ChatMessage> newMessages = history.map((m) {
            String sender = 'Bridget (AI)';
            if (m['sender'] == 'agent') sender = 'Agent';
            if (m['sender'] == 'user') sender = 'You';

            return ChatMessage(
              text: m['message'],
              isUser: m['sender'] == 'user',
              sender: m['sender'] == 'user' ? null : sender,
            );
          }).toList();

          if (newMessages.length > _messages.length) {
            setState(() {
              _messages.clear();
              _messages.addAll(newMessages);
              if (!silent) _isTyping = false;
            });
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch History Error: $e");
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _sendToBackend(userMessage);
  }

  Future<void> _sendToBackend(String message) async {
    if (!_isInit || _sessionId == null) {
      _processOfflineResponse(message);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl?action=send'),
        body: jsonEncode({
          'session_id': _sessionId,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (mounted) {
            if (data['reply'] != null) {
              setState(() {
                _isTyping = false;
                _messages.add(ChatMessage(
                  text: data['reply'],
                  isUser: false,
                  sender: data['mode'] == 'human' ? 'Agent' : 'Bridget (AI)'
                ));
              });
              _scrollToBottom();
            } else if (data['mode'] == 'human') {
              // Waiting for human, keep typing indicator maybe?
              // Or just fetch history will pick it up
            }
          }
      }
    } catch (e) {
       if (mounted) _processOfflineResponse(message);
    }
  }

  void _processOfflineResponse(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: _getAIResponse(message),
          isUser: false,
          sender: 'Bridget (AI-Demo)'
        ));
      });
      _scrollToBottom();
    }
  }

  String _getAIResponse(String query) {
    query = query.toLowerCase();
    
    if (query.contains('hello') || query.contains('hi') || query.contains('hey')) {
      return "Hello! How can I assist you with your trades today?";
    }
    if (query.contains('rate') || query.contains('price')) {
      return "Our rates are updated in real-time. For USD/NGN, the current rate is approx 1550. You can check the 'Swap' tab for exact figures.";
    }
    if (query.contains('kyc') || query.contains('verify')) {
      return "Verification is simple! Go to Profile > Compliance to upload your documents. It usually takes 24 hours.";
    }
    if (query.contains('send') || query.contains('transfer') || query.contains('pay')) {
      return "To send money, use the 'Quick Actions' menu on the home screen and select 'Send Money'. We support transfers to China, UK, USA, and Europe.";
    }
    if (query.contains('delay') || query.contains('slow')) {
      return "I apologize for any delay. Cross-border payments typically process within 24-48 hours. If it has been longer, please tap 'Agent' above to speak to a human.";
    }
    
    return "I see. Could you provide more details? Or you can tap the 'Agent' button at the top right to talk to a human specialist.";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handoffToAgent() async {
    if (_sessionId == null) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: "Connecting you to a human agent...",
        isUser: false,
        isSystem: true
      ));
    });
    _scrollToBottom();

    try {
      await http.post(
        Uri.parse('$_baseUrl?action=handover'),
        body: jsonEncode({'session_id': _sessionId}),
      );
    } catch (e) {
      debugPrint("Handover Error: $e");
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bridget Assistant", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Online • AI Powered", style: GoogleFonts.outfit(color: AppColors.success, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _handoffToAgent,
            icon: const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primary),
            label: Text("Agent", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 12),
              child: FadeIn(
                child: Row(
                  children: [
                    Text("Bridget is typing", style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(width: 4),
                    const _TypingIndicator(),
                  ],
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.sender != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(message.sender!, style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 20),
              ),
              border: Border.all(color: message.isUser ? Colors.transparent : AppColors.glassBorder),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Ask anything about Afritrade...",
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 15),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.glowShadow(AppColors.primary),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? sender;
  final bool isSystem;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.sender,
    this.isSystem = false,
  });
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.2, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: 4,
            width: 4,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
        );
      }),
    );
  }
}
