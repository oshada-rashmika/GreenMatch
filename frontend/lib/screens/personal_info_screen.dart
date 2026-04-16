import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

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
            "Personal Information",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  borderRadius: 24,
                  opacity: 0.05,
                  borderColor: Colors.white.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Full Name"),
                      _buildTextField(initialValue: "Elena Fisher"),
                      const SizedBox(height: 24),
                      _buildLabel("Student ID"),
                      _buildTextField(initialValue: "ST-2026-9482", enabled: false),
                      const SizedBox(height: 24),
                      _buildLabel("Email Address"),
                      _buildTextField(initialValue: "elena.fisher@student.university.edu"),
                      const SizedBox(height: 24),
                      _buildLabel("Phone Number"),
                      _buildTextField(initialValue: "+1 (555) 019-2834"),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Degree Level"),
                                _buildTextField(initialValue: "Undergraduate", enabled: false),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Major"),
                                _buildTextField(initialValue: "Computer Science", enabled: false),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.forestEmerald,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: AppTheme.forestEmerald.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Save Changes",
                              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({required String initialValue, bool enabled = true}) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      style: GoogleFonts.montserrat(color: enabled ? Colors.white : Colors.white54, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.forestEmerald.withValues(alpha: 0.5)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }
}
