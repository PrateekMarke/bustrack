import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String busId; // Bus ID (Driver UID) passed from the previous screen

  const ChatScreen({required this.busId, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageTextController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser; // Get the logged-in user
  }

  // ✅ Send Message with User's Name
  void sendMessage() async {
    if (messageTextController.text.isNotEmpty && loggedInUser != null) {
      try {
        String userId = loggedInUser!.uid;
        String userName = loggedInUser!.email ?? "Unknown"; // Default to email

        // Fetch Driver Name (if sender is a driver)
        DocumentSnapshot driverDoc = await _firestore.collection("driver").doc(userId).get();
        if (driverDoc.exists && driverDoc.data() != null) {
          userName = driverDoc["name"] ?? userName; // Driver's name
        }

        // Fetch Student Name (if sender is a student)
        DocumentSnapshot studentDoc = await _firestore.collection("students").doc(userId).get();
        if (studentDoc.exists && studentDoc.data() != null) {
          userName = studentDoc["name"] ?? userName; // Student's name
        }

        // Send the message to Firestore with sender’s name
        await _firestore.collection('chats').doc(widget.busId).collection('messages').add({
          'text': messageTextController.text,
          'sender': loggedInUser!.email, // Email remains for authentication
          'senderName': userName, // Store sender’s actual name
          'time': FieldValue.serverTimestamp(),
        });

        messageTextController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageStream(busId: widget.busId),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final String busId;
  const MessageStream({required this.busId});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder(
      stream: _firestore
          .collection("chats")
          .doc(busId)
          .collection("messages")
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];

        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];
          final senderName = message.data().containsKey('senderName') 
              ? message['senderName'] 
              : "Unknown"; // ✅ Prevents crash

          final messageBubble = MessageBubble(
            sender: messageSender,
            senderName: senderName, // Use "Unknown" if missing
            text: messageText,
            isMe: FirebaseAuth.instance.currentUser?.email == messageSender,
          );
          messageBubbles.add(messageBubble);
        }

        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: messageBubbles,
        );
      },
    );
  }
}


// ✅ Message Bubble Widget
class MessageBubble extends StatelessWidget {
  final String sender;
  final String senderName; // New field to store name
  final String text;
  final bool isMe;

  const MessageBubble({
    required this.sender,
    required this.senderName,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Show actual sender name above the message
          Text(
            senderName,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            color: isMe ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
