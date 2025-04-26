import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/message.dart';

class message_detail_screen extends StatelessWidget {
  final Message message;

  const message_detail_screen({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Message View",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 280,
                    minHeight: 180,
                    maxWidth: double.infinity,
                  ),
                  child: Image.file(
                    File(message.imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.createdAt != null
                        ? DateFormat('MMMM dd, yyyy – hh:mm a').format(message.createdAt!)
                        : "",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (message.description != null && message.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      message.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
