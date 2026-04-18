import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/guideline.dart';
import '../services/guideline_service.dart';

class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  State<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends State<GuidelinesScreen> {
  final GuidelineService _guidelineService = GuidelineService();
  List<Guideline> _guidelines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuidelines();
  }

  Future<void> _loadGuidelines() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final fetchedGuidelines = await _guidelineService.fetchGuidelinesForStudent();
      
      setState(() {
        _guidelines = fetchedGuidelines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showPremiumError(e.toString());
    }
  }

  void _showPremiumError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

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
            'Academic Guidelines',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.forestEmerald,
        ),
      );
    }

    if (_guidelines.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGuidelines,
      color: AppTheme.forestEmerald,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      child: ListView.separated(
        padding: const EdgeInsets.all(24.0),
        itemCount: _guidelines.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          return _buildGuidelineCard(_guidelines[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: AppTheme.forestEmerald.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text(
            'No Guidelines Yet',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your module-specific guidelines will appear here.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard(Guideline guideline) {
    return Container(
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
            children: [
              const Icon(Icons.menu_book, color: AppTheme.forestEmerald),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guideline.module?.moduleCode ?? 'N/A',
                      style: TextStyle(
                        color: AppTheme.forestEmerald.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      guideline.title,
                      style: const TextStyle(
                        color: AppTheme.forestEmerald,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            guideline.instructions,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          if (guideline.deliverables.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'REQUIRED DELIVERABLES',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: guideline.deliverables.keys.map((d) => _buildDeliverableChip(d)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliverableChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.forestEmerald.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.forestEmerald,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
