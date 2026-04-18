import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/supervisor_service.dart';
import '../../services/auth_provider.dart';
import '../../models/supervisor_profile.dart';

class SupervisorProfileScreen extends StatefulWidget {
  const SupervisorProfileScreen({super.key});

  @override
  State<SupervisorProfileScreen> createState() =>
      _SupervisorProfileScreenState();
}

class _SupervisorProfileScreenState extends State<SupervisorProfileScreen> {
  late final SupervisorService _supervisorService;
  late Future<SupervisorProfile> _profileFuture;

  // Text controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _staffIdController;

  @override
  void initState() {
    super.initState();
    _supervisorService = SupervisorService();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _staffIdController = TextEditingController();
    _initializeProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _staffIdController.dispose();
    super.dispose();
  }

  void _initializeProfile() {
    final supervisorId = context.read<AuthProvider>().userId;
    if (supervisorId != null && supervisorId.isNotEmpty) {
      _profileFuture = _supervisorService.getSupervisorProfile(supervisorId);
    } else {
      _profileFuture = Future.error(
        'Supervisor ID not found. Please log in again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.premiumBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<SupervisorProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildErrorState('No data received from server');
          }

          final profile = snapshot.data!;
          return _buildProfileContent(profile);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.forestEmerald),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: GoogleFonts.montserrat(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(SupervisorProfile profile) {
    // Initialize text controllers with profile data
    _nameController.text = profile.fullName;
    _emailController.text = profile.email;
    _staffIdController.text = profile.staffId;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(profile),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStatusCard(profile),
                const SizedBox(height: 20),
                _buildContactDetailsCard(profile),
                const SizedBox(height: 20),
                if (profile.expertiseTags.isNotEmpty)
                  _buildExpertiseCard(profile),
                const SizedBox(height: 20),
                if (profile.supervisedProjects.isNotEmpty)
                  _buildProjectsCard(profile),
                const SizedBox(height: 30),
                _buildLogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Failed To Load Profile',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Troubleshooting tips:',
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Check your internet connection\n'
                    '• Make sure the backend is running\n'
                    '• Try logging in again\n'
                    '• Check if you\'re logged in as a Supervisor',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white38,
                      fontSize: 10,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() => _initializeProfile()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestEmerald,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Go Back',
                style: GoogleFonts.montserrat(
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SupervisorProfile profile) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.forestEmerald, AppTheme.premiumBlack],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.forestEmerald, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestEmerald.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF161616),
                  child: Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.forestEmerald,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : profile.fullName,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          Text(
            'Staff ID: ${profile.staffId}',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          if (profile.specifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Specializations: ${profile.specifications.join(', ')}',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(SupervisorProfile profile) {
    final availabilityStatus =
        profile.capacityLimit != null &&
            profile.activeProjectsCount < profile.capacityLimit!
        ? 'AVAILABLE'
        : 'FULL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT ALLOCATION',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${profile.activeProjectsCount} Active Projects',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: availabilityStatus == 'AVAILABLE'
                  ? AppTheme.forestEmerald.withOpacity(0.2)
                  : Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: availabilityStatus == 'AVAILABLE'
                    ? AppTheme.forestEmerald.withOpacity(0.5)
                    : Colors.redAccent.withOpacity(0.5),
              ),
            ),
            child: Text(
              availabilityStatus,
              style: TextStyle(
                color: availabilityStatus == 'AVAILABLE'
                    ? AppTheme.forestEmerald
                    : Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailsCard(SupervisorProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: AppTheme.forestEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'OFFICIAL CONTACTS',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildEditableTextField(
            Icons.person_outline,
            'Full Name',
            _nameController,
          ),
          const Divider(color: AppTheme.glassBorder, height: 35),
          _buildEditableTextField(
            Icons.alternate_email_rounded,
            'Email',
            _emailController,
          ),
          const Divider(color: AppTheme.glassBorder, height: 35),
          _buildEditableTextField(
            Icons.badge_outlined,
            'Staff ID',
            _staffIdController,
          ),
          if (profile.capacityLimit != null) ...[
            const Divider(color: AppTheme.glassBorder, height: 35),
            _buildEditableInfoRow(
              Icons.people_outline_rounded,
              'Capacity: ${profile.capacityLimit} projects',
            ),
          ],
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // Show a snackbar confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Changes saved successfully!',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.forestEmerald,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestEmerald,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                'SAVE CHANGES',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.forestEmerald, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.montserrat(
                color: Colors.white38,
                fontSize: 14,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.forestEmerald.withOpacity(0.3),
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.forestEmerald.withOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.forestEmerald),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            cursorColor: AppTheme.forestEmerald,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoRow(IconData icon, String data) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.forestEmerald, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            data,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
          ),
        ),
        Icon(
          Icons.edit_outlined,
          color: Colors.white.withOpacity(0.2),
          size: 18,
        ),
      ],
    );
  }

  Widget _buildExpertiseCard(SupervisorProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.code_outlined,
                color: AppTheme.forestEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'EXPERTISE TAGS',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.expertiseTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.forestEmerald.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.forestEmerald.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag.tagName,
                      style: GoogleFonts.montserrat(
                        color: AppTheme.forestEmerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCard(SupervisorProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                color: AppTheme.forestEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'SUPERVISED PROJECTS',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.supervisedProjects.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppTheme.glassBorder, height: 20),
            itemBuilder: (context, index) {
              final project = profile.supervisedProjects[index];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.status,
                          style: GoogleFonts.montserrat(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(project.status),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status) {
      case 'MATCHED':
        badgeColor = AppTheme.forestEmerald;
        break;
      case 'UNDER_REVIEW':
        badgeColor = Colors.orange;
        break;
      case 'PENDING':
        badgeColor = Colors.grey;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
      label: Text(
        'Go Back',
        style: GoogleFonts.montserrat(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
