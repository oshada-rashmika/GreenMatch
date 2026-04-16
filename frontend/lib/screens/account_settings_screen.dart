import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _twoFactorAuth = true;

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
            "Account Settings",
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
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
                    BoxShadow(color: AppTheme.forestEmerald.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 50)
                  ],
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  _buildSectionHeader("Security"),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: 24,
                    opacity: 0.05,
                    borderColor: Colors.white.withValues(alpha: 0.1),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline, color: Colors.white70),
                          title: Text("Change Password", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                          onTap: () {},
                        ),
                        _buildDivider(),
                        SwitchListTile(
                          activeColor: AppTheme.forestEmerald,
                          secondary: const Icon(Icons.security, color: Colors.white70),
                          title: Text("Two-Factor Authentication", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                          value: _twoFactorAuth,
                          onChanged: (val) => setState(() => _twoFactorAuth = val),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: const Icon(Icons.devices, color: Colors.white70),
                          title: Text("Active Sessions", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader("Notifications"),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: 24,
                    opacity: 0.05,
                    borderColor: Colors.white.withValues(alpha: 0.1),
                    child: Column(
                      children: [
                        SwitchListTile(
                          activeColor: AppTheme.forestEmerald,
                          secondary: const Icon(Icons.email_outlined, color: Colors.white70),
                          title: Text("Email Notifications", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                          value: _emailNotifications,
                          onChanged: (val) => setState(() => _emailNotifications = val),
                        ),
                        _buildDivider(),
                        SwitchListTile(
                          activeColor: AppTheme.forestEmerald,
                          secondary: const Icon(Icons.notifications_active_outlined, color: Colors.white70),
                          title: Text("Push Notifications", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500)),
                          value: _pushNotifications,
                          onChanged: (val) => setState(() => _pushNotifications = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader("Danger Zone"),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: 24,
                    opacity: 0.05,
                    borderColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      title: Text("Delete Account", style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.w600)),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16);
  }
}
