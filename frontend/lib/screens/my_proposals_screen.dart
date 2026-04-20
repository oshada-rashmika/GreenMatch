import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/student_service.dart';

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  final Color bgColor = AppTheme.premiumBlack;
  final Color cardColor = Colors.white.withValues(alpha: 0.03);
  final Color accentColor = AppTheme.forestEmerald;
  final Color mutedTextColor = Colors.white60;

  List<MyProposalData> _proposals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProposals();
  }

  Future<void> _fetchProposals() async {
    try {
      final fetched = await StudentService().fetchMyProposals();
      if (mounted) {
        setState(() {
          _proposals = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'MATCHED': return const Color(0xFF10B981); // Emerald
      case 'UNDER_REVIEW': return const Color(0xFF3B82F6); // Blue
      case 'REJECTED': return const Color(0xFFEF4444); // Red
      default: return const Color(0xFFFACC15); // Yellow for pending/draft
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'My Proposals',
              style: GoogleFonts.montserrat(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.w700, 
                letterSpacing: 0.3
              ),
            ),
            bottom: TabBar(
              indicatorColor: AppTheme.forestEmerald,
              labelColor: AppTheme.forestEmerald,
              unselectedLabelColor: mutedTextColor,
              dividerColor: Colors.white.withValues(alpha: 0.05),
              indicatorWeight: 3,
              labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Active & Drafts'),
                Tab(text: 'Past Projects'),
              ],
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.forestEmerald.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald))
                : TabBarView(
                    children: [
                      _buildActiveAndDraftsTab(),
                      _buildPastProjectsTab(),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAndDraftsTab() {
    final active = _proposals.where((p) => p.status != 'REJECTED' && p.status != 'COMPLETED').toList();

    if (active.isEmpty) {
       return Center(child: Text("No active proposals found.", style: GoogleFonts.montserrat(color: mutedTextColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: active.length,
      itemBuilder: (context, index) {
        final p = active[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildProposalCard(
            title: p.title,
            status: p.status,
            statusColor: _getStatusColor(p.status),
            date: 'Submitted: ${_formatDate(p.createdAt)}',
            abstractPreview: p.abstractText,
            isDraft: false,
            supervisor: p.supervisorName,
          ),
        );
      },
    );
  }

  Widget _buildPastProjectsTab() {
    final past = _proposals.where((p) => p.status == 'REJECTED' || p.status == 'COMPLETED').toList();

    if (past.isEmpty) {
       return Center(child: Text("No past projects found.", style: GoogleFonts.montserrat(color: mutedTextColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: past.length,
      itemBuilder: (context, index) {
        final p = past[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildProposalCard(
            title: p.title,
            status: p.status,
            statusColor: _getStatusColor(p.status),
            date: 'Concluded: ${_formatDate(p.createdAt)}',
            abstractPreview: p.abstractText,
            isDraft: false,
            supervisor: p.supervisorName,
          ),
        );
      },
    );
  }

  Widget _buildProposalCard({
    required String title,
    required String status,
    required Color statusColor,
    required String date,
    required String abstractPreview,
    required bool isDraft,
    String? feedback,
    String? supervisor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radio_button_checked, color: statusColor, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.montserrat(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              if (isDraft)
                 Row(
                   children: [
                     Icon(Icons.edit_outlined, color: mutedTextColor, size: 16),
                     const SizedBox(width: 4),
                     Text('Edit', style: GoogleFonts.montserrat(color: mutedTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                   ],
                 )
              else
                 Icon(Icons.chevron_right, color: mutedTextColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
             date,
             style: GoogleFonts.montserrat(color: mutedTextColor, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Text(
            abstractPreview,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (feedback != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
              ),
              child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                       child: Text('Feedback: $feedback', style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, height: 1.4)),
                    )
                 ],
              ),
            ),
          ],
          if (supervisor != null) ...[
             const SizedBox(height: 16),
             Row(
                children: [
                   const Icon(Icons.person_outline, color: Color(0xFF10B981), size: 16),
                   const SizedBox(width: 8),
                   Text('Supervisor: $supervisor', style: GoogleFonts.montserrat(color: const Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
             ),
          ],
        ],
      ),
    );
  }
}
