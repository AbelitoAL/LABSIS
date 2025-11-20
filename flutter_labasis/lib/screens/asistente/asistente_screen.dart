// lib/screens/asistente/asistente_screen.dart

import 'package:flutter/material.dart';
import '../../services/asistente_service.dart';

class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _loadSugerencias();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'isUser': false,
        'text':
            '¡Hola! 👋 Soy Laby, tu asistente virtual de LABASIS.\n\n¿En qué puedo ayudarte hoy?',
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _loadSugerencias() async {
    try {
      final sugerencias = await AsistenteService.getSugerencias();
      if (sugerencias.isNotEmpty && mounted) {
        final sugerenciasText = sugerencias
            .map((s) => '• ${s['mensaje']}')
            .join('\n');
        
        setState(() {
          _messages.add({
            'isUser': false,
            'text': '💡 Sugerencias:\n\n$sugerenciasText',
            'timestamp': DateTime.now(),
            'isSuggestion': true,
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Ignorar errores de sugerencias
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = message.trim();
    _messageController.clear();

    // Agregar mensaje del usuario
    setState(() {
      _messages.add({
        'isUser': true,
        'text': userMessage,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // Construir historial para contexto
      final historial = _messages
          .where((m) => m['isSuggestion'] != true)
          .where((m) => m['isUser'] == true || m['text'] != '¡Hola! 👋 Soy Laby, tu asistente virtual de LABASIS.\n\n¿En qué puedo ayudarte hoy?')
          .take(_messages.length - 1) // Excluir el mensaje actual
          .map((m) => {
                'mensaje': m['isUser'] ? m['text'] as String : '',
                'respuesta': !m['isUser'] ? m['text'] as String : '',
              })
          .where((h) => h['mensaje']!.isNotEmpty && h['respuesta']!.isNotEmpty)
          .toList();

      final response = await AsistenteService.enviarMensaje(
        mensaje: userMessage,
        historial: historial.isNotEmpty ? historial : null,
      );

      // Agregar respuesta del asistente
      setState(() {
        _messages.add({
          'isUser': false,
          'text': response['respuesta'],
          'timestamp': DateTime.now(),
        });
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'isUser': false,
          'text': '❌ Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
          'timestamp': DateTime.now(),
          'isError': true,
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showQuickMessages() {
    final quickMessages = AsistenteService.getMensajesSugeridos();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mensajes rápidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...quickMessages.map((msg) => ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(msg),
              onTap: () {
                Navigator.pop(context);
                _messageController.text = msg;
                _sendMessage(msg);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar conversación'),
        content: const Text(
          '¿Estás seguro de que deseas limpiar toda la conversación?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearChat();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChat() async {
    try {
      await AsistenteService.clearHistorial();
      
      setState(() {
        _messages.clear();
      });
      
      _addWelcomeMessage();
      _loadSugerencias();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Conversación limpiada'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al limpiar conversación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.smart_toy,
                color: Color(0xFF6C63FF),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laby',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Asistente Virtual',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _confirmClearChat,
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _TypingIndicator();
                        }

                        final message = _messages[index];
                        final isUser = message['isUser'] as bool;
                        final isSuggestion = message['isSuggestion'] == true;
                        final isError = message['isError'] == true;

                        return _MessageBubble(
                          text: message['text'] as String,
                          isUser: isUser,
                          isSuggestion: isSuggestion,
                          isError: isError,
                        );
                      },
                    ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Quick messages button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF6C63FF),
                  onPressed: _showQuickMessages,
                  tooltip: 'Mensajes rápidos',
                ),

                const SizedBox(width: 8),

                // Input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    enabled: !_isTyping,
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isTyping
                        ? null
                        : () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de burbuja de mensaje
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isSuggestion;
  final bool isError;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    this.isSuggestion = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: isSuggestion
                  ? Colors.orange[100]
                  : isError
                      ? Colors.red[100]
                      : const Color(0xFF6C63FF).withOpacity(0.1),
              radius: 16,
              child: Icon(
                isSuggestion
                    ? Icons.lightbulb
                    : isError
                        ? Icons.error_outline
                        : Icons.smart_toy,
                size: 18,
                color: isSuggestion
                    ? Colors.orange[700]
                    : isError
                        ? Colors.red[700]
                        : const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6C63FF)
                    : isSuggestion
                        ? Colors.orange[50]
                        : isError
                            ? Colors.red[50]
                            : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : isSuggestion
                          ? Colors.orange[900]
                          : isError
                              ? Colors.red[900]
                              : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Indicador de "escribiendo..."
class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
            radius: 16,
            child: const Icon(
              Icons.smart_toy,
              size: 18,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 200),
                const SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dot animado
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF6C63FF),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}