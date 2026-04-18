import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/module_leader_service.dart';
import '../services/guideline_service.dart';
import '../widgets/glass_container.dart';

class CreateGuidelineSheet extends StatefulWidget {
  const CreateGuidelineSheet({super.key});

  @override
  State<CreateGuidelineSheet> createState() => _CreateGuidelineSheetState();
}

class _CreateGuidelineSheetState extends State<CreateGuidelineSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  String? _selectedModuleId;
  DateTime? _selectedDeadline;
  final Set<String> _selectedDeliverables = {};
  
  bool _isLoadingModules = true;
  bool _isSubmitting = false;
  List<ModuleLeaderAcademicModule> _modules = [];
  
  final List<String> _availableDeliverables = [
    'PDF Report',
    'GitHub Repo',
    'Video Demo',
    'Live Pitch',
    'Design Mockup',
    'Code Submission',
  ];

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.accessToken;
      if (token == null) return;
      
      final service = ModuleLeaderService();
      final payload = await service.fetchAcademicModules(jwtToken: token);
      
      setState(() {
        _modules = payload.modules;
        _isLoadingModules = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load modules: $e')),
        );
        setState(() => _isLoadingModules = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.forestEmerald,
              onPrimary: Colors.white,
              surface: AppTheme.premiumBlack,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedModuleId == null) {
      _showError('Please select a module');
      return;
    }
    if (_selectedDeadline == null) {
      _showError('Please select a deadline');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final guidelineService = GuidelineService();
      
      final data = {
        'moduleId': _selectedModuleId,
        'title': _titleController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'deliverables': _selectedDeliverables.toList(),
        'deadline': _selectedDeadline!.toIso8601String(),
      };

      await guidelineService.createGuideline(data);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppTheme.premiumBlack,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Guideline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Define academic goals and deliverables for your students.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Module Selection'),
                          const SizedBox(height: 12),
                          _buildModuleSelector(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('General Information'),
                          const SizedBox(height: 12),
                          _buildGlassTextField(
                            controller: _titleController,
                            label: 'Guideline Title',
                            hint: 'e.g., Final Year Project Specifications',
                            validator: (v) => v!.isEmpty ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildGlassTextField(
                            controller: _instructionsController,
                            label: 'Instructions',
                            hint: 'Detailed expectations for the students...',
                            maxLines: 5,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Required Deliverables'),
                          const SizedBox(height: 12),
                          _buildDeliverablesWrap(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Timeline'),
                          const SizedBox(height: 12),
                          _buildDeadlineSelector(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildSubmitButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, end: 0, curve: Curves.easeOutQuart, duration: 600.ms),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppTheme.forestEmerald.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildModuleSelector() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 16,
      opacity: 0.05,
      borderColor: Colors.white.withValues(alpha: 0.1),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedModuleId,
          hint: Text(
            _isLoadingModules ? 'Loading modules...' : 'Select Target Module',
            style: const TextStyle(color: Colors.white38),
          ),
          dropdownColor: AppTheme.premiumBlack,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.forestEmerald),
          items: _modules.map((m) {
            return DropdownMenuItem(
              value: m.id,
              child: Text(
                '${m.moduleCode} - ${m.moduleName}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedModuleId = val),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: 16,
          opacity: 0.03,
          borderColor: Colors.white.withValues(alpha: 0.08),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverablesWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableDeliverables.map((label) {
        final isSelected = _selectedDeliverables.contains(label);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDeliverables.remove(label);
              } else {
                _selectedDeliverables.add(label);
              }
            });
          },
          child: AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.forestEmerald.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.forestEmerald : Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.forestEmerald.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ] : [],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeadlineSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        opacity: 0.05,
        borderColor: Colors.white.withValues(alpha: 0.1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.forestEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month, color: AppTheme.forestEmerald, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Submission Deadline', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  _selectedDeadline == null ? 'Set Date' : DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDeadline!),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestEmerald.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forestEmerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isSubmitting
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
          : const Text(
              'PUBLISH GUIDELINE',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
      ),
    );
  }
}
