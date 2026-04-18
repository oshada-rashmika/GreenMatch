import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.premiumBlack,
        appBar: AppBar(
          backgroundColor: AppTheme.premiumBlack,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Formatting Guidelines',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book, color: AppTheme.forestEmerald),
                        SizedBox(width: 12),
                        Text(
                          'Project Proposal Guidelines',
                          style: TextStyle(
                            color: AppTheme.forestEmerald,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGuidelineItem(
                      '1. Word Count',
                      'The abstract must be between 200 and 300 words. Do not exceed the word limit.',
                    ),
                    _buildGuidelineItem(
                      '2. Formatting Structure',
                      'Use standard academic formatting. Ensure you include a clearly defined Problem Statement, Proposed Solution, and Tech Stack.',
                    ),
                    _buildGuidelineItem(
                      '3. Group Composition',
                      'Groups should consist of up to 6 members. The group leader must submit the proposal on behalf of the team.',
                    ),
                    _buildGuidelineItem(
                      '4. Module Alignment',
                      'Projects must directly address the core topics of the selected Academic Module.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Note: These guidelines are managed by the Module Leader and are subject to change before the semester begins.',
                style: TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
