import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_provider.dart';
import '../services/module_leader_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ModuleLeaderProfileScreen extends StatefulWidget {
  const ModuleLeaderProfileScreen({super.key});

  @override
  State<ModuleLeaderProfileScreen> createState() => _ModuleLeaderProfileScreenState();
}

class _ModuleLeaderProfileScreenState extends State<ModuleLeaderProfileScreen> {
  final Color bgColor = AppTheme.premiumBlack;
  final Color cardColor = const Color(0xFF161618);
  final Color greenAccent = const Color(0xFF2D5A27);
  final Color accentColor = AppTheme.forestEmerald;
  final Color mutedTextColor = const Color(0xFF6B7280);
  final Color dividerColor = const Color(0xFF2A2A2A);
  
  late Future<ModuleLeaderProfile>? _profileFuture;
  final ModuleLeaderService _service = ModuleLeaderService();
  
  bool _isPersonalInfoExpanded = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final token = context.read<AuthProvider>().accessToken;
    if (token != null) {
      _profileFuture = _service.fetchProfile(jwtToken: token).then((profile) {
        _nameController.text = profile.fullName;
        _staffIdController.text = profile.staffId;
        return profile;
      });
    } else {
      _profileFuture = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _staffIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profileFuture == null) {
      return const Scaffold(
        backgroundColor: AppTheme.premiumBlack,
        body: Center(child: Text('Authentication required', style: TextStyle(color: Colors.white))),
      );
    }

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Module Leader Profile',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<ModuleLeaderProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.forestEmerald));
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                ),
              );
            }

            final profile = snapshot.data!;
            
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1A381A),
                          bgColor,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        _buildProfileAvatar(),
                        const SizedBox(height: 22),
                        Text(
                          profile.fullName,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Text(
                            'Staff ID: ${profile.staffId}',
                            style: GoogleFonts.montserrat(color: mutedTextColor, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildManagedModulesCard(profile),
                        const SizedBox(height: 16),
                        _buildPersonalInfoForm(profile),
                        const SizedBox(height: 16),
                        _buildLogOutButton(),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
             width: 115,
             height: 115,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: const Color(0xFF1E1E1E),
               border: Border.all(color: greenAccent.withOpacity(0.6), width: 3),
               boxShadow: [
                 BoxShadow(
                   color: greenAccent.withOpacity(0.2),
                   blurRadius: 20,
                   spreadRadius: 5,
                 ),
               ],
             ),
             child: const Icon(Icons.school, size: 50, color: Color(0xFF6B7280)),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E4F2E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B361B), width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagedModulesCard(ModuleLeaderProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MANAGED MODULES',
                style: GoogleFonts.montserrat(
                  color: mutedTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${profile.ledModules.length} Modules',
                  style: GoogleFonts.montserrat(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (profile.ledModules.isEmpty)
            Text(
              'No modules currently managed.',
              style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14),
            )
          else
            ...profile.ledModules.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.moduleName,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${m.moduleCode} • ${m.academicYear} • ${m.batch}',
                      style: GoogleFonts.montserrat(color: mutedTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(ModuleLeaderProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isPersonalInfoExpanded = !_isPersonalInfoExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Icon(
                  _isPersonalInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: mutedTextColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditableTextField('FULL NAME', _nameController),
                const SizedBox(height: 16),
                _buildEditableTextField('STAFF ID', _staffIdController),
                const SizedBox(height: 16),
                _buildReadOnlyField('EMAIL ADDRESS', profile.email),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final token = context.read<AuthProvider>().accessToken;
                      if (token == null) return;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saving changes...')),
                      );

                      final result = await _service.updateProfile(
                        jwtToken: token,
                        fullName: _nameController.text.trim(),
                        staffId: _staffIdController.text.trim(),
                      );
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: result['success'] ? AppTheme.forestEmerald : Colors.red,
                          ),
                        );
                        if (result['success']) {
                          setState(() {
                             _isPersonalInfoExpanded = false;
                             _loadProfile();
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A27),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text('Save Changes', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: _isPersonalInfoExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildEditableTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: mutedTextColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.forestEmerald)),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: mutedTextColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
      ],
    );
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Log Out',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
          foregroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.15)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
