import 'package:flutter/material.dart';
import '../services/student_service.dart';

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  final Color bgColor = const Color(0xFF0F1522);
  final Color cardColor = const Color(0xFF1A2235);
  final Color accentColor = const Color(0xFFFACC15); // Yellow
  final Color mutedTextColor = const Color(0xFF94A3B8); // Slate 400

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
      default: return accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Proposals',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: mutedTextColor,
            dividerColor: const Color(0xFF2B364E),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Active & Drafts'),
              Tab(text: 'Past Projects'),
            ],
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _buildActiveAndDraftsTab(),
                _buildPastProjectsTab(),
              ],
            ),
      ),
    );
  }

  Widget _buildActiveAndDraftsTab() {
    final active = _proposals.where((p) => p.status != 'REJECTED' && p.status != 'COMPLETED').toList();

    if (active.isEmpty) {
       return Center(child: Text("No active proposals found.", style: TextStyle(color: mutedTextColor)));
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
       return Center(child: Text("No past projects found.", style: TextStyle(color: mutedTextColor)));
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B364E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              if (isDraft)
                 Row(
                   children: [
                     Icon(Icons.edit_outlined, color: mutedTextColor, size: 16),
                     const SizedBox(width: 4),
                     Text('Edit', style: TextStyle(color: mutedTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                   ],
                 )
              else
                 Icon(Icons.chevron_right, color: mutedTextColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
             date,
             style: TextStyle(color: mutedTextColor, fontSize: 11),
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
                borderRadius: BorderRadius.circular(8),
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
                   Text('Supervisor: $supervisor', style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
             ),
          ],
        ],
      ),
    );
  }
}
