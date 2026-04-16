import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'personal_info_screen.dart';
import 'academic_records_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Student Profile", 
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: -100, 
              left: -100,
              child: Container(
                width: 300, 
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.forestEmerald.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(color: AppTheme.forestEmerald.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 50)
                  ],
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.forestEmerald.withValues(alpha: 0.5), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50, 
                        backgroundColor: Color(0xFF1E293B), 
                        child: Icon(Icons.person, size: 50, color: Colors.white)
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text("Elena Fisher", style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(height: 4),
                  Center(child: Text("Computer Science Major | ST-2026-9482", style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 13))),
                  
                  const SizedBox(height: 64),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: 24,
                    opacity: 0.05,
                    borderColor: Colors.white.withValues(alpha: 0.1),
                    child: Column(
                      children: [
                        _buildListTile(
                          Icons.person_outline, 
                          "Personal Information",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
                        ),
                        _buildDivider(),
                        _buildListTile(
                          Icons.history_edu, 
                          "Academic Records",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicRecordsScreen())),
                        ),
                        _buildDivider(),
                        _buildListTile(Icons.settings_outlined, "Account Settings"),
                        _buildDivider(),
                        _buildListTile(Icons.help_outline, "Help & Support"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: 24,
                    opacity: 0.05,
                    borderColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: Text("Log Out", style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      onTap: () {},
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16);
  }
}
