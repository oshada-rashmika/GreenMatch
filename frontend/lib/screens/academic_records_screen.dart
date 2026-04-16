import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AcademicRecordsScreen extends StatelessWidget {
  const AcademicRecordsScreen({super.key});

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
            "Academic Records",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard("Cumulative GPA", "3.85", Icons.show_chart)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard("Credits Earned", "96/120", Icons.workspace_premium)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSemesterCard(
                      semester: "Fall 2025 (Current)",
                      courses: [
                        _CourseData("CS401", "Advanced Machine Learning", "A"),
                        _CourseData("CS405", "Cloud Computing Architecture", "A-"),
                        _CourseData("MGT301", "Technology Entrepreneurship", "Pending"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSemesterCard(
                      semester: "Spring 2025",
                      courses: [
                        _CourseData("CS310", "Algorithm Design & Analysis", "A"),
                        _CourseData("CS315", "Database Systems", "A"),
                        _CourseData("CS320", "Software Engineering UI/UX", "B+"),
                        _CourseData("MAT205", "Linear Algebra II", "A-"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSemesterCard(
                      semester: "Fall 2024",
                      courses: [
                        _CourseData("CS201", "Data Structures", "A"),
                        _CourseData("CS205", "Computer Architecture", "B+"),
                        _CourseData("PHY102", "Physics for CS", "A"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      opacity: 0.05,
      borderColor: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.forestEmerald, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard({required String semester, required List<_CourseData> courses}) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      opacity: 0.03,
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Text(
                semester.toUpperCase(),
                style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          ...courses.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          c.code,
                          style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.name,
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      c.grade,
                      style: GoogleFonts.montserrat(
                        color: c.grade == "Pending" ? Colors.amber : (c.grade.startsWith("A") ? AppTheme.forestEmerald : Colors.blue),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _CourseData {
  final String code;
  final String name;
  final String grade;
  _CourseData(this.code, this.name, this.grade);
}
