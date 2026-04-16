import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F1522);
    const cardColor = Color(0xFF1A2235);
    const accentColor = Color(0xFFFACC15); // Yellow
    const mutedTextColor = Color(0xFF94A3B8); // Slate 400
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Student Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          Center(
            child: Row(
              children: [
                const Text(
                  'Pending',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildCircleButton(Icons.notifications_none, cardColor),
          const SizedBox(width: 8),
          _buildCircleButton(Icons.person_outline, cardColor),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Elena\nFisher',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Student ID: ST-2026-9482',
              style: TextStyle(
                color: mutedTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time_filled, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATUS',
                          style: TextStyle(
                            color: mutedTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PENDING',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your proposal has been submitted and is awaiting review.',
                          style: TextStyle(
                            color: mutedTextColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Proposal Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Wrap(
                     spacing: 8,
                     runSpacing: 12,
                     crossAxisAlignment: WrapCrossAlignment.center,
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                         decoration: BoxDecoration(
                           color: const Color(0xFF064E3B), // Emerald 900
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: const Text(
                           'ARTIFICIAL INTELLIGENCE',
                           style: TextStyle(
                             color: Color(0xFF34D399), // Emerald 400
                             fontSize: 10,
                             fontWeight: FontWeight.w800,
                             letterSpacing: 1.1,
                           ),
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                         decoration: BoxDecoration(
                           color: const Color(0xFF1E3A8A).withOpacity(0.4), // Blue 900
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: const [
                             Icon(Icons.edit, size: 14, color: Color(0xFF60A5FA)),
                             SizedBox(width: 4),
                             Text(
                               'Edit',
                               style: TextStyle(
                                 color: Color(0xFF60A5FA), // Blue 400
                                 fontSize: 12,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ],
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.transparent,
                           border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: const [
                             Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                             SizedBox(width: 4),
                             Text(
                               'Withdraw',
                               style: TextStyle(
                                 color: Color(0xFFEF4444),
                                 fontSize: 12,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),

                   const SizedBox(height: 24),
                   const Text(
                     'AI-Driven Climate Modeling for Urban Microclimates',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                       height: 1.3,
                     ),
                   ),
                   const SizedBox(height: 16),
                   const Text(
                     'This research focuses on leveraging machine learning to predict temperature spikes in dense urban areas, offering actionable insights for city planning and green infrastructure placement...',
                     style: TextStyle(
                       color: mutedTextColor,
                       fontSize: 14,
                       height: 1.6,
                     ),
                   ),
                   const SizedBox(height: 24),

                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: [
                       _buildTechTag('Python'),
                       _buildTechTag('TensorFlow'),
                       _buildTechTag('PostGIS'),
                       _buildTechTag('React'),
                     ],
                   ),

                   const SizedBox(height: 32),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () {},
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF2B364E), 
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(16),
                         ),
                         elevation: 0,
                       ),
                       child: const Text(
                         'Resubmit Document',
                         style: TextStyle(
                           fontSize: 14,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {},
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTechTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
