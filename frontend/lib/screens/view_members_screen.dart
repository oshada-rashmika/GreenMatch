import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/student_service.dart';
import '../theme/app_theme.dart';

class ViewMembersScreen extends StatefulWidget {
  const ViewMembersScreen({super.key});

  @override
  State<ViewMembersScreen> createState() => _ViewMembersScreenState();
}

class _ViewMembersScreenState extends State<ViewMembersScreen> {
  final Color bgColor = AppTheme.premiumBlack;
  final Color cardColor = Colors.white.withOpacity(0.03);
  final Color accentColor = AppTheme.forestEmerald;
  final Color mutedTextColor = Colors.white60;

  bool _isLoading = true;
  List<MyProposalData> _proposals = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final service = StudentService();
      final proposals = await service.fetchMyProposals();
      if (mounted) {
        setState(() {
          _proposals = proposals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: Text(
            'My Members',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald))
            : _proposals.isEmpty
                ? Center(
                    child: Text(
                      'No groups found.',
                      style: TextStyle(color: mutedTextColor, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _proposals.length,
                    itemBuilder: (context, index) {
                      final proposal = _proposals[index];
                      return _buildSubjectCard(proposal);
                    },
                  ),
      ),
    );
  }

  Widget _buildSubjectCard(MyProposalData proposal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: accentColor.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Icon(Icons.import_contacts, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    proposal.moduleName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Members List
          if (proposal.members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No members found for this group.',
                style: TextStyle(color: mutedTextColor),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: proposal.members.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final member = proposal.members[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: Text(
                          member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  member.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (member.isLeader) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                    ),
                                    child: const Text(
                                      'LEADER',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${member.studentId} • ${member.degree}',
                              style: TextStyle(
                                color: mutedTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
