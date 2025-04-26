import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/message.dart';
import 'helpers/database_helper.dart';

class MessageFormScreen extends StatefulWidget {
  final Message? existingMessage;

  MessageFormScreen({this.existingMessage});

  @override
  _MessageFormScreenState createState() => _MessageFormScreenState();
}

class _MessageFormScreenState extends State<MessageFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingMessage != null) {
      _titleController.text = widget.existingMessage!.content;
      _descriptionController.text = widget.existingMessage!.description ?? '';
      if (widget.existingMessage!.imagePath != null) {
        _selectedImage = File(widget.existingMessage!.imagePath!);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveMessage() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a title.")),
      );
      return;
    }

    final message = Message(
      id: widget.existingMessage?.id,
      content: title,
      description: description.isNotEmpty ? description : null,
      imagePath: _selectedImage?.path,
      createdAt: DateTime.now(),
    );

    if (widget.existingMessage == null) {
      await DatabaseHelper().insertMessage(message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message created!")),
      );
    } else {
      await DatabaseHelper().updateMessage(message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message updated!")),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingMessage == null ? 'Create Message' : 'Edit Message'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.3,
        actions: [
          TextButton(
            onPressed: _saveMessage,
            child: Text(
              widget.existingMessage == null ? 'Post' : 'Update',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextField(
                      controller: _titleController,
                      maxLines: 1,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "Title",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      minLines: 3,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "What is on your mind?",
                        border: InputBorder.none,
                      ),
                    ),

                    // Show Image if selected
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Image removed.")),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Camera and Gallery Buttons
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icon(Icons.camera_alt_outlined),
                          tooltip: "Camera",
                        ),
                        IconButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: Icon(Icons.photo_outlined),
                          tooltip: "Gallery",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
