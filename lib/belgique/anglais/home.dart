import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belgique/belgique/anglais/bruges.dart';
import 'package:belgique/belgique/anglais/Brussels.dart';
import 'package:belgique/belgique/anglais/anvers.dart';
import 'package:belgique/belgique/anglais/Gand.dart';
import 'package:belgique/belgique/anglais/liege.dart';

class HomeEnglish extends StatefulWidget {
  const HomeEnglish({super.key});

  @override
  State<HomeEnglish> createState() => _HomeState();
}


class _HomeState extends State<HomeEnglish> with TickerProviderStateMixin {
  static const Color _bg = Color(0xFF040407);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _champagne = Color(0xFFF3E5AB);

  late final AnimationController _auroraCtrl; // dérive lente du fond
  late final AnimationController _shimmerCtrl; // reflet du titre, pulsations, zoom des photos
  late final AnimationController _entranceCtrl; // apparition en cascade
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _scrollY = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _auroraCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
    _scroll.addListener(() {
      _scrollY.value = _scroll.hasClients ? _scroll.offset : 0;
    });
  }

  @override
  void dispose() {
    _auroraCtrl.dispose();
    _shimmerCtrl.dispose();
    _entranceCtrl.dispose();
    _scroll.dispose();
    _scrollY.dispose();
    super.dispose();
  }

  final List<Map<String, String>> villes = [
    {
      'nom': 'Brussels',
      'image': 'assets4/belgique/bruxelles/77.jpg',
      'description': 'The vibrant capital, famous for its Grand-Place and lifestyle.',
    },
    {
      'nom': 'Ghent',
      'image': 'assets4/belgique/gand/11.webp',
      'description': 'A historic city with unique medieval charm, crossed by canals.',
    },
    {
      'nom': 'Bruges',
      'image': 'assets4/belgique/bruges/19.jpeg',
      'description': 'The Venice of the North, famous for its romantic canals and preserved medieval center.',
    },
    {
      'nom': 'Antwerp',
      'image': 'assets4/belgique/anvers/12.jpg',
      'description': 'The metropolis of fashion, diamonds, and Rubens\' rich heritage.',
    },
    {
      'nom': 'Liege',
      'image': 'assets4/belgique/liege/16.jpg',
      'description': 'The ardent city, renowned for its conviviality and essential waffles.',
    },
  ];

  void _afficherGenerateur(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.97,
          expand: false,
          builder: (context, scrollController) {
            return _GenerateurWidget(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _lancerRoulettePrincipale(BuildContext context) {
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Roulette',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 480),
      pageBuilder: (dialogContext, a1, a2) {
        return _RouletteDialog(villes: villes, parentContext: context);
      },
      transitionBuilder: (ctx, anim, secondary, child) {
        final CurvedAnimation curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.06, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _navigateToCityPage(BuildContext context, String nomVille) {
    Widget pageDestination;

    switch (nomVille) {
      case 'Brussels':
        pageDestination = const Brussels();
        break;
      case 'Ghent':
        pageDestination = const Gand();
        break;
      case 'Bruges':
        pageDestination = const Bruges();
        break;
      case 'Antwerp':
        pageDestination = const Anvers();
        break;
      case 'Liege':
        pageDestination = const Liege();
        break;
      default:
        pageDestination = _PlaceholderCityPage(cityName: nomVille);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pageDestination),
    );
  }

  // =========================================================================
  //  INTERFACE 2026 : aurore animée, verre fumé, or impérial, apparitions en
  //  cascade, parallaxe du titre, cartes-villes plein cadre (Ken Burns).
  // =========================================================================

  // Apparition en cascade : chaque bloc entre l'un après l'autre.
  Widget _reveal(int index, Widget child) {
    final double start = (index * 0.07).clamp(0.0, 0.8);
    final double end = (start + 0.35).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _entranceCtrl,
      child: child,
      builder: (context, ch) {
        final double p = Curves.easeOutCubic.transform(
          ((_entranceCtrl.value - start) / (end - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: p,
          child: Transform.translate(offset: Offset(0, (1 - p) * 28), child: ch),
        );
      },
    );
  }

  Widget _glass({
    required Widget child,
    double radius = 22,
    Color tint = Colors.white,
    double tintOpacity = 0.07,
    Color? border,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withOpacity(tintOpacity * 1.8),
                tint.withOpacity(tintOpacity * 0.4),
              ],
            ),
            border: Border.all(
              color: border ?? Colors.white.withOpacity(0.12),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _ornament() {
    Widget line(bool left) => Container(
      width: 46,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: left ? Alignment.centerLeft : Alignment.centerRight,
          end: left ? Alignment.centerRight : Alignment.centerLeft,
          colors: [_gold.withOpacity(0.0), _champagne.withOpacity(0.9)],
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(true),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.diamond_outlined, color: _champagne, size: 13),
        ),
        line(false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: _bg,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ---- Aurore animée (fixe, derrière le contenu) ----
              RepaintBoundary(
                child: CustomPaint(painter: _AuroraPainter(_auroraCtrl)),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _reveal(0, _buildTopBar(context)),
                      const SizedBox(height: 26),
                      _reveal(1, _buildHero()),
                      const SizedBox(height: 26),
                      _reveal(2, _buildStats()),
                      const SizedBox(height: 22),
                      _reveal(3, _buildBento(context)),
                      const SizedBox(height: 38),
                      _reveal(4, _buildSectionTitle()),
                      const SizedBox(height: 18),
                      for (int i = 0; i < villes.length; i++)
                        _reveal(5 + i, _buildVilleCard(context, i, villes[i])),
                      const SizedBox(height: 14),
                      Center(child: _ornament()),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Barre du haut : retour + favoris, en verre fumé ----
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PressScale(
          onTap: () => Navigator.pop(context),
          child: _glass(
            radius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 8),
                Text(
                  'BACK',
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        _PressScale(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const FavorisEnPage(),
                transitionDuration: const Duration(milliseconds: 520),
                reverseTransitionDuration: const Duration(milliseconds: 380),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final CurvedAnimation curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: _glass(
            radius: 30,
            tint: _gold,
            tintOpacity: 0.12,
            border: _gold.withOpacity(0.45),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, size: 14, color: _gold),
                const SizedBox(width: 8),
                Text(
                  'FAVORITES',
                  style: GoogleFonts.montserrat(
                    color: _champagne,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---- Titre : reflet d'or qui glisse + parallaxe au défilement ----
  Widget _buildHero() {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollY,
      builder: (context, y, child) {
        final double off = y.clamp(0.0, 400.0);
        return Opacity(
          opacity: (1 - off / 380).clamp(0.25, 1.0),
          child: Transform.translate(offset: Offset(0, off * 0.18), child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISCOVER',
            style: GoogleFonts.montserrat(
              color: _champagne.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (context, _) {
              final double s = _shimmerCtrl.value * 1.7 - 0.35;
              double st(double v) => v.clamp(0.0, 1.0).toDouble();
              return ShaderMask(
                shaderCallback: (Rect r) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Color(0xFFD4AF37),
                    Color(0xFFF3E5AB),
                    Color(0xFFFFFBEA),
                    Color(0xFFF3E5AB),
                    Color(0xFFD4AF37),
                  ],
                  stops: [st(s - 0.3), st(s - 0.12), st(s), st(s + 0.12), st(s + 0.3)],
                ).createShader(r),
                child: Text(
                  'Belgium',
                  style: GoogleFonts.cinzel(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    height: 1.05,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            height: 2,
            width: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color(0xFFD4AF37), Color(0xFF7A0C0C)],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore a country rich in traditions, culture and captivating urban landscapes, between historic castles and legendary sweets.',
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              color: Colors.white.withOpacity(0.68),
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Chiffres qui s'incrémentent ----
  Widget _buildStats() {
    Widget cell(int value, String label) {
      return Expanded(
        child: Column(
          children: [
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 1800),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Text(
                '$v',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _champagne,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                color: Colors.white54,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    Widget sep() => Container(
      width: 0.8,
      height: 34,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _gold.withOpacity(0.0),
            _gold.withOpacity(0.6),
            _gold.withOpacity(0.0),
          ],
        ),
      ),
    );

    return _glass(
      radius: 26,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          cell(villes.length, 'CITIES'),
          sep(),
          cell(12, 'MONTHS'),
          sep(),
          cell(2, 'TOOLS'),
        ],
      ),
    );
  }

  // ---- Deux tuiles : planificateur + roulette ----
  Widget _buildBento(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildTile(
              icon: Icons.auto_awesome_rounded,
              accent: const Color(0xFF60A5FA),
              kicker: 'PLANNER',
              titre: 'When to visit Belgium ?',
              texte: 'The best periods for each city, away from school holidays and busy weekends.',
              cta: 'LAUNCH',
              onTap: () => _afficherGenerateur(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTile(
              icon: Icons.casino_rounded,
              accent: const Color(0xFFA78BFA),
              kicker: 'UNDECIDED?',
              titre: 'The City Roulette',
              texte: 'Let chance pick your next Belgian city in a single tap.',
              cta: 'SPIN',
              onTap: () => _lancerRoulettePrincipale(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color accent,
    required String kicker,
    required String titre,
    required String texte,
    required String cta,
    required VoidCallback onTap,
  }) {
    return _PressScale(
      onTap: onTap,
      child: _glass(
        radius: 26,
        tint: accent,
        tintOpacity: 0.12,
        border: accent.withOpacity(0.35),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône qui pulse
                AnimatedBuilder(
                  animation: _shimmerCtrl,
                  builder: (context, _) {
                    final double g = 0.5 + 0.5 * sin(_shimmerCtrl.value * 2 * pi);
                    return Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.16),
                        border: Border.all(color: accent.withOpacity(0.45), width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.18 + 0.3 * g),
                            blurRadius: 8 + 14 * g,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: accent, size: 20),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  kicker,
                  style: GoogleFonts.montserrat(
                    color: accent,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  titre,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  texte,
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  cta,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: accent, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Must-See Cities',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gold.withOpacity(0.0), _champagne.withOpacity(0.9)],
            ),
          ),
        ),
      ],
    );
  }

  // ---- Carte-ville plein cadre : photo qui respire, dégradé, verre ----
  Widget _buildVilleCard(BuildContext context, int i, Map<String, String> v) {
    final String nom = v['nom']!;
    return _PressScale(
      scale: 0.975,
      onTap: () {
        HapticFeedback.selectionClick();
        _navigateToCityPage(context, nom);
      },
      child: Container(
        height: 214,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _gold.withOpacity(0.28), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: _gold.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo avec léger zoom lent (Ken Burns)
              AnimatedBuilder(
                animation: _shimmerCtrl,
                child: Image.asset(
                  v['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B1840), Color(0xFF0B0A1E)],
                      ),
                    ),
                    child: const Icon(Icons.location_city, color: Colors.white24, size: 48),
                  ),
                ),
                builder: (context, ch) {
                  final double z = 1.08 + 0.04 * sin(_shimmerCtrl.value * 2 * pi + i);
                  return Transform.scale(scale: z, child: ch);
                },
              ),
              // Dégradé de lisibilité
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.90),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              // Numéro
              Positioned(
                top: 14,
                left: 14,
                child: _glass(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    '0${i + 1}',
                    style: GoogleFonts.cinzel(
                      color: _champagne,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              // Texte
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nom,
                      style: GoogleFonts.cinzel(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      v['description']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: Colors.white.withOpacity(0.78),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'DISCOVER',
                          style: GoogleFonts.montserrat(
                            color: _champagne,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.6,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withOpacity(0.18),
                            border: Border.all(color: _gold.withOpacity(0.6), width: 0.8),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              size: 13, color: _champagne),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Fond : trois nappes de lumière (or, violet, bleu-vert) qui dérivent
//  lentement sur le noir obsidienne.
// ---------------------------------------------------------------------------
class _AuroraPainter extends CustomPainter {
  final Animation<double> t;

  _AuroraPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double a = t.value * 2 * pi;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF040407));

    void blob(Offset c, double r, Color col, double op) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withOpacity(op), col.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    blob(Offset(w * (0.18 + 0.14 * sin(a)), h * (0.10 + 0.05 * cos(a))), w * 0.85,
        const Color(0xFFD4AF37), 0.20);
    blob(Offset(w * (0.88 + 0.10 * cos(a + 1)), h * (0.38 + 0.08 * sin(a + 2))), w * 0.95,
        const Color(0xFF3B2A7A), 0.38);
    blob(Offset(w * (0.30 + 0.20 * cos(a + 3)), h * (0.78 + 0.06 * sin(a))), w * 0.95,
        const Color(0xFF0E4D5C), 0.32);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
//  Effet de pression : le bloc se contracte légèrement sous le doigt.
// ---------------------------------------------------------------------------
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const _PressScale({required this.child, required this.onTap, this.scale = 0.96});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ===========================================================================
//  BRIQUES PARTAGÉES 2026 — roulette, générateur et favoris
// ===========================================================================
const Color _kBg = Color(0xFF040407);
const Color _kGold = Color(0xFFD4AF37);
const Color _kChampagne = Color(0xFFF3E5AB);

const Map<String, String> _kVilleImages = {
  'Brussels': 'assets4/belgique/bruxelles/77.jpg',
  'Ghent': 'assets4/belgique/gand/11.webp',
  'Bruges': 'assets4/belgique/bruges/19.jpeg',
  'Antwerp': 'assets4/belgique/anvers/12.jpg',
  'Liege': 'assets4/belgique/liege/16.jpg',
};

Widget _photo(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Container(
      width: width,
      height: height,
      color: const Color(0xFF14141C),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 22),
    ),
  );
}

Widget _glassBox({
  required Widget child,
  double radius = 22,
  Color tint = Colors.white,
  double tintOpacity = 0.07,
  Color? border,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  double blur = 16,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint.withOpacity(tintOpacity * 1.8),
              tint.withOpacity(tintOpacity * 0.4),
            ],
          ),
          border: Border.all(color: border ?? Colors.white.withOpacity(0.12), width: 0.8),
        ),
        child: child,
      ),
    ),
  );
}

// ---- Fond aurore réutilisable (couleurs au choix) ----
class _AuroraBackdrop extends StatefulWidget {
  final Color a;
  final Color b;
  final Color c;
  const _AuroraBackdrop({
    this.a = const Color(0xFFD4AF37),
    this.b = const Color(0xFF3B2A7A),
    this.c = const Color(0xFF0E4D5C),
  });

  @override
  State<_AuroraBackdrop> createState() => _AuroraBackdropState();
}

class _AuroraBackdropState extends State<_AuroraBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TintAuroraPainter(_ctrl, widget.a, widget.b, widget.c),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TintAuroraPainter extends CustomPainter {
  final Animation<double> t;
  final Color a;
  final Color b;
  final Color c;
  _TintAuroraPainter(this.t, this.a, this.b, this.c) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double k = t.value * 2 * pi;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _kBg);

    void blob(Offset center, double r, Color col, double op) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withOpacity(op), col.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    blob(Offset(w * (0.15 + 0.14 * sin(k)), h * (0.08 + 0.05 * cos(k))), w * 0.85, a, 0.22);
    blob(Offset(w * (0.90 + 0.10 * cos(k + 1)), h * (0.40 + 0.08 * sin(k + 2))), w * 0.95, b, 0.36);
    blob(Offset(w * (0.30 + 0.20 * cos(k + 3)), h * (0.85 + 0.06 * sin(k))), w * 0.95, c, 0.30);
  }

  @override
  bool shouldRepaint(covariant _TintAuroraPainter oldDelegate) => false;
}

// ---- Apparition douce (fondu + glissement), avec délai ----
class _Reveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double dy;
  const _Reveal({super.key, required this.child, this.delayMs = 0, this.dy = 24});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      child: widget.child,
      builder: (context, ch) {
        final double p = Curves.easeOutCubic.transform(_ctrl.value);
        return Opacity(
          opacity: p,
          child: Transform.translate(offset: Offset(0, (1 - p) * widget.dy), child: ch),
        );
      },
    );
  }
}

// ---- Texte avec reflet d'or qui glisse ----
class _GoldShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign? align;
  const _GoldShimmerText(this.text, {required this.style, this.align});

  @override
  State<_GoldShimmerText> createState() => _GoldShimmerTextState();
}

class _GoldShimmerTextState extends State<_GoldShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final double s = _ctrl.value * 1.7 - 0.35;
        double st(double v) => v.clamp(0.0, 1.0).toDouble();
        return ShaderMask(
          shaderCallback: (Rect r) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFFD4AF37),
              Color(0xFFF3E5AB),
              Color(0xFFFFFBEA),
              Color(0xFFF3E5AB),
              Color(0xFFD4AF37),
            ],
            stops: [st(s - 0.3), st(s - 0.12), st(s), st(s + 0.12), st(s + 0.3)],
          ).createShader(r),
          child: Text(
            widget.text,
            textAlign: widget.align,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}

// ---- Anneaux qui pulsent (écran d'analyse) ----
class _PulseRings extends StatefulWidget {
  final double size;
  final IconData icon;
  const _PulseRings({this.size = 130, this.icon = Icons.travel_explore_rounded});

  @override
  State<_PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<_PulseRings> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingsPainter(_ctrl.value),
            ),
          ),
          Container(
            width: widget.size * 0.42,
            height: widget.size * 0.42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withOpacity(0.12),
              border: Border.all(color: _kGold.withOpacity(0.5), width: 0.8),
            ),
            child: Icon(widget.icon, color: _kChampagne, size: widget.size * 0.2),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double t;
  _RingsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    for (int k = 0; k < 3; k++) {
      final double p = (t + k / 3) % 1.0;
      canvas.drawCircle(
        c,
        size.width / 2 * p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = _kGold.withOpacity((1 - p) * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) => oldDelegate.t != t;
}

// ---- Cœur flottant (état vide des favoris) ----
class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart();

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final double t = Curves.easeInOut.transform(_ctrl.value);
        return Transform.translate(
          offset: Offset(0, -10 * t),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_kGold.withOpacity(0.22), _kGold.withOpacity(0.04)],
              ),
              border: Border.all(color: _kGold.withOpacity(0.4), width: 0.8),
              boxShadow: [
                BoxShadow(color: _kGold.withOpacity(0.16 + 0.22 * t), blurRadius: 30 + 22 * t),
              ],
            ),
            child: const Icon(Icons.favorite_border_rounded, color: _kGold, size: 40),
          ),
        );
      },
    );
  }
}

