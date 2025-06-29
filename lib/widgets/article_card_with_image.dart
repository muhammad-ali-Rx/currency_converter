import 'dart:convert' show base64Decode;

import 'package:currency_converter/model/article_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget _buildNewsCard(Article article) {
  Color impactColor;
  switch (article.impact) {
    case 'High':
      impactColor = Colors.red;
      break;
    case 'Medium':
      impactColor = Colors.orange;
      break;
    default:
      impactColor = Colors.green;
  }
  
  /// Returns a human-readable "time ago" string from a DateTime or String.
  String _getTimeAgo(dynamic createdAt) {
    DateTime date;
    if (createdAt is String) {
      date = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else if (createdAt is DateTime) {
      date = createdAt;
    } else {
      return '';
    }
    final Duration diff = DateTime.now().difference(date);
  
    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
      ),
    ),
    child: InkWell(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ArticleDetailScreen(article: article),
      //   ),
      // ),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (article.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: _buildArticleImage(article.imageUrl),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Impact badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 10, 108, 236),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: impactColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${article.impact} Impact',
                        style: TextStyle(
                          color: impactColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Title and Summary
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.summary,
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Meta info
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF8A94A6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(article.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF8A94A6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.source,
                      color: Color(0xFF8A94A6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.source,
                      style: const TextStyle(
                        color: Color(0xFF8A94A6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildArticleImage(String imageUrl) {
  if (imageUrl.startsWith('data:image')) {
    // Base64 image
    try {
      final base64String = imageUrl.split(',')[1]; // Remove data:image/jpeg;base64, part
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } catch (e) {
      return _buildPlaceholderImage();
    }
  } else if (imageUrl.isNotEmpty) {
    // URL image
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage();
      },
    );
  }
  
  return _buildPlaceholderImage();
}

Widget _buildPlaceholderImage() {
  return Container(
    width: double.infinity,
    height: 200,
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Icon(
        Icons.image_not_supported,
        color: Color(0xFF8A94A6),
        size: 48,
      ),
    ),
  );
}
