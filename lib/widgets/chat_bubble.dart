import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: ChatPage(
        isDark: isDark,
        toggleTheme: () {
          setState(() => isDark = !isDark);
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const ChatPage({super.key, required this.isDark, required this.toggleTheme});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];
  bool isTyping = true;
  bool showEmoji = false;

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final bounce = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.elasticOut),
    );

    setState(() {
      messages.add({
        "text": text,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
        "animation": animController,
        "bounce": bounce,
      });
      isTyping = true;
    });

    _controller.clear();
    animController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 70,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => isTyping = false);
    });
  }

  @override
  void dispose() {
    for (var m in messages) {
      (m['animation'] as AnimationController?)?.dispose();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget typingBubble(bool dark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: dark
              ? LinearGradient(colors: [Colors.grey.shade900, Colors.black54])
              : const LinearGradient(
                  colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            if (!dark)
              BoxShadow(
                color: const Color(0xFF00BCD4).withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: SizedBox(
          width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (i) => AnimatedDot(dark: dark, delay: i * 200),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;

    return Scaffold(
      backgroundColor: dark ? Colors.black : Colors.grey[200],
      appBar: AppBar(
        elevation: 4,
        backgroundColor: dark ? Colors.black : Colors.blueGrey,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: dark ? Colors.white12 : Colors.white,
              child: Icon(
                Icons.person,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KingDev",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Online",
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              dark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return typingBubble(dark);
                }

                final msg = messages[index];
                final anim = msg['animation'] as AnimationController?;
                final bounce = msg['bounce'] as Animation<double>?;

                final bubble = Align(
                  alignment: msg["isMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: msg["isMe"]
                          ? LinearGradient(
                              colors: dark
                                  ? [Colors.black87, Colors.grey[900]!]
                                  : const [
                                      Color(0xFFDA22FF),
                                      Color(0xFF9733EE),
                                    ],
                            )
                          : LinearGradient(
                              colors: dark
                                  ? [Colors.grey.shade900, Colors.black54]
                                  : const [
                                      Color(0xFFE0F7FA),
                                      Color(0xFFB2EBF2),
                                    ],
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: msg["isMe"]
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: msg["isMe"]
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      boxShadow: [
                        if (dark)
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        if (!dark && msg["isMe"])
                          BoxShadow(
                            color: const Color(0xFFDA22FF).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        if (!dark && !msg["isMe"])
                          BoxShadow(
                            color: const Color(0xFF00BCD4).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg["text"],
                          style: TextStyle(
                            color: msg["isMe"]
                                ? Colors.white
                                : (dark ? Colors.white : Colors.black87),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["time"],
                          style: TextStyle(
                            fontSize: 11,
                            color: msg["isMe"]
                                ? Colors.white70
                                : (dark ? Colors.white70 : Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (anim != null && bounce != null) {
                  return FadeTransition(
                    opacity: anim.drive(Tween(begin: 0, end: 1)),
                    child: ScaleTransition(scale: bounce, child: bubble),
                  );
                }

                return bubble;
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: dark ? Colors.black : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: dark
                      ? Colors.blueAccent.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: dark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    setState(() => showEmoji = !showEmoji);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) {
                      setState(() => isTyping = _controller.text.isNotEmpty);
                    },
                    style: TextStyle(color: dark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: dark
                          ? Colors.grey.shade900
                          : Colors.white.withOpacity(0.8),
                      hintText: "Type message...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: dark ? Colors.blueAccent : Colors.grey,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: dark ? Colors.blueAccent : Colors.black87,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),

          if (showEmoji)
            Container(
              height: 250,
              color: dark ? Colors.grey.shade900 : Colors.white70,
              child: GridView.count(
                crossAxisCount: 8,
                children: List.generate(32, (i) {
                  String emoji = String.fromCharCode(0x1F600 + i);
                  return GestureDetector(
                    onTap: () {
                      _controller.text += emoji;
                    },
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedDot extends StatefulWidget {
  final bool dark;
  final int delay;

  const AnimatedDot({super.key, required this.dark, required this.delay});

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.dark ? Colors.white70 : Colors.black87,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
