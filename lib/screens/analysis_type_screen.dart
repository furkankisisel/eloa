import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_category.dart';
import '../models/menu_section.dart';

import '../features/palmistry/screens/palmistry_home_screen.dart';

class AnalysisTypeScreen extends StatefulWidget {
  const AnalysisTypeScreen({super.key});

  @override
  State<AnalysisTypeScreen> createState() => _AnalysisTypeScreenState();
}

class _AnalysisTypeScreenState extends State<AnalysisTypeScreen> {
  AnalysisCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final sections = MenuSection.getAllSections();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Scrollable content
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    return _buildSection(context, sections[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom button
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // Logo/Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.back_hand_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ne Öğrenmek İstiyorsun?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Avucunun sırlarını keşfetmek için bir soru seç',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, MenuSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(
                section.icon,
                color: section.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: section.accentColor,
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrolling cards
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: section.categories.length,
            itemBuilder: (context, index) {
              final category = section.categories[index];
              return _buildCategoryCard(
                context,
                CategoryCardData(
                  category: category,
                  accentColor: section.accentColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryCardData data) {
    final isSelected = _selectedCategory == data.category;
    final isFull = data.category == AnalysisCategory.full;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = data.category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isFull ? 200 : 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected || isFull
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.accentColor.withOpacity(isSelected ? 0.4 : 0.25),
                    data.accentColor.withOpacity(isSelected ? 0.2 : 0.1),
                  ],
                )
              : null,
          color: isSelected || isFull ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? data.accentColor
                : isFull
                    ? data.accentColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: data.accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  data.icon,
                  color: isSelected ? data.accentColor : Colors.white70,
                  size: 28,
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: data.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              data.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? data.accentColor : Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '~${data.estimatedMinutes} dk',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Seçilen: ${_selectedCategory!.questionTitle}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCategory == null
                  ? null
                  : () {
                      final provider = context.read<AnalysisProvider>();
                      provider.selectCategory(_selectedCategory!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PalmistryHomeScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withOpacity(0.1),
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedCategory == null ? 'Bir Soru Seçin' : 'DEVAM',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
