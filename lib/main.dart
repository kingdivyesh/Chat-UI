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
  bool isDark = true; // Start with neon black dark mode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: ChatPage(
        key: const ValueKey('chatPage'),
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
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool showEmoji = false;

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.elasticOut),
    );

    setState(() {
      messages.add({
        "text": text,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
        "animation": animationController,
        "bounce": bounceAnimation,
      });
      isTyping = false;
    });

    _controller.clear();
    animationController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 70,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    for (var m in messages) {
      m['animation']?.dispose();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDark;

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
      body: Container(
        decoration: dark
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[200]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isTyping && index == messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: dark ? Colors.grey.shade900 : Colors.grey[200],
                          border: dark
                              ? null
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Typing...",
                          style: TextStyle(
                            fontSize: 14,
                            color: dark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }

                  final msg = messages[index];
                  final anim = msg['animation'] as AnimationController?;
                  final bounce = msg['bounce'] as Animation<double>?;

                  Widget bubble = Align(
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
                                    : [
                                        Colors.blueGrey.withAlpha(
                                          (1 * 255).toInt(),
                                        ),
                                        Colors.black54.withAlpha(
                                          (0.4 * 255).toInt(),
                                        ),
                                      ],
                              )
                            : LinearGradient(
                                colors: dark
                                    ? [Colors.grey.shade900, Colors.black54]
                                    : [
                                        Colors.white70.withAlpha(
                                          (0.4 * 255).toInt(),
                                        ),
                                        Colors.white,
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
                              color: Colors.blueAccent.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
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
                                  : (dark ? Colors.white : Colors.black),
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
                                  : Colors.black45,
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

            // Emoji Panel
            if (showEmoji)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: dark ? Colors.grey.shade900 : Colors.grey[200],
                  border: dark ? null : Border.all(color: Colors.grey.shade400),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: GridView.count(
                  crossAxisCount: 8,
                  children: List.generate(32, (i) {
                    String emoji = String.fromCharCode(0x1F600 + i);
                    return GestureDetector(
                      onTap: () {
                        _controller.text += emoji;
                      },
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: dark ? Colors.black : Colors.grey[200],
                border: dark ? null : Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(25),
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
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: dark
                            ? Colors.grey.shade900
                            : Colors.grey[100],
                        hintText: "Type message...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
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
          ],
        ),
      ),
    );
  }
}
