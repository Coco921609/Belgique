import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belgique/belgique/français/bruges.dart';
import 'package:belgique/belgique/français/Gand.dart';
import 'package:belgique/belgique/français/anvers.dart';
import 'package:belgique/belgique/français/liege.dart';
import 'package:belgique/belgique/français/bruxelles.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> with TickerProviderStateMixin {
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
      'nom': 'Bruxelles',
      'image': 'assets4/belgique/bruxelles/77.jpg',
      'description': 'La capitale vibrante, célèbre pour sa Grand-Place et son art de vivre.',
    },
    {
      'nom': 'Gand',
      'image': 'assets4/belgique/gand/11.webp',
      'description': 'Une ville historique au charme médiéval unique, traversée par des canaux.',
    },
    {
      'nom': 'Bruges',
      'image': 'assets4/belgique/bruges/19.jpeg',
      'description': 'La Venise du Nord, célèbre pour ses canaux romantiques et son centre médiéval préservé.',
    },
    {
      'nom': 'Anvers',
      'image': 'assets4/belgique/anvers/12.jpg',
      'description': 'La métropole de la mode, du diamant et du riche patrimoine de Rubens.',
    },
    {
      'nom': 'Liège',
      'image': 'assets4/belgique/liege/16.jpg',
      'description': 'La cité ardente, reconnue pour sa convivialité et ses incontournables gaufres.',
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
      case 'Bruxelles':
        pageDestination = const Bruxelles();
        break;
      case 'Gand':
        pageDestination = const Gand();
        break;
      case 'Bruges':
        pageDestination = const Bruges();
        break;
      case 'Anvers':
        pageDestination = const Anvers();
        break;
      case 'Liège':
        pageDestination = const Liege();
        break;
      default:
        pageDestination = _PlaceholderCityPage(cityName: nomVille);
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pageDestination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
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
                  'RETOUR',
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
                pageBuilder: (context, animation, secondaryAnimation) => const FavorisFrPage(),
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
                  'FAVORIS',
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
            'DÉCOUVREZ LA',
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
                  'Belgique',
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
            'Explorez un pays riche en traditions, en culture et en paysages urbains captivants, entre châteaux historiques et douceurs légendaires.',
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
          cell(villes.length, 'VILLES'),
          sep(),
          cell(12, 'MOIS ANALYSÉS'),
          sep(),
          cell(2, 'OUTILS'),
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
              kicker: 'PLANIFICATEUR',
              titre: 'Quand visiter la Belgique ?',
              texte: 'Les meilleures périodes par ville, hors vacances scolaires et week-ends chargés.',
              cta: 'LANCER',
              onTap: () => _afficherGenerateur(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTile(
              icon: Icons.casino_rounded,
              accent: const Color(0xFFA78BFA),
              kicker: 'INDÉCIS ?',
              titre: 'La Roulette des Villes',
              texte: 'Laissez le hasard choisir votre prochaine ville belge en un seul clic.',
              cta: 'TOURNER',
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
            'Les Villes Incontournables',
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
                          'DÉCOUVRIR',
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
  'Bruxelles': 'assets4/belgique/bruxelles/77.jpg',
  'Gand': 'assets4/belgique/gand/11.webp',
  'Bruges': 'assets4/belgique/bruges/19.jpeg',
  'Anvers': 'assets4/belgique/anvers/12.jpg',
  'Liège': 'assets4/belgique/liege/16.jpg',
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
      case 'Hiver':
        return Icons.ac_unit_rounded;
      case 'Printemps':
        return Icons.local_florist_rounded;
      case 'Été':
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
                                bon ? 'IDÉAL' : 'À ÉVITER',
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
                          _open ? 'RÉDUIRE' : 'LIRE LA SUITE',
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
      case 'Bruxelles':
        pageDestination = const Bruxelles();
        break;
      case 'Gand':
        pageDestination = const Gand();
        break;
      case 'Bruges':
        pageDestination = const Bruges();
        break;
      case 'Anvers':
        pageDestination = const Anvers();
        break;
      case 'Liège':
        pageDestination = const Liege();
        break;
      default:
        pageDestination = _PlaceholderCityPage(cityName: _selectedVille);
    }

    Navigator.push(
      widget.parentContext,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pageDestination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
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
                        'ROULETTE DES VILLES',
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
                                    'TIRAGE EN COURS',
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
                                    'DÉCOUVRIR ${(_selectedVille.isEmpty ? ville['nom']! : _selectedVille).toUpperCase()}',
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
                                    'TIRER À NOUVEAU',
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

// --- WIDGET DU GÉNÉRATEUR ---
class _GenerateurWidget extends StatefulWidget {
  final ScrollController scrollController;

  const _GenerateurWidget({required this.scrollController});

  @override
  State<_GenerateurWidget> createState() => _GenerateurWidgetState();
}

class _GenerateurWidgetState extends State<_GenerateurWidget> {
  final List<String> toutesLesVilles = ['Bruxelles', 'Gand', 'Bruges', 'Anvers', 'Liège'];

  String? villeSelectionnee;
  bool estEnGenerationVitesse = false;
  bool estGenere = false;

  String affichageVitesseTexte = "ANALYSE DE LA BANQUE...";
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
      "CONNEXION À LA BASE DE DONNÉES...",
      "ANALYSE DES PÉRIODES RECOMMANDÉES...",
      "ANALYSE DES PÉRIODES À ÉVITER...",
      "ANALYSE DES SAISONS...",
      "GÉNÉRATION DES CONSEILS...",
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
    if (nomVille == 'Bruxelles') {
      return [
        {'nom': 'Janvier', 'estBon': false, 'saison': 'Hiver', 'raison': 'Le mois de janvier à Bruxelles est une période particulièrement rude, marquée par une grisaille persistante et des vents froids qui soufflent sur les pavés de la Grand-Place. La luminosité est extrêmement réduite, ce qui ternit l\'éclat de l\'architecture Art Nouveau et rend les promenades extérieures peu agréable. Il est préférable de se concentrer sur les visites de musées intérieurs plutôt que d\'espérer une découverte urbaine sereine.'},
        {'nom': 'Février', 'estBon': false, 'saison': 'Hiver', 'raison': 'Février ne marque que peu d\'amélioration, avec une humidité ambiante qui rend les températures ressenties bien plus basses qu\'elles ne le sont réellement. Les jours sont courts et souvent pluvieux, transformant les déplacements entre le Mont des Arts et les différents quartiers en épreuves sportives. C\'est un mois à éviter si vous souhaitez profiter pleinement de la ville sans être contraint par une météo capricieuse et souvent dissuasive.'},
        {'nom': 'Mars', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mars apporte enfin un souffle de renouveau, avec des journées qui s\'allongent et une lumière qui commence à réchauffer les pierres historiques du centre-ville. C\'est le moment idéal pour une première visite printanière, car les foules de touristes ne sont pas encore arrivées. En privilégiant les jours de semaine, vous pourrez arpenter les rues et les parcs avec une tranquillité exceptionnelle et découvrir Bruxelles sous son meilleur jour.'},
        {'nom': 'Avril', 'estBon': true, 'saison': 'Printemps', 'raison': 'Le mois d\'avril est une période magique pour Bruxelles, notamment grâce à l\'ouverture tant attendue des Serres Royales de Laeken qui offrent un spectacle floral époustouflant. Le climat devient nettement plus doux, propice à la redécouverte des parcs urbains et des terrasses qui commencent à s\'animer. C\'est une fenêtre parfaite pour une escapade culturelle, à condition d\'éviter les week-ends pour garder une fluidité de circulation.'},
        {'nom': 'Mai', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mai est sans conteste l\'un des mois les plus agréables pour explorer la capitale européenne, avec des températures idéales pour marcher sans fatigue. L\'atmosphère est festive, les espaces verts comme le parc du Cinquantenaire sont resplendissants, et la vie sociale bat son plein dans les quartiers animés. Une visite programmée en milieu de semaine vous garantira une expérience fluide, loin des pressions touristiques qui commencent à monter.'},
        {'nom': 'Juin', 'estBon': false, 'saison': 'Été', 'raison': 'Juin sonne le début de la haute saison touristique, entraînant une saturation progressive des lieux emblématiques comme l\'Atomium et le Manneken-Pis. Les files d\'attente deviennent significatives et l\'ambiance, bien que dynamique, perd de son authenticité face à l\'afflux massif de groupes. Les prix des hébergements commencent à grimper, ce qui rend le rapport qualité-prix de votre séjour bien moins attractif qu\'au printemps.'},
        {'nom': 'Juillet', 'estBon': false, 'saison': 'Été', 'raison': 'Juillet est le mois des grandes vacances, où le centre-ville est littéralement submergé par une marée humaine venue du monde entier. La chaleur urbaine, prisonnière des rues étroites, peut devenir accablante, rendant les longues marches particulièrement pénibles. Il devient complexe de réserver une table dans les restaurants prisés ou de profiter des attractions sans devoir patienter des heures entières sous un soleil souvent intense.'},
        {'nom': 'Août', 'estBon': false, 'saison': 'Été', 'raison': 'Août maintient une forte pression touristique avec un taux d\'occupation maximal des sites historiques et des hôtels bruxellois. La ville est bruyante et souvent agitée, loin de l\'image paisible que l\'on pourrait rechercher pour une escapade culturelle. Les températures élevées combinées au monde omniprésent rendent la découverte de la ville moins reposante, surtout si vous cherchez à éviter les zones de grande densité touristique.'},
        {'nom': 'Septembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Septembre offre une magnifique période de transition, avec une météo souvent clémente et une luminosité dorée qui sublime les façades historiques de Bruxelles. La rentrée scolaire permet un retour au calme significatif, rendant les musées et les monuments beaucoup plus accessibles. C\'est le moment privilégié pour flâner sans pression et profiter des tarifs hôteliers plus abordables en semaine.'},
        {'nom': 'Octobre', 'estBon': true, 'saison': 'Automne', 'raison': 'L\'automne s\'installe doucement, parant les parcs de Bruxelles de magnifiques teintes orangées, ce qui rend les promenades particulièrement photogéniques et relaxantes. Le climat est encore très correct pour découvrir l\'architecture de la ville sans souffrir de la chaleur ou du grand froid. C\'est une période très sereine, parfaite pour s\'imprégner de la culture locale et des expositions automnales dans une ambiance apaisée.'},
        {'nom': 'Novembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Novembre est un mois de transition calme, où la frénésie touristique est absente, laissant place à une atmosphère authentique et mélancolique propre à la Belgique. Les températures plus fraîches invitent à se réfugier dans des estaminets chaleureux ou des salons de thé traditionnels. Une visite en milieu de semaine est idéale pour profiter pleinement de la ville en toute intimité, loin des foules.'},
        {'nom': 'Décembre', 'estBon': false, 'saison': 'Hiver', 'raison': 'Si décembre attire pour ses "Plaisirs d\'Hiver", il s\'agit surtout d\'une période de saturation extrême pour le centre historique bruxellois les week-ends. La densité humaine autour des marchés de Noël et des zones piétonnes rend toute déambulation difficile, voire frustrante. Le froid, bien que traditionnel, s\'accompagne d\'une agitation qui masque le charme habituel de la capitale.'},
      ];
    } else if (nomVille == 'Gand') {
      return [
        {'nom': 'Janvier', 'estBon': false, 'saison': 'Hiver', 'raison': 'Janvier à Gand est synonyme de froid vif venant de la mer du Nord, qui s\'engouffre le long des canaux et rend les balades sur le Quai aux Herbes assez peu confortables. Les journées courtes limitent la capacité à profiter des façades historiques, qui perdent de leur éclat sous le ciel bas et grisâtre. C\'est un mois où la ville tourne au ralenti et où le confort intérieur est privilégié au détriment des découvertes extérieures.'},
        {'nom': 'Février', 'estBon': false, 'saison': 'Hiver', 'raison': 'Le mois de février reste marqué par des conditions météorologiques instables et souvent froides, avec des risques de pluie fine qui rendent les pavés gantois particulièrement glissants. Le brouillard, très présent, peut masquer la beauté du Beffroi ou du Château des Comtes, empêchant d\'apprécier pleinement le paysage urbain. Une période à réserver uniquement si vous prévoyez de passer la majorité de votre temps à l\'intérieur des musées.'},
        {'nom': 'Mars', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mars est une période de renouveau pour Gand, où le soleil commence à percer les nuages, illuminant à nouveau les reflets dans les eaux de la Lys. C\'est un excellent compromis entre la fraîcheur de l\'hiver qui s\'en va et le début du printemps plus animé. En visitant en semaine, vous éviterez les afflux de week-end et profiterez d\'une ville qui s\'éveille en toute sérénité.'},
        {'nom': 'Avril', 'estBon': true, 'saison': 'Printemps', 'raison': 'Avril révèle tout le charme bucolique de Gand, avec des berges qui verdissent et une atmosphère étudiante qui dynamise les terrasses sans saturer les monuments. Les conditions climatiques deviennent très agréables pour les balades à pied ou en vélo le long des canaux. C\'est un mois idéal pour une escapade printanière avant que la haute saison touristique ne commence à peser sur la ville.'},
        {'nom': 'Mai', 'estBon': true, 'saison': 'Printemps', 'raison': 'Le mois de mai est sans doute l\'un des meilleurs moments pour succomber au charme de Gand, avec des températures douces et une lumière qui sublime le patrimoine médiéval. La ville est vivante, les fleurs embellissent les ponts, et les terrasses offrent un cadre parfait pour la détente. Une visite en milieu de semaine garantit une immersion authentique dans la vie gantoise sans l\'affluence touristique des mois d\'été.'},
        {'nom': 'Juin', 'estBon': false, 'saison': 'Été', 'raison': 'Juin marque un changement de rythme avec l\'arrivée des premiers flux touristiques importants, rendant les lieux emblématiques comme le Graslei très fréquentés dès le moindre rayon de soleil. L\'agitation est perceptible dans les ruelles étroites, et la quiétude habituelle de la ville commence à s\'effriter face à une hausse marquée de la fréquentation. Les prix des hébergements débutent leur ascension vers les sommets estivaux.'},
        {'nom': 'Juillet', 'estBon': false, 'saison': 'Été', 'raison': 'Juillet est dominé par les "Fêtes de Gand", qui transforment la ville en un festival gigantesque. Si c\'est une période vibrante, elle rend la découverte patrimoniale classique extrêmement difficile en raison des installations, des foules immenses et de l\'occupation totale de l\'espace public par les festivités. Ce n\'est clairement pas le mois pour ceux qui cherchent la tranquillité ou une visite historique sans tapage.'},
        {'nom': 'Août', 'estBon': false, 'saison': 'Été', 'raison': 'En août, la ville reste très prisée, conservant une forte densité touristique qui sature les attractions majeures et les points de vue sur les canaux. La chaleur peut s\'avérer fatigante lors de longues marches dans le centre historique médiéval, et la recherche d\'une table au restaurant devient souvent un défi logistique. L\'ambiance estivale est bien présente, mais au prix d\'une perte de la sérénité gantoise habituelle.'},
        {'nom': 'Septembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Septembre offre une parenthèse apaisante avec des températures encore très clémentes et une lumière d\'arrière-saison parfaite pour explorer Gand sous son meilleur profil. Le départ des vacanciers rend à la ville son équilibre, permettant de s\'imprégner de l\'histoire et de la beauté des lieux sans la foule. Visiter en semaine en septembre est une garantie de succès pour un séjour relaxant et culturellement riche.'},
        {'nom': 'Octobre', 'estBon': true, 'saison': 'Automne', 'raison': 'Octobre enveloppe Gand d\'une aura mystérieuse et romantique, avec des arbres qui bordent les canaux se parant de couleurs chaudes. C\'est un mois idéal pour apprécier l\'art local et les musées dans une atmosphère plus feutrée et authentique. Les touristes se font rares, laissant le champ libre aux curieux qui veulent découvrir Gand sans devoir faire la queue devant les monuments.'},
        {'nom': 'Novembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Novembre est une période de calme profond, où la ville reprend un rythme lent, propice à une découverte intimiste. C\'est le moment parfait pour s\'attarder dans les brasseries traditionnelles ou les galeries d\'art sans aucune pression temporelle ou physique. Une escapade en semaine permet de vivre Gand de l\'intérieur, en toute sérénité, loin des sentiers battus et de l\'agitation estivale.'},
        {'nom': 'Décembre', 'estBon': false, 'saison': 'Hiver', 'raison': 'Décembre attire beaucoup de monde lors des week-ends en raison des illuminations et des marchés de Noël, ce qui rend le centre-ville très encombré. Le froid humide typique de la région peut rendre les longues déambulations dans les rues bondées assez pénibles. Bien que l\'aspect visuel soit superbe, la réalité de la visite touristique en cette période est souvent marquée par une foule oppressante et des conditions climatiques rudes.'},
      ];
    } else if (nomVille == 'Bruges') {
      return [
        {'nom': 'Janvier', 'estBon': false, 'saison': 'Hiver', 'raison': 'Janvier à Bruges est marqué par un froid intense qui rend les promenades le long des canaux très peu agréables, avec des vents qui s\'engouffrent entre les bâtiments médiévaux. Beaucoup d\'activités touristiques fonctionnent au ralenti, voire ferment, et l\'ambiance globale est plutôt morose et déserte. C\'est une période où la magie de Bruges peine à s\'exprimer pleinement en raison de la rigueur climatique.'},
        {'nom': 'Février', 'estBon': false, 'saison': 'Hiver', 'raison': 'Le climat de février reste très rigoureux, avec des risques de pluie verglaçante et des journées sombres qui ternissent les façades pittoresques. Les pavés historiques deviennent glissants et dangereux, ce qui décourage la déambulation libre dans le centre-ville. Il est difficile de profiter du charme romantique de Bruges lorsque les conditions extérieures incitent uniquement à se réfugier à l\'intérieur.'},
        {'nom': 'Mars', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mars marque le retour de la lumière et une certaine douceur qui permet de commencer à apprécier les extérieurs brugeois. Les touristes de masse sont encore absents, ce qui offre une occasion rare de photographier le Beffroi ou le Rozenhoedkaai dans le silence. En choisissant la semaine, vous aurez la sensation d\'avoir cette ville médiévale pour vous seul, dans une ambiance de renouveau très appréciable.'},
        {'nom': 'Avril', 'estBon': true, 'saison': 'Printemps', 'raison': 'Avril voit Bruges se parer de ses plus beaux atours printaniers, avec des fleurs qui embellissent les jardins et les béguinages, créant des décors dignes d\'une carte postale. Le temps est généralement clément, ce qui est parfait pour les balades en barque sur les canaux. C\'est un mois idéal pour découvrir Bruges, à condition de privilégier les jours de semaine pour éviter les premiers flux touristiques.'},
        {'nom': 'Mai', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mai est sans aucun doute l\'un des mois les plus resplendissants pour Bruges, offrant une météo souvent idéale et une lumière printanière qui sublime l\'architecture flamande. Les canaux sont particulièrement photogéniques avec le retour de la végétation. Il est crucial, cependant, de planifier votre séjour hors des jours fériés et des week-ends pour conserver la magie de la ville intacte.'},
        {'nom': 'Juin', 'estBon': false, 'saison': 'Été', 'raison': 'Juin voit l\'arrivée massive de visiteurs internationaux qui saturent le petit centre-ville de Bruges, rendant la circulation piétonne pénible. Les quais, autrefois paisibles, deviennent des axes bondés où il est difficile de s\'arrêter pour admirer le paysage. L\'ambiance romantique laisse place à une agitation constante, et les temps d\'attente pour les principales attractions deviennent significatifs.'},
        {'nom': 'Juillet', 'estBon': false, 'saison': 'Été', 'raison': 'Juillet représente l\'apogée de l\'affluence estivale, où Bruges perd une partie de son identité au profit d\'un tourisme de masse très dense. La chaleur peut être étouffante dans les ruelles étroites, et l\'offre de restauration est saturée, rendant l\'expérience globale moins confortable et plus coûteuse. C\'est une période à éviter si vous cherchez la quiétude et l\'aspect authentique de la cité flamande.'},
        {'nom': 'Août', 'estBon': false, 'saison': 'Été', 'raison': 'En août, la pression reste constante avec un flux ininterrompu de touristes qui occupent chaque recoin du centre-ville historique. Les prix des hébergements sont à leur maximum, et les boutiques de souvenirs et de chocolat sont prises d\'assaut en permanence. L\'expérience de visite est souvent stressante à cause de la foule, ce qui altère le plaisir que l\'on peut tirer de la beauté exceptionnelle de cette ville.'},
        {'nom': 'Septembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Septembre offre un répit bienvenu avec la baisse de fréquentation, rendant à Bruges son rythme lent et sa poésie caractéristique. Les températures restent agréables, idéales pour grimper au sommet du Beffroi et profiter d\'une vue panoramique sans avoir à se frayer un chemin. Visiter en semaine pendant ce mois permet de découvrir l\'âme véritable de la ville dans des conditions de confort optimales.'},
        {'nom': 'Octobre', 'estBon': true, 'saison': 'Automne', 'raison': 'Octobre drape Bruges d\'une aura mystérieuse et mélancolique, avec des brumes matinales qui se lèvent sur les canaux, créant des ambiances inoubliables pour les photographes. Les couleurs automnales des arbres complètent ce tableau idyllique. En évitant les week-ends, vous profiterez d\'une visite calme, apaisée, et très authentique, loin de l\'agitation estivale qui n\'est plus qu\'un lointain souvenir.'},
        {'nom': 'Novembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Novembre apporte une atmosphère feutrée et une tranquillité absolue dans les rues pavées de Bruges. C\'est le moment parfait pour s\'immerger dans l\'histoire médiévale et visiter les musées sans subir aucune attente. Les soirées plus sombres incitent à se retrouver dans des restaurants cosy pour déguster des plats flamands, faisant de cette période une expérience de voyage très reposante et inspirante.'},
        {'nom': 'Décembre', 'estBon': false, 'saison': 'Hiver', 'raison': 'La période de Noël à Bruges est certes féerique visuellement, mais elle attire une foule si compacte qu\'elle en devient impraticable les samedis et dimanches. Le froid vif est souvent difficile à supporter lorsqu\'on fait la queue pour accéder aux marchés ou aux activités. Bien que l\'ambiance soit festive, le confort de visite est fortement diminué par l\'affluence record que connaît la ville en cette période.'},
      ];
    } else if (nomVille == 'Anvers') {
      return [
        {'nom': 'Janvier', 'estBon': false, 'saison': 'Hiver', 'raison': 'Anvers en janvier est exposée aux vents froids qui soufflent directement de l\'Escaut, rendant les promenades sur les quais glaciales. La météo est souvent grise et peu engageante, ce qui freine l\'envie d\'explorer le centre-ville et les quartiers architecturaux à pied. Les journées étant très courtes, les opportunités de visites extérieures sont limitées, faisant de ce mois une période peu recommandée pour une découverte complète.'},
        {'nom': 'Février', 'estBon': false, 'saison': 'Hiver', 'raison': 'Février se caractérise par une grisaille persistante et des pluies fréquentes, qui assombrissent la beauté des places historiques d\'Anvers. Les conditions climatiques sont souvent rebutantes pour les marcheurs souhaitant découvrir le patrimoine urbain sans protection. C\'est une période où la ville semble tourner au ralenti, et où les sorties extérieures sont compromises par un froid humide et pénétrant.'},
        {'nom': 'Mars', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mars marque un éveil culturel et climatique très appréciable, avec des journées plus lumineuses qui invitent à arpenter le Meir et les rues adjacentes. Les températures deviennent plus clémentes, rendant la visite du musée Rubens et du quartier des diamantaires beaucoup plus agréable. Planifier votre séjour en milieu de semaine vous permettra de profiter pleinement de l\'effervescence urbaine sans les foules du week-end.'},
        {'nom': 'Avril', 'estBon': true, 'saison': 'Printemps', 'raison': 'Avril est un mois dynamique où la ville d\'Anvers s\'anime sous un soleil printanier, offrant des conditions idéales pour explorer les nouveaux quartiers créatifs et les berges de l\'Escaut. L\'air est doux, les terrasses commencent à s\'installer et la vie culturelle est foisonnante. C\'est un moment parfait pour une escapade urbaine, surtout en semaine pour éviter la hausse naturelle de la fréquentation des week-ends.'},
        {'nom': 'Mai', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mai est incontestablement un mois phare pour Anvers, offrant un climat souvent ensoleillé qui magnifie son architecture avant-gardiste et historique. La ville est en plein essor culturel, avec de nombreux événements et expositions. Pour profiter de cette atmosphère unique sans le tumulte des foules du samedi, un séjour organisé du mardi au jeudi reste la meilleure stratégie pour une immersion totale.'},
        {'nom': 'Juin', 'estBon': false, 'saison': 'Été', 'raison': 'Juin apporte une hausse de la fréquentation touristique qui se fait sentir dans les zones commerçantes et autour des sites majeurs comme la Gare Centrale. Les températures montent et l\'agitation urbaine peut rendre la visite moins relaxante qu\'au printemps. Les embouteillages piétons deviennent plus fréquents, et l\'ambiance générale de la ville, tout en restant festive, perd de cette fluidité qui fait le charme des périodes plus calmes.'},
        {'nom': 'Juillet', 'estBon': false, 'saison': 'Été', 'raison': 'Juillet est le mois des vacances scolaires, ce qui sature l\'espace public anversois avec un mélange de touristes et de locaux profitant de l\'été. La chaleur réverbérée sur les pierres et le béton peut rendre les promenades pénibles, et les principaux monuments sont souvent bondés. L\'affluence est élevée, ce qui diminue significativement le confort de votre séjour, surtout si vous cherchez à explorer le centre historique dans le calme.'},
        {'nom': 'Août', 'estBon': false, 'saison': 'Été', 'raison': 'Août est souvent marqué par des périodes de canicule qui transforment le cœur de la ville en une fournaise, rendant les longues marches urbaines assez inconfortables. Les restaurants et les attractions sont complets en permanence, ce qui nécessite une planification rigoureuse souvent stressante. C\'est une période très fréquentée où le charme métropolitain d\'Anvers est quelque peu masqué par la densité humaine et les fortes chaleurs.'},
        {'nom': 'Septembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Septembre offre un retour à une atmosphère beaucoup plus équilibrée, avec une météo douce et vivifiante qui rend les explorations urbaines très agréables. Les musées retrouvent leur calme, permettant d\'admirer les collections artistiques sans bousculade. En visitant en semaine, vous profiterez d\'une ville qui vit à son propre rythme, idéale pour une découverte culturelle riche et sereine.'},
        {'nom': 'Octobre', 'estBon': true, 'saison': 'Automne', 'raison': 'Octobre sublime la gare et les rues historiques avec une lumière automnale dorée qui crée une atmosphère unique et très esthétique. C\'est le moment privilégié pour découvrir la richesse du patrimoine rubénien et les quartiers des diamantaires dans une ambiance feutrée. En évitant les week-ends, vous vous assurez une visite fluide et authentique de la cité flamande.'},
        {'nom': 'Novembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Novembre est une période très intéressante pour les amateurs de culture qui souhaitent s\'immerger dans les galeries et musées anversois loin de toute pression touristique. La ville est silencieuse et offre une atmosphère introspective propice aux découvertes. Les températures fraîches ne sont pas un frein, au contraire, elles incitent à la découverte des cafés et bistrots typiques de la ville.'},
        {'nom': 'Décembre', 'estBon': false, 'saison': 'Hiver', 'raison': 'Décembre transforme Anvers en une destination de shopping frénétique, provoquant des foules oppressantes dans les artères commerçantes et saturant les capacités d\'accueil de la ville. Le froid piquant conjugué à une forte densité de visiteurs rend la visite classique pénible. Les week-ends sont à proscrire totalement si vous cherchez une expérience de voyage plaisante et sans stress.'},
      ];
    } else { // Liège
      return [
        {'nom': 'Janvier', 'estBon': false, 'saison': 'Hiver', 'raison': 'Janvier à Liège est caractérisé par un froid vif, souvent accentué par l\'humidité de la Meuse qui pénètre les vêtements. Les célèbres escaliers de la ville, comme la Montagne de Bueren, deviennent glissants et dangereux, ce qui limite les options de balades panoramiques. L\'atmosphère générale est plutôt morose et incitative à rester dans les intérieurs, rendant la découverte de la ville moins dynamique.'},
        {'nom': 'Février', 'estBon': false, 'saison': 'Hiver', 'raison': 'Le climat de février reste lourd et souvent brumeux, ce qui masque les points de vue imprenables sur la vallée de la Meuse depuis les hauteurs de la citadelle. La grisaille hivernale pèse sur la ville, et les activités extérieures manquent de l\'éclat nécessaire pour être véritablement appréciées. C\'est un mois à éviter si vous prévoyez une découverte complète et lumineuse de la cité ardente.'},
        {'nom': 'Mars', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mars marque un réveil salvateur, avec des journées plus clémentes qui permettent de redécouvrir les charmes de Liège sans souffrir du froid hivernal. L\'atmosphère devient plus conviviale, et les Liégeois commencent à réinvestir les places. En visitant en semaine, vous profiterez d\'une authenticité préservée et d\'une ville qui sort de son hibernation en toute tranquilidad.'},
        {'nom': 'Avril', 'estBon': true, 'saison': 'Printemps', 'raison': 'Avril apporte une belle énergie printanière, avec une nature qui verdit sur les coteaux et une ville qui respire la joie de vivre. Les conditions sont parfaites pour arpenter les ruelles escarpées du centre historique et les sentiers de randonnée urbaine. C\'est un mois idéal pour découvrir Liège sous son meilleur profil, à condition de privilégier les jours de semaine pour conserver cette sensation d\'espace.'},
        {'nom': 'Mai', 'estBon': true, 'saison': 'Printemps', 'raison': 'Mai est incontestablement un mois béni pour Liège, avec des parcs éclatants de verdure et une météo souvent très agréable. L\'ambiance est décontractée, les terrasses bordant la Meuse invitent à la flânerie, et la culture locale est accessible avec le sourire. Un séjour en milieu de semaine garantit une immersion totale dans la convivialité liégeoise, loin des pics de fréquentation touristique.'},
        {'nom': 'Juin', 'estBon': false, 'saison': 'Été', 'raison': 'Juin marque une hausse des températures qui peut rendre la découverte de la ville, située en cuvette, assez étouffante. L\'activité nocturne devient très intense, ce qui peut perturber la quiétude nécessaire à une visite culturelle. L\'agitation urbaine augmente, et les lieux publics commencent à être très fréquentés, ce qui diminue le confort des promenades historiques en journée.'},
        {'nom': 'Juillet', 'estBon': false, 'saison': 'Été', 'raison': 'Juillet est le mois des grandes vacances, où la chaleur s\'accumule dans les ruelles étroites, rendant les marches urbaines épuisantes. Les festivités estivales attirent un public local important, ce qui sature les infrastructures de la ville. Bien que l\'ambiance soit festive, ce n\'est pas la période idéale si vous recherchez une découverte patrimoniale sereine et confortable de Liège.'},
        {'nom': 'Août', 'estBon': false, 'saison': 'Été', 'raison': 'Août est dominé par des événements folkloriques majeurs, comme ceux d\'Outremeuse, qui transforment radicalement le fonctionnement de la ville. Si c\'est une période riche culturellement pour les locaux, elle paralyse les visites touristiques classiques en raison des foules et des restrictions d\'accès. C\'est une période très spéciale, mais à éviter absolument si vous cherchez le calme pour votre séjour.'},
        {'nom': 'Septembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Septembre offre un répit très apprécié, avec un climat automnal doux et une atmosphère beaucoup plus sereine. Les lumières subliment les bâtiments historiques sans la chaleur étouffante de l\'été. C\'est un moment parfait pour les amateurs d\'histoire et d\'architecture qui veulent découvrir Liège sans stress, en profitant de la bienveillance des habitants et de la fluidité de visite.'},
        {'nom': 'Octobre', 'estBon': true, 'saison': 'Automne', 'raison': 'Octobre est sans doute l\'un des mois les plus romantiques à Liège, avec les coteaux de la Citadelle qui se parent de leurs plus belles couleurs. La ville est calme et invite aux déambulations dans les ruelles anciennes. C\'est une période idéale pour prendre le temps de vivre à la liégeoise, loin des foules et des vacances, pour une expérience de voyage enrichissante et apaisée.'},
        {'nom': 'Novembre', 'estBon': true, 'saison': 'Automne', 'raison': 'Novembre offre une occasion unique de découvrir les musées et le patrimoine liégeois d\'une manière très intimiste, sans aucune file d\'attente. La fraîcheur de la saison invite à s\'immerger dans les traditions culinaires locales, très chaleureuses, et à échanger avec les Liégeois dans les bistrots historiques. Un voyage en semaine permet de profiter de cette authenticité rare en toute sérénité.'},
        {'nom': 'Décembre', 'estBon': false, 'saison': 'Hiver', 'raison': 'Décembre à Liège est synonyme de Village de Noël, attirant des foules monumentales qui rendent la circulation dans le centre-ville très difficile. Cette saturation est préjudiciable à la découverte culturelle classique, car les monuments sont souvent entourés par l\'agitation festive. Malgré la magie de Noël, la logistique liée à la densité de visiteurs rend le séjour peu confortable en cette période de l\'année.'},
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
        ? 'CHOISISSEZ UNE VILLE'
        : (estEnGenerationVitesse ? 'ANALYSE EN COURS' : 'GÉNÉRER MON PLANNING');
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
                        'ANALYSE ANNUELLE',
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
                          _chip('$bons MOIS IDÉAUX', vert, Icons.check_circle_rounded),
                          _chip('$mauvais À ÉVITER', rouge, Icons.do_not_disturb_on_rounded),
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
        _sectionLabel('MOIS PAR MOIS'),
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
                          'Planification',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF60A5FA),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quand visiter',
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        _GoldShimmerText(
                          'la Belgique ?',
                          style: GoogleFonts.cinzel(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Choisissez une ville : nous analysons les 12 mois de l\'année pour vous.',
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
                                  'RAPPEL MÉTÉO',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFFFBBF24),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.4,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Même si la période est recommandée, vérifiez toujours la météo avant de partir.',
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
                  _Reveal(delayMs: 280, child: _sectionLabel('VOTRE VILLE')),
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

// --- PAGE DES FAVORIS 2026 : aurore, bannières photo, dépliage animé ---
class FavorisFrPage extends StatefulWidget {
  const FavorisFrPage({super.key});

  @override
  State<FavorisFrPage> createState() => _FavorisFrPageState();
}

class _FavorisFrPageState extends State<FavorisFrPage> {
  List<String> _favorisBruxellesIds = [];
  List<String> _favorisGandIds = [];
  List<String> _favorisBrugesIds = [];
  List<String> _favorisAnversIds = [];
  List<String> _favorisLiegeIds = [];
  bool _isLoading = true;

  // Ensembles pour stocker les dossiers et quartiers ouverts sans animation
  final Set<String> _dossiersOuverts = {};
  final Set<String> _quartiersOuverts = {};

  final Map<String, Map<String, dynamic>> _tousLesLieux = {
    // --- BRUXELLES ---
    'parlement': {
      'titre': 'Parlement Européen',
      'images': ['assets4/belgique/bruxelles/1.jpg', 'assets4/belgique/bruxelles/2.jpg', 'assets4/belgique/bruxelles/3.jpg'],
      'quartier': 'Quartier Européen',
      'dossier': 'Bruxelles'
    },
    'cinquantenaire': {
      'titre': 'Parc du Cinquantenaire',
      'images': ['assets4/belgique/bruxelles/4.jpg', 'assets4/belgique/bruxelles/5.png'],
      'quartier': 'Quartier Européen',
      'dossier': 'Bruxelles'
    },
    'leopold': {
      'titre': 'Parc Léopold',
      'images': ['assets4/belgique/bruxelles/7.jpg'],
      'quartier': 'Quartier Européen',
      'dossier': 'Bruxelles'
    },
    'grandplace': {
      'titre': 'Grand-Place',
      'images': ['assets4/belgique/bruxelles/9.jpg', 'assets4/belgique/bruxelles/10.jpg', 'assets4/belgique/bruxelles/11.jpg'],
      'quartier': 'Centre Historique',
      'dossier': 'Bruxelles'
    },
    'mannekenpis': {
      'titre': 'Manneken-Pis et Jeanneke-Pis',
      'images': ['assets4/belgique/bruxelles/199.jpg', 'assets4/belgique/bruxelles/14.jpg'],
      'quartier': 'Centre Historique',
      'dossier': 'Bruxelles'
    },
    'galeries': {
      'titre': 'Galeries Royales Saint-Hubert',
      'images': ['assets4/belgique/bruxelles/15.jpg'],
      'quartier': 'Centre Historique',
      'dossier': 'Bruxelles'
    },
    'montdesarts': {
      'titre': 'Mont des Arts',
      'images': ['assets4/belgique/bruxelles/16.jpg', 'assets4/belgique/bruxelles/17.webp'],
      'quartier': 'Centre Historique',
      'dossier': 'Bruxelles'
    },
    'palaisjustice': {
      'titre': 'Palais de Justice',
      'images': ['assets4/belgique/bruxelles/18.jpg', 'assets4/belgique/bruxelles/19.webp', 'assets4/belgique/bruxelles/20.webp', 'assets4/belgique/bruxelles/21.jpg'],
      'quartier': 'Centre Historique',
      'dossier': 'Bruxelles'
    },
    'atomium': {
      'titre': 'Atomium',
      'images': ['assets4/belgique/bruxelles/22.jpg', 'assets4/belgique/bruxelles/23.jpg', 'assets4/belgique/bruxelles/24.jpg'],
      'quartier': 'Heyzel / Nord',
      'dossier': 'Bruxelles'
    },
    'minieurope': {
      'titre': 'Mini-Europe',
      'images': ['assets4/belgique/bruxelles/25.webp', 'assets4/belgique/bruxelles/26.jpg'],
      'quartier': 'Heyzel / Nord',
      'dossier': 'Bruxelles'
    },
    'laeken': {
      'titre': 'Serres Royales de Laeken',
      'images': ['assets4/belgique/bruxelles/27.webp', 'assets4/belgique/bruxelles/28.jpg', 'assets4/belgique/bruxelles/29.webp'],
      'quartier': 'Laeken (Nord-Ouest)',
      'dossier': 'Bruxelles'
    },

    // --- GAND ---
    'chateau_comtes': {
      'titre': 'Le Château des Comtes',
      'images': ['assets4/belgique/gand/1.jpeg', 'assets4/belgique/gand/2.jpg', 'assets4/belgique/gand/3.jpg'],
      'quartier': 'Les Incontournables de Gand',
      'dossier': 'Gand'
    },
    'beffroi_gand': {
      'titre': 'Le Beffroi de Gand',
      'images': ['assets4/belgique/gand/4.jpg'],
      'quartier': 'Les Incontournables de Gand',
      'dossier': 'Gand'
    },
    'saint_bavon': {
      'titre': 'La Cathédrale Saint-Bavon',
      'images': ['assets4/belgique/gand/5.jpg', 'assets4/belgique/gand/6.jpg'],
      'quartier': 'Les Incontournables de Gand',
      'dossier': 'Gand'
    },
    'quai_herbes_grains': {
      'titre': 'Le Quai aux Herbes (Graslei) et le Quai aux Grains (Korenlei)',
      'images': ['assets4/belgique/gand/7.jpg'],
      'quartier': 'Les Incontournables de Gand',
      'dossier': 'Gand'
    },
    'pont_saint_michel': {
      'titre': 'Le Pont Saint-Michel',
      'images': ['assets4/belgique/gand/8.webp', 'assets4/belgique/gand/9.webp', 'assets4/belgique/gand/12.webp'],
      'quartier': 'Les Incontournables de Gand',
      'dossier': 'Gand'
    },

    // --- BRUGES ---
    'canaux_bruges': {
      'titre': 'Les Canaux de Bruges',
      'images': ['assets4/belgique/bruges/1.webp', 'assets4/belgique/bruges/2.jpg', 'assets4/belgique/bruges/3.webp'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },
    'quai_rosaire': {
      'titre': 'Le Quai du Rosaire (Rozenhoedkaai)',
      'images': ['assets4/belgique/bruges/4.jpg', 'assets4/belgique/bruges/6.jpg'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },
    'beffroi_bruges': {
      'titre': 'Le Beffroi de Bruges',
      'images': ['assets4/belgique/bruges/9.webp'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },
    'grote_markt': {
      'titre': 'La Grande-Place (Grote Markt)',
      'images': ['assets4/belgique/bruges/11.webp', 'assets4/belgique/bruges/12.webp', 'assets4/belgique/bruges/14.webp'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },
    'godshuizen': {
      'titre': 'Les Godshuizen (Maisons de Dieu)',
      'images': ['assets4/belgique/bruges/15.webp', 'assets4/belgique/bruges/16.webp'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },
    'moulins_bruges': {
      'titre': 'Les Moulins à vent de Bruges',
      'images': ['assets4/belgique/bruges/17.jpeg'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },
    'basilique_saintsang': {
      'titre': 'La Basilique du Saint-Sang',
      'images': ['assets4/belgique/bruges/20.jpg', 'assets4/belgique/bruges/21.webp'],
      'quartier': 'Les Incontournables de Bruges',
      'dossier': 'Bruges'
    },

    // --- ANVERS ---
    'gare_centrale_anvers': {
      'titre': 'La Gare d\'Anvers-Central',
      'images': ['assets4/belgique/anvers/1.jpg', 'assets4/belgique/anvers/2.jpg', 'assets4/belgique/anvers/3.webp', 'assets4/belgique/anvers/4.webp'],
      'quartier': 'Les Incontournables d\'Anvers',
      'dossier': 'Anvers'
    },
    'grote_markt_anvers': {
      'titre': 'La Grand-Place (Grote Markt)',
      'images': ['assets4/belgique/anvers/5.jpg', 'assets4/belgique/anvers/6.jpg', 'assets4/belgique/anvers/7.webp'],
      'quartier': 'Les Incontournables d\'Anvers',
      'dossier': 'Anvers'
    },
    'cathedrale_notredame_anvers': {
      'titre': 'La Cathédrale Notre-Dame',
      'images': ['assets4/belgique/anvers/8.jpg'],
      'quartier': 'Les Incontournables d\'Anvers',
      'dossier': 'Anvers'
    },
    'het_steen': {
      'titre': 'Le Het Steen',
      'images': ['assets4/belgique/anvers/9.webp', 'assets4/belgique/anvers/10.webp', 'assets4/belgique/anvers/11.webp'],
      'quartier': 'Les Incontournables d\'Anvers',
      'dossier': 'Anvers'
    },

    // --- LIÈGE ---
    'montagne_bueren': {
      'titre': 'La Montagne de Bueren',
      'images': ['assets4/belgique/liege/1.webp', 'assets4/belgique/liege/2.webp', 'assets4/belgique/liege/1 bis.webp'],
      'quartier': 'Les Incontournables de Liège',
      'dossier': 'Liège'
    },
    'coteaux_citadelle': {
      'titre': 'Les Coteaux de la Citadelle',
      'images': ['assets4/belgique/liege/3.jpg', 'assets4/belgique/liege/4.jpg'],
      'quartier': 'Les Incontournables de Liège',
      'dossier': 'Liège'
    },
    'gare_liege_guillemins': {
      'titre': 'La Gare de Liège-Guillemins',
      'images': ['assets4/belgique/liege/5.jpg', 'assets4/belgique/liege/6.webp', 'assets4/belgique/liege/7.jpg'],
      'quartier': 'Les Incontournables de Liège',
      'dossier': 'Liège'
    },
    'cathedrale_saint_paul': {
      'titre': 'La Cathédrale Saint-Paul',
      'images': ['assets4/belgique/liege/8.jpg'],
      'quartier': 'Les Incontournables de Liège',
      'dossier': 'Liège'
    },
    'ruelles_impasses_liege': {
      'titre': 'Les Ruelles et Impasses de Liège',
      'images': ['assets4/belgique/liege/10.jpg', 'assets4/belgique/liege/15.jpg', 'assets4/belgique/liege/12.webp'],
      'quartier': 'Les Incontournables de Liège',
      'dossier': 'Liège'
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
    setState(() {
      _favorisBruxellesIds = prefs.getStringList('favoris_bruxelles_fr') ?? [];
      _favorisGandIds = prefs.getStringList('favoris_gand_fr') ?? [];
      _favorisBrugesIds = prefs.getStringList('favoris_bruges_fr') ?? [];
      _favorisAnversIds = prefs.getStringList('favoris_anvers_fr') ?? [];
      _favorisLiegeIds = prefs.getStringList('favoris_liege_fr') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id, String dossier) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      if (dossier == 'Bruxelles') {
        _favorisBruxellesIds.remove(id);
        prefs.setStringList('favoris_bruxelles_fr', _favorisBruxellesIds);
      } else if (dossier == 'Gand') {
        _favorisGandIds.remove(id);
        prefs.setStringList('favoris_gand_fr', _favorisGandIds);
      } else if (dossier == 'Bruges') {
        _favorisBrugesIds.remove(id);
        prefs.setStringList('favoris_bruges_fr', _favorisBrugesIds);
      } else if (dossier == 'Anvers') {
        _favorisAnversIds.remove(id);
        prefs.setStringList('favoris_anvers_fr', _favorisAnversIds);
      } else if (dossier == 'Liège') {
        _favorisLiegeIds.remove(id);
        prefs.setStringList('favoris_liege_fr', _favorisLiegeIds);
      }
    });
  }

  // -------------------------------------------------------------------------
  //  Aides de lecture des favoris
  // -------------------------------------------------------------------------
  List<String> _idsPour(String dossier) {
    if (dossier == 'Bruxelles') return _favorisBruxellesIds;
    if (dossier == 'Gand') return _favorisGandIds;
    if (dossier == 'Bruges') return _favorisBrugesIds;
    if (dossier == 'Anvers') return _favorisAnversIds;
    return _favorisLiegeIds;
  }

  List<Map<String, dynamic>> _lieuxPour(String dossier, String quartier) {
    final List<Map<String, dynamic>> res = [];
    for (final String id in _idsPour(dossier)) {
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
    for (final String id in _idsPour(dossier)) {
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
          _statCell(total, total > 1 ? 'LIEUX' : 'LIEU'),
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
          _statCell(villesActives, villesActives > 1 ? 'VILLES' : 'VILLE'),
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
              'Aucun favori',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Touchez le cœur sur les lieux qui vous plaisent dans les pages des villes : ils apparaîtront ici, classés par quartier.',
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
                                ? 'AUCUN LIEU'
                                : (count == 1 ? '1 LIEU SAUVEGARDÉ' : '$count LIEUX SAUVEGARDÉS'),
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
                    'Aucun favori dans cette section.',
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
                  _retirerFavori(lieu['id'].toString(), dossierNom);
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
    final dossiers = ['Bruxelles', 'Gand', 'Bruges', 'Anvers', 'Liège'];

    final Map<String, List<String>> quartiersParVille = {
      'Bruxelles': ['Quartier Européen', 'Centre Historique', 'Heyzel / Nord', 'Laeken (Nord-Ouest)'],
      'Gand': ['Les Incontournables de Gand'],
      'Bruges': ['Les Incontournables de Bruges'],
      'Anvers': ['Les Incontournables d\'Anvers'],
      'Liège': ['Les Incontournables de Liège'],
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
                              label: 'RETOUR',
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
                            'VOTRE SÉLECTION',
                            style: GoogleFonts.montserrat(
                              color: _kChampagne.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _GoldShimmerText(
                            'Mes Favoris',
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
      body: Center(child: Text('Page en développement pour $cityName', style: const TextStyle(color: Colors.white70))),
    );
  }
}