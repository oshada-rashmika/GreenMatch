import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class SupervisorProfileScreen extends StatefulWidget {
  const SupervisorProfileScreen({super.key});

  @override
  State<SupervisorProfileScreen> createState() => _SupervisorProfileScreenState();
}

class _SupervisorProfileScreenState extends State<SupervisorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.premiumBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildContactDetailsCard(),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF161616),
                  child: Icon(Icons.person_rounded, size: 60, color: Colors.white24),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.forestEmerald,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Dr. Alan Montgomery',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          Text(
            'Senior Research Supervisor',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Research Specializations: AI/ML, Automation, FullStack Dev',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
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
              const Text('CURRENT ALLOCATION',
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('4 Active Researches',
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.forestEmerald.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.forestEmerald.withOpacity(0.5)),
            ),
            child: const Text('AVAILABLE',
                style: TextStyle(color: AppTheme.forestEmerald, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildContactDetailsCard() {
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
              const Icon(Icons.badge_outlined, color: AppTheme.forestEmerald, size: 20),
              const SizedBox(width: 10),
              Text('OFFICIAL CONTACTS',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 25),
          _buildEditableInfoRow(Icons.alternate_email_rounded, 'alan.m@university.edu'),
          const Divider(color: AppTheme.glassBorder, height: 35),
          _buildEditableInfoRow(Icons.phone_iphone_rounded, '+94 77 123 4567'),
          const Divider(color: AppTheme.glassBorder, height: 35),
          _buildEditableInfoRow(Icons.business_center_outlined, 'Lab Complex, Level 04'),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // Logic to save changes
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestEmerald,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(
                'SAVE CHANGES',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(IconData icon, String data) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.forestEmerald, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Text(data, 
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15)),
        ),
        Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.2), size: 18),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
      label: Text('Go Back', 
        style: GoogleFonts.montserrat(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }
}