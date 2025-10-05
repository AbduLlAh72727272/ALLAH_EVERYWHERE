import 'dart:io';
import 'package:allah_every_where/services/ChatService.dart';
import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String alimName;
  final String alimProfilePicture;
  final bool isAlimOnline;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.alimName,
    required this.alimProfilePicture,
    required this.isAlimOnline,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isTyping = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.chatId);
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isUploading) return;

    _messageController.clear();
    setState(() => _isTyping = false);

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        message: message,
        messageType: 'text',
      );
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Failed to send message: $e');
    }
  }

  void _sendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() => _isUploading = true);
        
        final mediaUrl = await _chatService.uploadMedia(
          file: File(image.path),
          chatId: widget.chatId,
          messageType: 'image',
        );
        
        await _chatService.sendMessage(
          chatId: widget.chatId,
          message: 'Image',
          messageType: 'image',
          mediaUrl: mediaUrl,
        );
        
        setState(() => _isUploading = false);
        _scrollToBottom();
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackBar('Failed to send image: $e');
    }
  }

  void _sendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploading = true);
        
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        
        final mediaUrl = await _chatService.uploadMedia(
          file: file,
          chatId: widget.chatId,
          messageType: 'file',
        );
        
        await _chatService.sendMessage(
          chatId: widget.chatId,
          message: fileName,
          messageType: 'file',
          mediaUrl: mediaUrl,
        );
        
        setState(() => _isUploading = false);
        _scrollToBottom();
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackBar('Failed to send file: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image, color: Colors.blue),
              title: Text('Send Image'),
              onTap: () {
                Navigator.pop(context);
                _sendImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: Colors.green),
              title: Text('Send File'),
              onTap: () {
                Navigator.pop(context);
                _sendFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.close, color: Colors.red),
              title: Text('Close Chat'),
              onTap: () {
                Navigator.pop(context);
                _showCloseConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Close Chat'),
        content: Text('Are you sure you want to close this chat session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatService.closeChatSession(widget.chatId);
                Navigator.pop(context);
              } catch (e) {
                _showErrorSnackBar('Failed to close chat: $e');
              }
            },
            child: Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF1C7B2), Color(0xFFB19F95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: widget.alimProfilePicture.isNotEmpty
                      ? NetworkImage(widget.alimProfilePicture)
                      : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  radius: 20.r,
                ),
                if (widget.isAlimOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.alimName,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.isAlimOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: widget.isAlimOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'close':
                  _showCloseConfirmation();
                  break;
                case 'rate':
                  _showRatingDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'rate',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8.w),
                    Text('Rate Scholar'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'close',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 8.w),
                    Text('Close Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: VoidColors.secondary,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getMessagesStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data?.docs ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Start your conversation',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Send a message to begin chatting with the scholar',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      final isMe = messageData['senderId'] == _chatService.currentUser?.uid;
                      final timestamp = messageData['timestamp'] as Timestamp?;
                      final time = timestamp != null 
                          ? DateFormat('hh:mm a').format(timestamp.toDate())
                          : '';

                      return _buildMessageBubble(
                        isMe: isMe,
                        message: messageData['message'] ?? '',
                        time: time,
                        messageType: messageData['messageType'] ?? 'text',
                        mediaUrl: messageData['mediaUrl'],
                        isRead: messageData['isRead'] ?? false,
                      );
                    },
                  );
                },
              ),
            ),
            if (_isUploading)
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(width: 8),
                    Text('Uploading...'),
                  ],
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String message,
    required String time,
    required String messageType,
    String? mediaUrl,
    required bool isRead,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
        padding: EdgeInsets.all(12.w),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF373E4E) : Color(0xFF7A8194),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: isMe ? Radius.circular(12.r) : Radius.circular(4.r),
            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (messageType == 'image' && mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  mediaUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.error),
                    );
                  },
                ),
              )
            else if (messageType == 'file' && mediaUrl != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, color: Colors.white),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                message,
                style: TextStyle(fontSize: 14.sp, color: VoidColors.white),
              ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 10.sp, color: VoidColors.white.withOpacity(0.7)),
                ),
                if (isMe) ...[
                  SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: isRead ? Colors.blue : VoidColors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFF3D4354),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showOptionsBottomSheet,
            child: Icon(
              Icons.add,
              color: Color(0xFF9398A7),
              size: 24,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              onChanged: (text) {
                setState(() {
                  _isTyping = text.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: VoidColors.white.withOpacity(0.6)),
              ),
              style: TextStyle(color: VoidColors.white),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _isTyping ? _sendMessage : null,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isTyping ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    double rating = 5.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate this Scholar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How would you rate your experience?'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = (index + 1).toDouble();
                      });
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _chatService.rateAlim(
                    chatId: widget.chatId,
                    alimId: '', // You'd need to pass this from the chat data
                    rating: rating,
                    review: reviewController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thank you for your feedback!')),
                  );
                } catch (e) {
                  _showErrorSnackBar('Failed to submit rating: $e');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
