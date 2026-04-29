import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_constants.dart';
import '../theme/app_theme.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system('You are Newsly AI, a polite and helpful news assistant. You must ONLY answer questions related to news, current events, politics, global affairs, or providing summaries of topics. If a user asks a question unrelated to news (e.g. lyrics, personal advice, random facts, coding), politely decline and remind them you are a news assistant.'),
    );
    _chat = _model.startChat();
    _messages.add({
      'role': 'model',
      'text': 'Hi there! I am Newsly AI. Ask me to summarize the latest news, explain complex topics, or anything else.',
    });
  }

  void _sendMessage({String? predefinedText}) async {
    final text = predefinedText ?? _textController.text;
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({'role': 'model', 'text': ''}); // Placeholder for streaming
      _isLoading = true;
    });
    
    _scrollToBottom();

    final modelsToTry = [
      'gemini-3.1-flash-lite-preview',
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
    ];

    bool success = false;
    String errorMessage = "";

    for (String modelName in modelsToTry) {
      if (success) break;
      try {
        final tempModel = GenerativeModel(
          model: modelName,
          apiKey: AppConstants.geminiApiKey,
          systemInstruction: Content.system('You are Newsly AI, a polite and helpful news assistant. You must ONLY answer questions related to news, current events, politics, global affairs, or providing summaries of topics. If a user asks a question unrelated to news (e.g. lyrics, personal advice, random facts, coding), politely decline and remind them you are a news assistant.'),
        );
        final tempChat = tempModel.startChat(history: _chat.history.toList());
        
        final stream = tempChat.sendMessageStream(Content.text(text));
        
        await for (final chunk in stream) {
          if (!mounted) return;
          setState(() {
            _messages.last['text'] = _messages.last['text']! + (chunk.text ?? '');
          });
          _scrollToBottom();
        }
        
        success = true;
        // Update the main chat session so history is preserved
        _chat = tempChat;
      } catch (e) {
        errorMessage = e.toString();
        // Continue to next model on failure (503, not found, etc)
      }
    }

    if (!success && mounted) {
      setState(() {
        _messages.last['text'] = 'Error: All models failed. The server might be overloaded. Details: $errorMessage';
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
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

  Widget _buildSuggestedQuestions() {
    final questions = [
      "What is the current situation in the Middle East?",
      "Summarize today's top technology news.",
      "What are the latest updates on climate change?",
      "Explain the recent global economic trends."
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: questions.map((q) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ActionChip(
            label: Text(q, style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontSize: 13)),
            backgroundColor: AppTheme.accent.withOpacity(0.1),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => _sendMessage(predefinedText: q),
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text(
          'Newsly AI',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return _buildMessageBubble(message['text']!, isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
          _buildSuggestedQuestions(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.accent : AppTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.sourceSans3(
            color: isUser ? Colors.white : AppTheme.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
