import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
//  Sélecteur de langue : fichier isolé, indépendant de la scène d'ouverture.
//  Une fine capsule de verre fumé, bordure d'or à peine visible, deux mots
//  en petites capitales. Discret, élégant.
// ---------------------------------------------------------------------------
class SelecteurLangue extends StatelessWidget {
  final VoidCallback onFrench;
  final VoidCallback onEnglish;

  const SelecteurLangue({
    super.key,
    required this.onFrench,
    required this.onEnglish,
  });

  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.30),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _gold.withOpacity(0.5), width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentLangue(
                    label: 'FRANÇAIS',
                    semantique: 'Continuer en français',
                    onTap: onFrench,
                  ),
                ),
                Container(
                  width: 0.8,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _gold.withOpacity(0.0),
                        _gold.withOpacity(0.7),
                        _gold.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _SegmentLangue(
                    label: 'ENGLISH',
                    semantique: 'Continue in English',
                    onTap: onEnglish,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentLangue extends StatefulWidget {
  final String label;
  final String semantique;
  final VoidCallback onTap;

  const _SegmentLangue({
    required this.label,
    required this.semantique,
    required this.onTap,
  });

  @override
  State<_SegmentLangue> createState() => _SegmentLangueState();
}

class _SegmentLangueState extends State<_SegmentLangue> {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _champagne = Color(0xFFF3E5AB);
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantique,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          color: _pressed ? _gold.withOpacity(0.16) : Colors.transparent,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: GoogleFonts.montserrat(
              color: _pressed ? Colors.white : _champagne.withOpacity(0.92),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.6,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}