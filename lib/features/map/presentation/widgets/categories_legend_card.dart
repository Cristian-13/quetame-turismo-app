import 'package:flutter/material.dart';

class CategoriesLegendCard extends StatelessWidget {
  final bool isDarkMode;

  const CategoriesLegendCard({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF2B2B2B);
    final Color subtitleColor =
        isDarkMode ? Colors.white70 : const Color(0xFF545454);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Categorías',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _LegendItem(
            label: 'Histórico',
            color: const Color(0xFF8A4B22),
            textColor: subtitleColor,
          ),
          _LegendItem(
            label: 'Naturaleza',
            color: const Color(0xFF3FA63A),
            textColor: subtitleColor,
          ),
          _LegendItem(
            label: 'Mirador',
            color: const Color(0xFF4D74D9),
            textColor: subtitleColor,
          ),
          _LegendItem(
            label: 'Gastronomía',
            color: const Color(0xFFF15A4A),
            textColor: subtitleColor,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
