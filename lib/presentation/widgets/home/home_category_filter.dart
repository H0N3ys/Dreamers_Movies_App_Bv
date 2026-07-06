import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class HomeCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const HomeCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          bool isHovered = false; 

          return StatefulBuilder(
            builder: (context, setState) {
              return MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => isHovered = true),
                  onTapUp: (_) {
                    setState(() => isHovered = false);
                    onCategorySelected(index);
                  },
                  onTapCancel: () => setState(() => isHovered = false),
                  child: AnimatedScale(
                    scale: isHovered ? 1.05 : 1.0, 
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withAlpha(31) 
                            : Colors.white.withAlpha(13), 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          
                          color: isHovered 
                              ? Colors.white.withAlpha(128)
                              : isSelected
                                  ? Colors.white.withAlpha(102) 
                                  : Colors.white.withAlpha(26), 
                          width: 1.2,
                        ),
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: Colors.white.withAlpha(25), 
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [], 
                      ),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontFamily: AppTheme.secondaryFont,
                            
                            color: isSelected || isHovered ? Colors.white : Colors.white54,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }
}