// ---- Carte d'un mois (dépliable) ----
class _MonthCard extends StatefulWidget {
  final Map<String, dynamic> m;
  const _MonthCard({required this.m});

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _open = false;

  IconData _iconeSaison(String s) {
    switch (s) {
      case 'Winter':
        return Icons.ac_unit_rounded;
      case 'Spring':
        return Icons.local_florist_rounded;
      case 'Summer':
        return Icons.wb_sunny_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool bon = widget.m['estBon'] == true;
    final Color accent = bon ? const Color(0xFF34D399) : const Color(0xFFF87171);
    final String saison = widget.m['saison'].toString();

    return _PressScale(
      scale: 0.985,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _open = !_open);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withOpacity(0.11), accent.withOpacity(0.02)],
          ),
          border: Border.all(color: accent.withOpacity(0.28), width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [accent, accent.withOpacity(0.1)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.14),
                            border: Border.all(color: accent.withOpacity(0.35), width: 0.8),
                          ),
                          child: Icon(_iconeSaison(saison), color: accent, size: 17),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.m['nom'].toString(),
                                style: GoogleFonts.cinzel(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                saison.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  color: Colors.white54,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                bon ? Icons.check_circle_rounded : Icons.do_not_disturb_on_rounded,
                                size: 12,
                                color: accent,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                bon ? 'IDEAL' : 'AVOID',
                                style: GoogleFonts.montserrat(
                                  color: accent,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: Text(
                        widget.m['raison'].toString(),
                        maxLines: _open ? 40 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 12.5,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _open ? 'COLLAPSE' : 'READ MORE',
                          style: GoogleFonts.montserrat(
                            color: accent,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutCubic,
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  ROULETTE DES VILLES — plein écran immersif : photo floutée en fond, cadran
//  doré qui tourne, ralentissement progressif, explosion d'étincelles.
// ===========================================================================
class _RouletteDialog extends StatefulWidget {
  final List<Map<String, String>> villes;
  final BuildContext parentContext;

  const _RouletteDialog({required this.villes, required this.parentContext});

  @override
  State<_RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<_RouletteDialog> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFinished = false;
  String _selectedVille = '';
  int _token = 0;

  late final AnimationController _ringCtrl;
  late final AnimationController _burstCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    _burstCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _lancer();
  }

  @override
  void dispose() {
    _token++;
    _ringCtrl.dispose();
    _burstCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // Tirage : les images défilent vite puis ralentissent jusqu'à l'arrêt.
  Future<void> _lancer() async {
    final int mine = ++_token;
    final Random rnd = Random();
    final int n = widget.villes.length;
    final int total = 24 + rnd.nextInt(6);
    int last = _currentIndex;

    if (mounted) {
      setState(() {
        _isFinished = false;
        _selectedVille = '';
      });
    }
    _burstCtrl.reset();

    for (int i = 0; i < total; i++) {
      if (!mounted || mine != _token) return;
      int next;
      do {
        next = rnd.nextInt(n);
      } while (next == last && n > 1);
      last = next;
      setState(() => _currentIndex = next);
      HapticFeedback.selectionClick();
      final double t = i / (total - 1);
      await Future.delayed(Duration(milliseconds: (55 + 330 * pow(t, 2.6)).round()));
    }

    if (!mounted || mine != _token) return;
    setState(() {
      _isFinished = true;
      _selectedVille = widget.villes[_currentIndex]['nom']!;
    });
    HapticFeedback.heavyImpact();
    _burstCtrl.forward(from: 0);
  }

  void _naviguerVersVilleSelectionnee() {
    Navigator.pop(context);
    Widget pageDestination;

    switch (_selectedVille) {
      case 'Brussels':
        pageDestination = const Brussels();
        break;
      case 'Ghent':
        pageDestination = const Gand();
        break;
      case 'Bruges':
        pageDestination = const Bruges();
        break;
      case 'Antwerp':
        pageDestination = const Anvers();
        break;
      case 'Liege':
        pageDestination = const Liege();
        break;
      default:
        pageDestination = _PlaceholderCityPage(cityName: _selectedVille);
    }

    Navigator.push(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => pageDestination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int n = widget.villes.length;
    final Map<String, String> ville = widget.villes[_currentIndex];
    final Map<String, String> prev = widget.villes[(_currentIndex - 1 + n) % n];
    final Map<String, String> next = widget.villes[(_currentIndex + 1) % n];
    final Size size = MediaQuery.of(context).size;
    final double dial = min(min(size.width * 0.64, size.height * 0.32), 280.0);
    final double box = dial + 56;

    TextStyle ghost = GoogleFonts.cinzel(
      color: Colors.white.withOpacity(0.2),
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 3,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Fond : photo de la ville courante, floutée ----
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              child: KeyedSubtree(
                key: ValueKey<String>(ville['image']!),
                child: Transform.scale(
                  scale: 1.25,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: _photo(ville['image']!, width: double.infinity, height: double.infinity),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.62),
                    Colors.black.withOpacity(0.78),
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CITY ROULETTE',
                        style: GoogleFonts.montserrat(
                          color: _kChampagne.withOpacity(0.9),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.4,
                        ),
                      ),
                      _PressScale(
                        onTap: () => Navigator.pop(context),
                        child: _glassBox(
                          radius: 30,
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ---- Cadran ----
                        SizedBox(
                          width: box,
                          height: box,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (context, _) {
                                  final double g = _pulseCtrl.value;
                                  return Container(
                                    width: dial,
                                    height: dial,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _kGold.withOpacity(_isFinished ? 0.34 + 0.24 * g : 0.10 + 0.10 * g),
                                          blurRadius: 44 + 30 * g,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              ClipOval(
                                child: SizedBox(
                                  width: dial - 28,
                                  height: dial - 28,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 170),
                                    transitionBuilder: (child, anim) => FadeTransition(
                                      opacity: anim,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
                                        child: child,
                                      ),
                                    ),
                                    child: KeyedSubtree(
                                      key: ValueKey<int>(_currentIndex),
                                      child: _photo(
                                        ville['image']!,
                                        width: dial - 28,
                                        height: dial - 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _ringCtrl,
                                  builder: (context, _) => CustomPaint(
                                    size: Size(box, box),
                                    painter: _DialPainter(rotation: _ringCtrl.value, finished: _isFinished),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _burstCtrl,
                                  builder: (context, _) => CustomPaint(
                                    size: Size(box, box),
                                    painter: _BurstPainter(_burstCtrl.value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ---- Nom de la ville (effet « rouleau ») ----
                        Text(prev['nom']!.toUpperCase(), style: ghost),
                        SizedBox(
                          height: 58,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(anim),
                                child: child,
                              ),
                            ),
                            child: _isFinished
                                ? ShaderMask(
                              key: ValueKey<String>('fin-${ville['nom']}'),
                              shaderCallback: (r) => const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFFFFBEA), Color(0xFFD4AF37)],
                              ).createShader(r),
                              child: Text(
                                ville['nom']!,
                                style: GoogleFonts.cinzel(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                            )
                                : Text(
                              ville['nom']!,
                              key: ValueKey<String>('run-${ville['nom']}'),
                              style: GoogleFonts.cinzel(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                        Text(next['nom']!.toUpperCase(), style: ghost),
                        const SizedBox(height: 14),

                        // ---- Statut / description ----
                        SizedBox(
                          height: 64,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 450),
                            child: _isFinished
                                ? Padding(
                              key: const ValueKey<String>('desc'),
                              padding: const EdgeInsets.symmetric(horizontal: 34),
                              child: Text(
                                ville['description']!,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12.5,
                                  height: 1.55,
                                ),
                              ),
                            )
                                : AnimatedBuilder(
                              key: const ValueKey<String>('status'),
                              animation: _pulseCtrl,
                              builder: (context, _) => Center(
                                child: Opacity(
                                  opacity: 0.45 + 0.55 * _pulseCtrl.value,
                                  child: Text(
                                    'SPINNING...',
                                    style: GoogleFonts.montserrat(
                                      color: _kChampagne,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- Actions ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                  child: AnimatedOpacity(
                    opacity: _isFinished ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: IgnorePointer(
                      ignoring: !_isFinished,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PressScale(
                            onTap: _naviguerVersVilleSelectionnee,
                            child: Container(
                              height: 56,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB), Color(0xFFD4AF37)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kGold.withOpacity(0.4),
                                    blurRadius: 26,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'DISCOVER ${(_selectedVille.isEmpty ? ville['nom']! : _selectedVille).toUpperCase()}',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.black87, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PressScale(
                            onTap: _lancer,
                            child: _glassBox(
                              radius: 28,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.refresh_rounded, color: Colors.white70, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SPIN AGAIN',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.2,
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }
}

// ---- Cadran : graduations dorées, tête lumineuse qui tourne ----
class _DialPainter extends CustomPainter {
  final double rotation;
  final bool finished;
  _DialPainter({required this.rotation, required this.finished});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2 - 16;
    const int n = 72;

    for (int i = 0; i < n; i++) {
      final double a = i * 2 * pi / n - pi / 2;
      final bool major = i % 6 == 0;
      double glow;
      if (finished) {
        glow = 1.0;
      } else {
        double d = (i / n - rotation) % 1.0;
        if (d < 0) d += 1.0;
        glow = pow(1 - d, 5).toDouble();
      }
      final double len = major ? 13 : 7;
      final Paint p = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = major ? 2.2 : 1.3
        ..color = Color.lerp(Colors.white.withOpacity(major ? 0.24 : 0.12), _kGold, glow)!;
      final Offset dir = Offset(cos(a), sin(a));
      canvas.drawLine(c + dir * r, c + dir * (r - len), p);
    }

    canvas.drawCircle(
      c,
      r - 22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _kGold.withOpacity(finished ? 0.8 : 0.3),
    );

    // Repère triangulaire en haut
    final Path tri = Path()
      ..moveTo(c.dx - 6, c.dy - r - 13)
      ..lineTo(c.dx + 6, c.dy - r - 13)
      ..lineTo(c.dx, c.dy - r - 3)
      ..close();
    canvas.drawPath(tri, Paint()..color = _kChampagne);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.rotation != rotation || old.finished != finished;
}

// ---- Étincelles dorées à l'arrêt de la roulette ----
class _BurstPainter extends CustomPainter {
  final double t;
  _BurstPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2 - 16;
    final double e = Curves.easeOutCubic.transform(t);
    final double fade = (1 - t).clamp(0.0, 1.0).toDouble();

    for (int i = 0; i < 36; i++) {
      final double a = i * 2 * pi / 36 + (i % 3) * 0.12;
      final double spread = 0.85 + 0.35 * ((i * 7) % 5) / 5;
      final double dist = r * (0.7 + 0.8 * e) * spread;
      final Offset pos = c + Offset(cos(a), sin(a)) * dist;
      canvas.drawCircle(
        pos,
        3.2 * (1 - t) + 0.8,
        Paint()..color = (i.isEven ? _kGold : _kChampagne).withOpacity(fade),
      );
    }

    canvas.drawCircle(
      c,
      r * (0.8 + 0.7 * e),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * (1 - t)
        ..color = _kChampagne.withOpacity(fade * 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

// --- GENERATOR ---
class _GenerateurWidget extends StatefulWidget {
  final ScrollController scrollController;

  const _GenerateurWidget({required this.scrollController});

  @override
  State<_GenerateurWidget> createState() => _GenerateurWidgetState();
}

class _GenerateurWidgetState extends State<_GenerateurWidget> {
  final List<String> toutesLesVilles = ['Brussels', 'Ghent', 'Bruges', 'Antwerp', 'Liege'];

  String? villeSelectionnee;
  bool estEnGenerationVitesse = false;
  bool estGenere = false;

  String affichageVitesseTexte = "DATABASE ANALYSIS...";
  int compteurVitesse = 0;
  Timer? _timerVitesse;
  String villeOngletActif = '';

  @override
  void dispose() {
    _timerVitesse?.cancel();
    super.dispose();
  }

  void _lancerGenerationHauteVitesse() {
    if (villeSelectionnee == null) return;

    setState(() {
      estEnGenerationVitesse = true;
      estGenere = false;
      compteurVitesse = 0;
      villeOngletActif = villeSelectionnee!;
    });

    final random = Random();
    final etapesTexte = [
      "CONNECTING TO DATABASE...",
      "ANALYZING RECOMMENDED PERIODS...",
      "ANALYZING PERIODS TO AVOID...",
      "ANALYZING SEASONS...",
      "GENERATING ADVICE...",
    ];

    _timerVitesse?.cancel();
    _timerVitesse = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;
      setState(() {
        compteurVitesse++;
        affichageVitesseTexte = etapesTexte[random.nextInt(etapesTexte.length)] +
            " [${random.nextInt(99)}%]";
      });

      if (compteurVitesse >= 32) {
        timer.cancel();
        if (mounted) {
          setState(() {
            estEnGenerationVitesse = false;
            estGenere = true;
          });
        }
      }
    });
  }

  List<Map<String, dynamic>> _getMoisPourVille(String nomVille) {
    if (nomVille == 'Brussels') {
      return [
        {'nom': 'January', 'estBon': false, 'saison': 'Winter', 'raison': 'January in Brussels is particularly harsh, marked by persistent gray skies and cold winds blowing across the Grand-Place cobblestones. Light is extremely low, tarnishing the Art Nouveau architecture and making outdoor walks less pleasant. It is best to focus on indoor museum visits.'},
        {'nom': 'February', 'estBon': false, 'saison': 'Winter', 'raison': 'February shows little improvement, with ambient humidity making temperatures feel much lower than they actually are. Days are short and often rainy, turning walks between Mont des Arts and neighborhoods into a struggle. Avoid if you want a serene urban discovery.'},
        {'nom': 'March', 'estBon': true, 'saison': 'Spring', 'raison': 'March brings a breath of renewal, with longer days and sunlight starting to warm the historic stones of the city center. It is ideal for a first spring visit before tourist crowds arrive. Weekday visits offer exceptional tranquility.'},
        {'nom': 'April', 'estBon': true, 'saison': 'Spring', 'raison': 'April is magical in Brussels, thanks to the opening of the Royal Greenhouses of Laeken offering a stunning floral spectacle. The climate is milder, perfect for urban parks and opening terraces. A great window for cultural getaways on weekdays.'},
        {'nom': 'May', 'estBon': true, 'saison': 'Spring', 'raison': 'May is undoubtedly one of the best months to explore the European capital, with ideal walking temperatures. The atmosphere is festive, parks like Cinquantenaire are resplendent, and social life thrives. Weekday visits guarantee a fluid experience.'},
        {'nom': 'June', 'estBon': false, 'saison': 'Summer', 'raison': 'June marks the start of high tourist season, leading to gradual crowding at iconic sites like Atomium and Manneken-Pis. Queues grow significant and accommodation prices climb, making it less attractive than spring.'},
        {'nom': 'July', 'estBon': false, 'saison': 'Summer', 'raison': 'July is peak holiday season, with the city center submerged by international visitors. Urban heat can become oppressive, making long walks exhausting. Booking tables or visiting attractions requires patience under intense sun.'},
        {'nom': 'August', 'estBon': false, 'saison': 'Summer', 'raison': 'August maintains high tourist pressure with peak occupancy in historic sites and hotels. The city is loud and busy, less restful for a cultural getaway due to high temperatures and crowds.'},
        {'nom': 'September', 'estBon': true, 'saison': 'Autumn', 'raison': 'September offers a wonderful transition with mild weather and golden light enhancing historic facades. Back-to-school means significant calm, making museums more accessible and hotel rates more affordable on weekdays.'},
        {'nom': 'October', 'estBon': true, 'saison': 'Autumn', 'raison': 'Autumn sets in smoothly, painting Brussels parks in orange hues for photogenic and relaxing walks. Climate is still great for architecture without summer heat or winter cold. A serene period for local culture.'},
        {'nom': 'November', 'estBon': true, 'saison': 'Autumn', 'raison': 'November is a calm transitional month free of tourist frenzy, leaving space for an authentic atmosphere. Cooler temperatures invite cozy traditional tea rooms. Weekday visits offer full intimacy.'},
        {'nom': 'December', 'estBon': false, 'saison': 'Winter', 'raison': 'While December attracts visitors for "Winter Pleasures", weekends bring extreme crowding in the historic center. Human density around Christmas markets makes strolling difficult and hides the capital\'s usual charm.'},
      ];
    } else if (nomVille == 'Ghent') {
      return [
        {'nom': 'January', 'estBon': false, 'saison': 'Winter', 'raison': 'January in Ghent means sharp North Sea winds sweeping along canals, making walks along Graslei quite uncomfortable. Short days limit enjoying historic facades under low gray skies.'},
        {'nom': 'February', 'estBon': false, 'saison': 'Winter', 'raison': 'February remains unstable and cold with fine rain risks making slippery cobblestones. Fog can hide the Belfry or Castle of the Counts. Best reserved for indoor museum lovers.'},
        {'nom': 'March', 'estBon': true, 'saison': 'Spring', 'raison': 'March brings renewal as the sun pierces clouds, lighting up Lys river reflections. A great compromise between winter and spring. Weekday visits avoid weekend crowds.'},
        {'nom': 'April', 'estBon': true, 'saison': 'Spring', 'raison': 'April reveals Ghent\'s bucolic charm with greener banks and lively student terraces. Great climate for walking or cycling along canals before high season starts.'},
        {'nom': 'May', 'estBon': true, 'saison': 'Spring', 'raison': 'May is arguably one of the best moments to experience Ghent, with mild temperatures and sunlight highlighting medieval heritage. Weekday visits ensure an authentic local immersion.'},
        {'nom': 'June', 'estBon': false, 'saison': 'Summer', 'raison': 'June brings heavy tourist flows, making landmarks like Graslei busy at any sunny moment. Alleys get crowded and accommodation prices rise.'},
        {'nom': 'July', 'estBon': false, 'saison': 'Summer', 'raison': 'July is dominated by the Ghent Festivities, turning the city into a giant festival. While vibrant, it makes classical heritage discovery extremely difficult due to crowds and street occupation.'},
        {'nom': 'August', 'estBon': false, 'saison': 'Summer', 'raison': 'August keeps high tourist density saturating major attractions and canal views. Heat can be tiring during historic walks, and restaurant reservations become challenging.'},
        {'nom': 'September', 'estBon': true, 'saison': 'Autumn', 'raison': 'September offers a soothing break with mild temperatures and late-season light. Vacationers leaving restores balance, allowing history exploration without crowds on weekdays.'},
        {'nom': 'October', 'estBon': true, 'saison': 'Autumn', 'raison': 'October wraps Ghent in a romantic vibe as canal-side trees wear warm colors. Ideal for local art and cozy museums with minimal tourists.'},
        {'nom': 'November', 'estBon': true, 'saison': 'Autumn', 'raison': 'November is a period of deep calm, perfect for an intimate discovery. Enjoy traditional brasseries and art galleries without time pressure on weekdays.'},
        {'nom': 'December', 'estBon': false, 'saison': 'Winter', 'raison': 'December brings heavy weekend crowds due to illuminations and Christmas markets, making downtown very busy. Humid cold makes long strolls difficult.'},
      ];
    } else if (nomVille == 'Bruges') {
      return [
        {'nom': 'January', 'estBon': false, 'saison': 'Winter', 'raison': 'January in Bruges features intense cold making canal walks unpleasant with winds between medieval buildings. Many tourist activities slow down or close.'},
        {'nom': 'February', 'estBon': false, 'saison': 'Winter', 'raison': 'February climate remains harsh with freezing rain risks and dark days tarnishing picturesque facades. Slippery historic cobblestones discourage free wandering.'},
        {'nom': 'March', 'estBon': true, 'saison': 'Spring', 'raison': 'March marks the return of light and mildness. Mass tourists are still absent, offering a rare chance to photograph the Belfry or Rozenhoedkaai in silence on weekdays.'},
        {'nom': 'April', 'estBon': true, 'saison': 'Spring', 'raison': 'April adorns Bruges with spring flowers in gardens and beguinages, creating postcard settings. Pleasant weather is perfect for boat rides on canals.'},
        {'nom': 'May', 'estBon': true, 'saison': 'Spring', 'raison': 'May is breathtaking in Bruges with ideal weather and spring light enhancing Flemish architecture. Best planned outside weekends to keep the magic intact.'},
        {'nom': 'June', 'estBon': false, 'saison': 'Summer', 'raison': 'June sees massive international visitors saturating downtown Bruges, making pedestrian traffic difficult and turning romantic ambiance busy.'},
        {'nom': 'July', 'estBon': false, 'saison': 'Summer', 'raison': 'July is peak summer crowd season where Bruges loses some identity to mass tourism. Tight alleys trap heat, and restaurant offers saturate.'},
        {'nom': 'August', 'estBon': false, 'saison': 'Summer', 'raison': 'August maintains continuous tourist streams occupying every corner of the historic center. Accommodation prices peak and chocolate shops are packed.'},
        {'nom': 'September', 'estBon': true, 'saison': 'Autumn', 'raison': 'September offers a welcome relief with lower attendance, returning Bruges to its slow pace and poetic charm. Great weather for climbing the Belfry.'},
        {'nom': 'October', 'estBon': true, 'saison': 'Autumn', 'raison': 'October drapes Bruges in mysterious autumn mist over canals, creating unforgettable photo settings. Quiet and peaceful on weekdays.'},
        {'nom': 'November', 'estBon': true, 'saison': 'Autumn', 'raison': 'November brings cozy atmosphere and absolute tranquility to Bruges paved streets. Perfect for visiting museums without waiting.'},
        {'nom': 'December', 'estBon': false, 'saison': 'Winter', 'raison': 'Christmas in Bruges is visually magical but attracts packed crowds on Saturdays and Sundays. Sharp cold makes queuing difficult.'},
      ];
    } else if (nomVille == 'Antwerp') {
      return [
        {'nom': 'January', 'estBon': false, 'saison': 'Winter', 'raison': 'Antwerp in January faces cold winds blowing straight from the Scheldt, making quay walks freezing. Gray weather slows down outdoor city exploration.'},
        {'nom': 'February', 'estBon': false, 'saison': 'Winter', 'raison': 'February features persistent gray skies and frequent rain dimming historic squares. Cold and humid weather discourages outdoor heritage discovery.'},
        {'nom': 'March', 'estBon': true, 'saison': 'Spring', 'raison': 'March marks a pleasant cultural awakening with brighter days inviting strolls along Meir. Mild temperatures make Rubens house visits pleasant on weekdays.'},
        {'nom': 'April', 'estBon': true, 'saison': 'Spring', 'raison': 'April animates Antwerp under spring sun, offering ideal conditions to explore creative districts and Scheldt banks. Terraces open up.'},
        {'nom': 'May', 'estBon': true, 'saison': 'Spring', 'raison': 'May is a flagship month for Antwerp with sunny weather magnifying avant-garde and historic architecture. Tuesday-to-Thursday stays offer ideal immersion.'},
        {'nom': 'June', 'estBon': false, 'saison': 'Summer', 'raison': 'June brings rising tourist numbers in shopping zones and Central Station. Warm temperatures and urban hustle make visits less relaxing.'},
        {'nom': 'July', 'estBon': false, 'saison': 'Summer', 'raison': 'July school holidays saturate Antwerp public spaces. Concrete heat makes long walks tiring and major monuments crowded.'},
        {'nom': 'August', 'estBon': false, 'saison': 'Summer', 'raison': 'August heatwaves turn city center into a furnace. Restaurants and attractions stay fully booked, requiring rigorous planning.'},
        {'nom': 'September', 'estBon': true, 'saison': 'Autumn', 'raison': 'September returns to a balanced atmosphere with mild weather for urban exploring. Museums regain calm for art lovers.'},
        {'nom': 'October', 'estBon': true, 'saison': 'Autumn', 'raison': 'October highlights station and historic streets with golden autumn light. Perfect to discover Rubens heritage in a cozy atmosphere.'},
        {'nom': 'November', 'estBon': true, 'saison': 'Autumn', 'raison': 'November is great for culture lovers diving into galleries and museums away from tourist pressure. City is quiet and introspective.'},
        {'nom': 'December', 'estBon': false, 'saison': 'Winter', 'raison': 'December turns Antwerp into frantic shopping destination with overwhelming crowds in commercial streets. Weekends should be avoided.'},
      ];
    } else { // Liege
      return [
        {'nom': 'January', 'estBon': false, 'saison': 'Winter', 'raison': 'January in Liege features sharp cold worsened by Meuse humidity. Famous stairs like Montagne de Bueren become slippery and dangerous.'},
        {'nom': 'February', 'estBon': false, 'saison': 'Winter', 'raison': 'February weather remains heavy and foggy, hiding Meuse valley views from Citadel heights. Winter grayness weighs on outdoor activities.'},
        {'nom': 'March', 'estBon': true, 'saison': 'Spring', 'raison': 'March brings a welcome awakening with milder days to enjoy Liege without winter cold. Weekday visits preserve authentic local charm.'},
        {'nom': 'April', 'estBon': true, 'saison': 'Spring', 'raison': 'April brings vibrant spring energy with green hillsides and lively streets. Perfect conditions to explore historic center alleys on weekdays.'},
        {'nom': 'May', 'estBon': true, 'saison': 'Spring', 'raison': 'May is a blessed month for Liege with blooming parks and pleasant weather. Meuse riverbank terraces invite relaxation.'},
        {'nom': 'June', 'estBon': false, 'saison': 'Summer', 'raison': 'June temperature rises can make bowl-shaped city exploration stifling. Intense nightlife disrupts quiet cultural visits.'},
        {'nom': 'July', 'estBon': false, 'saison': 'Summer', 'raison': 'July holiday heat traps in narrow alleys, making urban walks exhausting. Local summer events saturate city infrastructure.'},
        {'nom': 'August', 'estBon': false, 'saison': 'Summer', 'raison': 'August features major folklore events like Outremeuse festivities which paralyze classical tourist visits due to crowds and access rules.'},
        {'nom': 'September', 'estBon': true, 'saison': 'Autumn', 'raison': 'September offers a welcome break with mild autumn weather and serene atmosphere. Perfect for history lovers exploring without stress.'},
        {'nom': 'October', 'estBon': true, 'saison': 'Autumn', 'raison': 'October is romantic in Liege as Citadel hills wear gorgeous colors. Quiet city invites peaceful old-alley strolls.'},
        {'nom': 'November', 'estBon': true, 'saison': 'Autumn', 'raison': 'November offers an intimate way to discover Liege museums without waiting lines. Enjoy warm local culinary traditions.'},
        {'nom': 'December', 'estBon': false, 'saison': 'Winter', 'raison': 'December brings the Christmas Village, attracting monumental crowds that complicate downtown traffic and cultural visits.'},
      ];
    }
  }

  Widget _sectionLabel(String t) {
    return Row(
      children: [
        Text(
          t,
          style: GoogleFonts.montserrat(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_kGold.withOpacity(0.5), _kGold.withOpacity(0.0)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color col, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: col.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: col),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: col,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Tuile photo d'une ville (sélection animée) ----
  Widget _villeCard(String ville) {
    final bool sel = villeSelectionnee == ville;
    return _PressScale(
      scale: 0.95,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (sel) {
            villeSelectionnee = null;
            villeOngletActif = '';
            estGenere = false;
          } else {
            villeSelectionnee = ville;
            villeOngletActif = ville;
            estGenere = false;
          }
        });
      },
      child: AnimatedScale(
        scale: sel ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: 108,
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: sel ? _kGold : Colors.white.withOpacity(0.12),
              width: sel ? 1.6 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: sel ? _kGold.withOpacity(0.38) : Colors.black.withOpacity(0.45),
                blurRadius: sel ? 24 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: sel ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  child: _photo(_kVilleImages[ville] ?? ''),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(sel ? 0.05 : 0.25),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 12,
                  child: Text(
                    ville,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: sel ? _kChampagne : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedScale(
                    scale: sel ? 1 : 0,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: _kGold),
                      child: const Icon(Icons.check_rounded, size: 14, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCta() {
    final bool enabled = villeSelectionnee != null && !estEnGenerationVitesse;
    final String label = villeSelectionnee == null
        ? 'CHOOSE A CITY'
        : (estEnGenerationVitesse ? 'ANALYSIS IN PROGRESS' : 'GENERATE MY PLAN');
    return _PressScale(
      onTap: () {
        if (enabled) {
          HapticFeedback.mediumImpact();
          _lancerGenerationHauteVitesse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: enabled
              ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB), Color(0xFFD4AF37)])
              : LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.04)]),
          border: Border.all(
            color: enabled ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 0.8,
          ),
          boxShadow: enabled
              ? [BoxShadow(color: _kGold.withOpacity(0.38), blurRadius: 26, offset: const Offset(0, 8))]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (estEnGenerationVitesse)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
              )
            else
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: enabled ? Colors.black87 : Colors.white30,
              ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                label,
                key: ValueKey<String>(label),
                style: GoogleFonts.montserrat(
                  color: enabled ? Colors.black87 : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Écran d'analyse : anneaux + barre de progression dorée ----
  Widget _buildScanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: Column(
          children: [
            const _PulseRings(size: 140),
            const SizedBox(height: 22),
            Text(
              affichageVitesseTexte,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: _kChampagne,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 230,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: (compteurVitesse / 32).clamp(0.0, 1.0).toDouble()),
                duration: const Duration(milliseconds: 160),
                builder: (context, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 3,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kGold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Résultats : bannière photo, frise annuelle, cartes des mois ----
  Widget _buildResultats(List<Map<String, dynamic>> mois) {
    final int bons = mois.where((m) => m['estBon'] == true).length;
    final int mauvais = mois.length - bons;
    const Color vert = Color(0xFF34D399);
    const Color rouge = Color(0xFFF87171);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 172,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _kGold.withOpacity(0.35), width: 0.8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 22, offset: const Offset(0, 10)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.18, end: 1.0),
                  duration: const Duration(milliseconds: 1800),
                  curve: Curves.easeOutCubic,
                  builder: (context, s, child) => Transform.scale(scale: s, child: child),
                  child: _photo(_kVilleImages[villeOngletActif] ?? ''),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.88)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YEARLY ANALYSIS',
                        style: GoogleFonts.montserrat(
                          color: _kChampagne.withOpacity(0.85),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _GoldShimmerText(
                        villeOngletActif,
                        style: GoogleFonts.cinzel(
                          fontSize: 31,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _chip('$bons IDEAL MONTHS', vert, Icons.check_circle_rounded),
                          _chip('$mauvais TO AVOID', rouge, Icons.do_not_disturb_on_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Frise des 12 mois
        _glassBox(
          radius: 22,
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(mois.length, (i) {
              final bool bon = mois[i]['estBon'] == true;
              final Color col = bon ? vert : rouge;
              final String lettre = mois[i]['nom'].toString().substring(0, 1).toUpperCase();
              return Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600 + i * 70),
                  curve: Curves.easeOutCubic,
                  builder: (context, p, _) => SizedBox(
                    height: 66,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 9,
                          height: (bon ? 44.0 : 18.0) * p,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [col, col.withOpacity(0.35)],
                            ),
                            boxShadow: [BoxShadow(color: col.withOpacity(0.35 * p), blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lettre,
                          style: GoogleFonts.montserrat(
                            color: Colors.white54,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 22),
        _sectionLabel('MONTH BY MONTH'),
        const SizedBox(height: 14),
        ...List.generate(mois.length, (i) {
          return _Reveal(
            delayMs: 150 + i * 70,
            dy: 20,
            child: _MonthCard(m: mois[i]),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final listeMois = _getMoisPourVille(villeOngletActif);
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07070D),
          border: Border(top: BorderSide(color: _kGold.withOpacity(0.4), width: 0.8)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: _AuroraBackdrop(
                a: Color(0xFF3B82F6),
                b: Color(0xFF3B2A7A),
                c: Color(0xFFD4AF37),
              ),
            ),
            SingleChildScrollView(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 12, 20, 30 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ---- En-tête ----
                  _Reveal(
                    delayMs: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Planner',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF60A5FA),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When to visit',
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        _GoldShimmerText(
                          'Belgium ?',
                          style: GoogleFonts.cinzel(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pick a city: we analyze all 12 months of the year for you.',
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ---- Rappel météo ----
                  _Reveal(
                    delayMs: 180,
                    child: _glassBox(
                      radius: 20,
                      tint: const Color(0xFFF59E0B),
                      tintOpacity: 0.12,
                      border: const Color(0xFFF59E0B).withOpacity(0.35),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFBBF24).withOpacity(0.15),
                              border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.4), width: 0.8),
                            ),
                            child: const Icon(Icons.cloudy_snowing, color: Color(0xFFFBBF24), size: 19),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WEATHER REMINDER',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFFFBBF24),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.4,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Even if the period is recommended, always check the weather before you go.',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ---- Sélection de la ville ----
                  _Reveal(delayMs: 280, child: _sectionLabel('YOUR CITY')),
                  const SizedBox(height: 6),
                  _Reveal(
                    delayMs: 340,
                    child: SizedBox(
                      height: 158,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        itemCount: toutesLesVilles.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => _villeCard(toutesLesVilles[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ---- Bouton principal ----
                  _Reveal(delayMs: 420, child: _buildCta()),
                  const SizedBox(height: 26),

                  // ---- Analyse / résultats ----
                  if (estEnGenerationVitesse)
                    _Reveal(key: const ValueKey<String>('scan'), child: _buildScanner())
                  else if (estGenere && villeSelectionnee != null)
                    _Reveal(
                      key: ValueKey<String>('res-$villeOngletActif'),
                      child: _buildResultats(listeMois),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FAVORITES PAGE ---
class FavorisEnPage extends StatefulWidget {
  const FavorisEnPage({super.key});

  @override
  State<FavorisEnPage> createState() => _FavorisEnPageState();
}

class _FavorisEnPageState extends State<FavorisEnPage> {
  // Older saved IDs are normalized to the IDs used by the current city pages.
  static const Map<String, String> _legacyFavoriteIds = {
    'chateau_comtes': 'castle_of_counts',
    'beffroi_gand': 'ghent_belfry',
    'saint_bavon': 'saint_bavos_cathedral',
    'quai_herbes_grains': 'graslei_korenlei',
    'pont_saint_michel': 'saint_michaels_bridge',
    'montagne_bueren': 'montagne_de_bueren',
    'coteaux_citadelle': 'citadel_hillsides',
    'gare_liege_guillemins': 'liege_guillemins_station',
    'cathedrale_saint_paul': 'saint_pauls_cathedral',
    'ruelles_impasses_liege': 'old_town_lanes',
  };

  static const List<String> _favoriteStorageKeys = [
    'favoris_en',
    'favoris_bruxelles_en',
    'favoris_brussels_en',
    'favoris_bruges_en',
    'favoris_gand_en',
    'favoris_ghent_en',
    'ghent_favorites',
    'favoris_anvers_en',
    'favoris_antwerp_en',
    'favoris_anvers_fr',
    'favoris_liege_en',
    'liege_favorites',
  ];

  String _canonicalFavoriteId(String id) => _legacyFavoriteIds[id] ?? id;

  List<String> _favorisIds = [];
  bool _isLoading = true;

  final Map<String, Map<String, dynamic>> _tousLesLieux = {
    // --- BRUSSELS ---
    'parlement': {
      'titre': 'European Parliament',
      'images': ['assets4/belgique/bruxelles/1.jpg', 'assets4/belgique/bruxelles/2.jpg', 'assets4/belgique/bruxelles/3.jpg'],
      'quartier': 'European Quarter',
      'dossier': 'Brussels'
    },
    'cinquantenaire': {
      'titre': 'Cinquantenaire Park',
      'images': ['assets4/belgique/bruxelles/4.jpg', 'assets4/belgique/bruxelles/5.png'],
      'quartier': 'European Quarter',
      'dossier': 'Brussels'
    },
    'leopold': {
      'titre': 'Leopold Park',
      'images': ['assets4/belgique/bruxelles/7.jpg'],
      'quartier': 'European Quarter',
      'dossier': 'Brussels'
    },
    'grandplace': {
      'titre': 'Grand-Place',
      'images': ['assets4/belgique/bruxelles/9.jpg', 'assets4/belgique/bruxelles/10.jpg', 'assets4/belgique/bruxelles/11.jpg'],
      'quartier': 'Historic Center',
      'dossier': 'Brussels'
    },
    'mannekenpis': {
      'titre': 'Manneken-Pis and Jeanneke-Pis',
      'images': ['assets4/belgique/bruxelles/199.jpg', 'assets4/belgique/bruxelles/14.jpg'],
      'quartier': 'Historic Center',
      'dossier': 'Brussels'
    },
    'galeries': {
      'titre': 'Royal Saint-Hubert Galleries',
      'images': ['assets4/belgique/bruxelles/15.jpg'],
      'quartier': 'Historic Center',
      'dossier': 'Brussels'
    },
    'montdesarts': {
      'titre': 'Mont des Arts',
      'images': ['assets4/belgique/bruxelles/16.jpg', 'assets4/belgique/bruxelles/17.webp'],
      'quartier': 'Historic Center',
      'dossier': 'Brussels'
    },
    'palaisjustice': {
      'titre': 'Palace of Justice',
      'images': ['assets4/belgique/bruxelles/18.jpg', 'assets4/belgique/bruxelles/19.webp', 'assets4/belgique/bruxelles/20.webp', 'assets4/belgique/bruxelles/21.jpg'],
      'quartier': 'Historic Center',
      'dossier': 'Brussels'
    },
    'atomium': {
      'titre': 'Atomium',
      'images': ['assets4/belgique/bruxelles/22.jpg', 'assets4/belgique/bruxelles/23.jpg', 'assets4/belgique/bruxelles/24.jpg'],
      'quartier': 'Heysel / North',
      'dossier': 'Brussels'
    },
    'minieurope': {
      'titre': 'Mini-Europe',
      'images': ['assets4/belgique/bruxelles/25.webp', 'assets4/belgique/bruxelles/26.jpg'],
      'quartier': 'Heysel / North',
      'dossier': 'Brussels'
    },
    'laeken': {
      'titre': 'Royal Greenhouses of Laeken',
      'images': ['assets4/belgique/bruxelles/27.webp', 'assets4/belgique/bruxelles/28.jpg', 'assets4/belgique/bruxelles/29.webp'],
      'quartier': 'Laeken (North-West)',
      'dossier': 'Brussels'
    },

    // --- GHENT ---
    'castle_of_counts': {
      'titre': 'The Castle of the Counts',
      'images': ['assets4/belgique/gand/1.jpeg', 'assets4/belgique/gand/2.jpg', 'assets4/belgique/gand/3.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'ghent_belfry': {
      'titre': 'The Belfry of Ghent',
      'images': ['assets4/belgique/gand/4.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'saint_bavos_cathedral': {
      'titre': 'Saint Bavo\'s Cathedral',
      'images': ['assets4/belgique/gand/5.jpg', 'assets4/belgique/gand/6.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'graslei_korenlei': {
      'titre': 'The Graslei and Korenlei',
      'images': ['assets4/belgique/gand/7.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'saint_michaels_bridge': {
      'titre': 'Saint Michael\'s Bridge',
      'images': ['assets4/belgique/gand/8.webp', 'assets4/belgique/gand/9.webp', 'assets4/belgique/gand/12.webp'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },

    // --- BRUGES ---
    'canaux_bruges': {
      'titre': 'The Canals of Bruges',
      'images': ['assets4/belgique/bruges/1.webp', 'assets4/belgique/bruges/2.jpg', 'assets4/belgique/bruges/3.webp'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },
    'quai_rosaire': {
      'titre': 'The Rozenhoedkaai (Quay of the Rosary)',
      'images': ['assets4/belgique/bruges/4.jpg', 'assets4/belgique/bruges/6.jpg'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },
    'beffroi_bruges': {
      'titre': 'The Belfry of Bruges',
      'images': ['assets4/belgique/bruges/9.webp'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },
    'grote_markt': {
      'titre': 'The Market Square (Grote Markt)',
      'images': ['assets4/belgique/bruges/11.webp', 'assets4/belgique/bruges/12.webp', 'assets4/belgique/bruges/14.webp'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },
    'godshuizen': {
      'titre': 'The Godshuizen (Almshouses)',
      'images': ['assets4/belgique/bruges/15.webp', 'assets4/belgique/bruges/16.webp'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },
    'moulins_bruges': {
      'titre': 'The Windmills of Bruges',
      'images': ['assets4/belgique/bruges/17.jpeg'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },
    'basilique_saintsang': {
      'titre': 'The Basilica of the Holy Blood',
      'images': ['assets4/belgique/bruges/20.jpg', 'assets4/belgique/bruges/21.webp'],
      'quartier': 'Bruges Highlights',
      'dossier': 'Bruges'
    },

    // --- ANTWERP ---
    'gare_centrale_anvers': {
      'titre': 'Antwerp-Central Station',
      'images': ['assets4/belgique/anvers/1.jpg', 'assets4/belgique/anvers/2.jpg', 'assets4/belgique/anvers/3.webp', 'assets4/belgique/anvers/4.webp'],
      'quartier': 'Antwerp Must-Sees',
      'dossier': 'Antwerp'
    },
    'grote_markt_anvers': {
      'titre': 'Grote Markt of Antwerp',
      'images': ['assets4/belgique/anvers/5.jpg', 'assets4/belgique/anvers/6.jpg', 'assets4/belgique/anvers/7.webp'],
      'quartier': 'Antwerp Must-Sees',
      'dossier': 'Antwerp'
    },
    'cathedrale_notredame_anvers': {
      'titre': 'Cathedral of Our Lady',
      'images': ['assets4/belgique/anvers/8.jpg'],
      'quartier': 'Antwerp Must-Sees',
      'dossier': 'Antwerp'
    },
    'het_steen': {
      'titre': 'Het Steen Castle',
      'images': ['assets4/belgique/anvers/9.webp', 'assets4/belgique/anvers/10.webp', 'assets4/belgique/anvers/11.webp'],
      'quartier': 'Antwerp Must-Sees',
      'dossier': 'Antwerp'
    },

    // --- LIEGE ---
    'montagne_de_bueren': {
      'titre': 'The Montagne de Bueren',
      'images': ['assets4/belgique/liege/1.webp', 'assets4/belgique/liege/2.webp', 'assets4/belgique/liege/1 bis.webp'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'citadel_hillsides': {
      'titre': 'The Citadel Hillsides',
      'images': ['assets4/belgique/liege/3.jpg', 'assets4/belgique/liege/4.jpg'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'liege_guillemins_station': {
      'titre': 'Liege-Guillemins Station',
      'images': ['assets4/belgique/liege/5.jpg', 'assets4/belgique/liege/6.webp', 'assets4/belgique/liege/7.jpg'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'saint_pauls_cathedral': {
      'titre': 'Saint Paul\'s Cathedral',
      'images': ['assets4/belgique/liege/8.jpg'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'old_town_lanes': {
      'titre': 'The Alleys and Dead Ends of Liege',
      'images': ['assets4/belgique/liege/10.jpg', 'assets4/belgique/liege/15.jpg', 'assets4/belgique/liege/12.webp'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
  };

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final List<String> allFavs = [];

    for (final key in _favoriteStorageKeys) {
      final List<String> storedIds = prefs.getStringList(key) ?? const <String>[];
      for (final storedId in storedIds) {
        final String id = _canonicalFavoriteId(storedId);
        if (!allFavs.contains(id)) {
          allFavs.add(id);
        }
      }
    }

    setState(() {
      _favorisIds = allFavs;
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final String canonicalId = _canonicalFavoriteId(id);

    setState(() {
      _favorisIds.remove(canonicalId);
    });

    for (final key in _favoriteStorageKeys) {
      final List<String>? storedIds = prefs.getStringList(key);
      if (storedIds == null) continue;

      final List<String> remainingIds = storedIds
          .where((storedId) => _canonicalFavoriteId(storedId) != canonicalId)
          .toList();

      if (remainingIds.length != storedIds.length) {
        await prefs.setStringList(key, remainingIds);
      }
    }
  }

  // -------------------------------------------------------------------------
  //  Aides de lecture des favoris
  // -------------------------------------------------------------------------
  final Set<String> _dossiersOuverts = {};
  final Set<String> _quartiersOuverts = {};

  List<Map<String, dynamic>> _lieuxPour(String dossier, String quartier) {
    final List<Map<String, dynamic>> res = [];
    for (final String id in _favorisIds) {
      final Map<String, dynamic>? base = _tousLesLieux[id];
      if (base == null) continue;
      if (base['dossier'] == dossier && base['quartier'] == quartier) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(base);
        item['id'] = id;
        res.add(item);
      }
    }
    return res;
  }

  int _compteDossier(String dossier) {
    int c = 0;
    for (final String id in _favorisIds) {
      final Map<String, dynamic>? base = _tousLesLieux[id];
      if (base != null && base['dossier'] == dossier) c++;
    }
    return c;
  }

  Widget _glassPill({required IconData icon, required String label, Color? color}) {
    final Color col = color ?? Colors.white70;
    return _glassBox(
      radius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: col, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: col,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell(int value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '$v',
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _kChampagne,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 9.5,
              color: Colors.white54,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int villesActives) {
    return _glassBox(
      radius: 26,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          _statCell(total, total > 1 ? 'PLACES' : 'PLACE'),
          Container(
            width: 0.8,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kGold.withOpacity(0.0), _kGold.withOpacity(0.6), _kGold.withOpacity(0.0)],
              ),
            ),
          ),
          _statCell(villesActives, villesActives > 1 ? 'CITIES' : 'CITY'),
        ],
      ),
    );
  }

  Widget _buildVide() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: _glassBox(
        radius: 30,
        padding: const EdgeInsets.fromLTRB(28, 38, 28, 34),
        child: Column(
          children: [
            const _FloatingHeart(),
            const SizedBox(height: 26),
            Text(
              'No favorites yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the heart on the places you love in the city pages: they will appear here, sorted by neighborhood.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Un dossier = une ville, avec bannière photo ----
  Widget _buildDossier(String dossierNom, List<String> quartiers) {
    final bool open = _dossiersOuverts.contains(dossierNom);
    final int count = _compteDossier(dossierNom);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A11),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _kGold.withOpacity(open ? 0.5 : 0.26), width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 24, offset: const Offset(0, 12)),
          BoxShadow(color: _kGold.withOpacity(open ? 0.14 : 0.05), blurRadius: 30, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Column(
          children: [
            _PressScale(
              scale: 0.985,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (open) {
                    _dossiersOuverts.remove(dossierNom);
                  } else {
                    _dossiersOuverts.add(dossierNom);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                height: open ? 104 : 132,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: open ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      child: _photo(_kVilleImages[dossierNom] ?? ''),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.88)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      bottom: 16,
                      right: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dossierNom,
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            count == 0
                                ? 'NO PLACES'
                                : (count == 1 ? '1 PLACE SAVED' : '$count PLACES SAVED'),
                            style: GoogleFonts.montserrat(
                              color: _kChampagne.withOpacity(count == 0 ? 0.5 : 0.9),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 14,
                        left: 16,
                        child: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kGold,
                            boxShadow: [BoxShadow(color: _kGold.withOpacity(0.5), blurRadius: 12)],
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.montserrat(
                              color: Colors.black87,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: _glassBox(
                        radius: 30,
                        padding: const EdgeInsets.all(8),
                        child: AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          child: const Icon(Icons.keyboard_arrow_down_rounded, color: _kChampagne, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: open
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
                child: Column(
                  children: quartiers.map((q) => _buildQuartier(dossierNom, q)).toList(),
                ),
              )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Un quartier dans un dossier ----
  Widget _buildQuartier(String dossierNom, String quartierNom) {
    final String key = '$dossierNom-$quartierNom';
    final bool open = _quartiersOuverts.contains(key);
    final List<Map<String, dynamic>> lieux = _lieuxPour(dossierNom, quartierNom);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(open ? 0.12 : 0.07), width: 0.8),
      ),
      child: Column(
        children: [
          _PressScale(
            scale: 0.985,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (open) {
                  _quartiersOuverts.remove(key);
                } else {
                  _quartiersOuverts.add(key);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.diamond_outlined, color: _kGold, size: 13),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      quartierNom,
                      style: GoogleFonts.montserrat(
                        color: _kChampagne,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (lieux.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kGold.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${lieux.length}',
                        style: GoogleFonts.montserrat(
                          color: _kGold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: _kChampagne.withOpacity(0.8), size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: lieux.isEmpty
                  ? Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No favorites in this section.',
                    style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 12),
                  ),
                ),
              )
                  : Column(
                children: List.generate(lieux.length, (i) {
                  return _Reveal(
                    key: ValueKey<String>('lieu-${lieux[i]['id']}'),
                    delayMs: i * 90,
                    dy: 16,
                    child: _buildLieu(lieux[i], dossierNom),
                  );
                }),
              ),
            )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  // ---- Un lieu favori : titre, suppression, galerie horizontale ----
  Widget _buildLieu(Map<String, dynamic> lieu, String dossierNom) {
    final List<String> images = List<String>.from(lieu['images'] ?? []);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.02)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: _kGold, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lieu['titre'].toString(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _PressScale(
                scale: 0.88,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _retirerFavori(lieu['id'].toString());
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.35), width: 0.8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                ),
              ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: images.length,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _photo(images[i], width: 124, height: 92),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dossiers = ['Brussels', 'Ghent', 'Bruges', 'Antwerp', 'Liege'];

    final Map<String, List<String>> quartiersParVille = {
      'Brussels': ['European Quarter', 'Historic Center', 'Heysel / North', 'Laeken (North-West)'],
      'Ghent': ['Ghent Highlights'],
      'Bruges': ['Bruges Highlights'],
      'Antwerp': ['Antwerp Must-Sees'],
      'Liege': ['Liege Highlights'],
    };

    final int total = dossiers.fold<int>(0, (s, d) => s + _compteDossier(d));
    final int villesActives = dossiers.where((d) => _compteDossier(d) > 0).length;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const _AuroraBackdrop(
                a: Color(0xFFD4AF37),
                b: Color(0xFF7A1633),
                c: Color(0xFF3B2A7A),
              ),
              SafeArea(
                child: _isLoading
                    ? const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(color: _kGold, strokeWidth: 1.6),
                  ),
                )
                    : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ---- Barre du haut ----
                    _Reveal(
                      child: Row(
                        children: [
                          _PressScale(
                            onTap: () => Navigator.pop(context),
                            child: _glassPill(
                              icon: Icons.arrow_back_ios_new_rounded,
                              label: 'BACK',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ---- Titre ----
                    _Reveal(
                      delayMs: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR SELECTION',
                            style: GoogleFonts.montserrat(
                              color: _kChampagne.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _GoldShimmerText(
                            'My Favorites',
                            style: GoogleFonts.cinzel(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 2,
                            width: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF000000), Color(0xFFD4AF37), Color(0xFF7A0C0C)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (total == 0)
                      _Reveal(delayMs: 200, child: _buildVide())
                    else ...[
                      _Reveal(delayMs: 200, child: _buildStats(total, villesActives)),
                      const SizedBox(height: 28),
                      for (int i = 0; i < dossiers.length; i++)
                        _Reveal(
                          delayMs: 320 + i * 100,
                          child: _buildDossier(dossiers[i], quartiersParVille[dossiers[i]] ?? []),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderCityPage extends StatelessWidget {
  final String cityName;
  const _PlaceholderCityPage({required this.cityName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070913),
      appBar: AppBar(title: Text(cityName, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.transparent),
      body: Center(child: Text('Page under development for $cityName', style: const TextStyle(color: Colors.white70))),
    );
  }
}