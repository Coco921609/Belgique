import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// =============================================================================
//  DESIGN TOKENS
// =============================================================================
const Color _bgObsidian = Color(0xFF0F0F12);
const Color _surface = Color(0xFF1C1B20);
const Color _surfaceHigh = Color(0xFF2B2A31);
const Color _goldAccent = Color(0xFFFF4B2B);
const Color _goldLight = Color(0xFFD6F55B);
const Color _textMuted = Color(0xFFA9A59C);
const Color _amberTint = Color(0xFFFFD9A0);
const Color _rose = Color(0xFFFFB4A2);
const Color _paper = Color(0xFFF1ECE2);
const Color _ink = Color(0xFF0E0E10);
const Color _lime = Color(0xFFD6F55B);
const Color _sand = Color(0xFFFFD9A0);
const Color _fgSoft = Color(0xFFA9A59C);

TextStyle _serif({
  double size = 24,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? spacing,
  FontStyle? style,
}) => TextStyle(
  fontFamily: 'Georgia',
  fontFamilyFallback: const ['Times New Roman', 'serif'],
  fontSize: size,
  fontWeight: weight,
  color: color ?? _paper,
  height: height,
  letterSpacing: spacing,
  fontStyle: style,
);


// =============================================================================
//  DONNÉES (source unique pour les deux écrans)
// =============================================================================
final List<Map<String, dynamic>> _kQuartiersAnvers = [
  {
    'quartier': 'Les Incontournables d\'Anvers',
    'lieux': [
      {
        'id': 'gare_centrale_anvers',
        'titre': 'La Gare d\'Anvers-Central',
        'images': [
          'assets4/belgique/anvers/1.jpg',
          'assets4/belgique/anvers/2.jpg',
          'assets4/belgique/anvers/3.webp',
          'assets4/belgique/anvers/4.webp'
        ],
        'histoire':
        'Souvent qualifiée de "Cathédrale du Rail", la Gare d\'Anvers-Central est considérée comme l\'une des plus belles gares ferroviaires au monde. Inaugurée en 1905, son architecture éclectique monumentale mêle un dôme grandiose, un hall majestueux revêtu de marbre et une immense verrière en fer et en verre.',
        'conseil': 'Prendre le temps d\'admirer le hall principal et la verrière depuis les niveaux supérieurs. Vérifier la météo avant de partir.',
        'mapsQuery': 'Gare d\'Anvers-Central',
      },
      {
        'id': 'grote_markt_anvers',
        'titre': 'La Grand-Place (Grote Markt)',
        'images': [
          'assets4/belgique/anvers/5.jpg',
          'assets4/belgique/anvers/6.jpg',
          'assets4/belgique/anvers/7.webp'
        ],
        'histoire':
        'Cœur historique de la ville, la Grand-Place d\'Anvers est entourée par le majestueux Hôtel de Ville de style Renaissance italienne et flamande, ainsi que par d\'opulentes maisons de corporations surmontées de statues dorées. En son centre se dresse la fontaine spectaculaire représentant Silvius Brabo.',
        'conseil': 'L\'endroit parfait pour s\'installer en terrasse et admirer les façades illuminées. Vérifier la météo avant de partir.',
        'mapsQuery': 'Grote Markt Anvers',
      },
      {
        'id': 'cathedrale_notredame_anvers',
        'titre': 'La Cathédrale Notre-Dame',
        'images': [
          'assets4/belgique/anvers/8.jpg',
        ],
        'histoire':
        'Chef-d\'œuvre absolu de l\'art gothique brabançon, la cathédrale Notre-Dame d\'Anvers dresse son clocher majestueux à 123 mètres de hauteur, inscrit au patrimoine mondial de l\'UNESCO. Son intérieur spectaculaire abrite plusieurs chefs-d\'œuvre majeurs du célèbre peintre baroque Pierre Paul Rubens.',
        'conseil': 'Prendre le temps d\'observer les tableaux monumentaux de Rubens à l\'intérieur. Vérifier la météo avant de partir.',
        'mapsQuery': 'Cathédrale Notre-Dame Anvers',
      },
      {
        'id': 'het_steen',
        'titre': 'Le Het Steen',
        'images': [
          'assets4/belgique/anvers/9.webp',
          'assets4/belgique/anvers/10.webp',
          'assets4/belgique/anvers/11.webp',
        ],
        'histoire':
        'Surveillant les berges de l\'Escaut, le Het Steen est le plus ancien bâtiment de la ville (érigé au XIIIe siècle). Cet ancien château fort médiéval, qui servait autrefois de porte fortifiée et de prison, accueille désormais le centre d\'accueil des visiteurs et offre une terrasse panoramique sur le fleuve.',
        'conseil': 'Monter sur le toit-terrasse pour bénéficier d\'une vue dégagée sur l\'Escaut et le port. Vérifier la météo avant de partir.',
        'mapsQuery': 'Het Steen Anvers',
      },
    ],
  },
];

/// Toutes les fiches d'une liste de quartiers, à plat.
List<Map<String, dynamic>> _lieuxDe(List<Map<String, dynamic>> quartiers) => [
  for (final q in quartiers)
    ...(q['lieux'] as List).cast<Map<String, dynamic>>(),
];

// =============================================================================
//  OUTILS PARTAGÉS
// =============================================================================

/// Transition : fondu + léger glissement vers le haut (ou fondu seul).
Route<T> _route<T>(Widget page, {bool slide = true}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 480),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: slide
            ? SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
          child: child,
        )
            : child,
      );
    },
  );
}

/// Image d'asset avec gestion d'erreur élégante.
Widget _img(String path, {BoxFit fit = BoxFit.cover, bool expand = true}) {
  return Image.asset(
    path,
    fit: fit,
    width: expand ? double.infinity : null,
    height: expand ? double.infinity : null,
    gaplessPlayback: true,
    errorBuilder: (_, __, ___) => Container(
      color: _surfaceHigh,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 40),
    ),
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: _surface,
  borderRadius: BorderRadius.circular(32),
  border: Border.all(color: _paper.withOpacity(0.08), width: 0.8),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.38),
      blurRadius: 34,
      offset: const Offset(0, 16),
    ),
  ],
);

// =============================================================================
//  WIDGETS RÉUTILISABLES
// =============================================================================

/// Fond animé : deux halos dorés/violets qui dérivent lentement.
class _AmbientBackground extends StatefulWidget {
  const _AmbientBackground();

  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_c.value);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.9 + 0.5 * t, -0.8),
                      radius: 0.9,
                      colors: [_goldAccent.withOpacity(0.10), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(1.0 - 0.6 * t, 0.9 - 0.3 * t),
                      radius: 1.0,
                      colors: [const Color(0xFF3A2D6E).withOpacity(0.18), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Apparition progressive (fondu + montée) à l'affichage, avec délai optionnel.
class _Reveal extends StatefulWidget {
  const _Reveal({super.key, required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Retour tactile : légère réduction à l'appui.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (mounted && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Image qui s'agrandit légèrement au toucher avant d'ouvrir la galerie plein écran.
class _ZoomTapImage extends StatefulWidget {
  const _ZoomTapImage({required this.path, required this.onTap});

  final String path;
  final VoidCallback onTap;

  @override
  State<_ZoomTapImage> createState() => _ZoomTapImageState();
}

class _ZoomTapImageState extends State<_ZoomTapImage> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) {
        _set(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: _img(widget.path),
      ),
    );
  }
}

/// Bouton icône en verre dépoli.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: _Pressable(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

/// Barre supérieure commune (utilisée par l'écran Favoris).
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _goldAccent,
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// Petite pastille (compteur, légende).
class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Encadré conseil.
class _TipBox extends StatelessWidget {
  const _TipBox({required this.icon, required this.text, required this.textColor, this.bg = const Color(0xFFD6F55B)});

  final IconData icon;
  final String text;
  final Color textColor;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _ink, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: textColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton principal doré à dégradé.
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_goldLight, _goldAccent]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _goldAccent.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _bgObsidian),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: _bgObsidian,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton secondaire (doré ou neutre).
class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.label, required this.onTap, this.gold = false});

  final String label;
  final VoidCallback onTap;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        decoration: BoxDecoration(
          color: gold ? _goldAccent.withOpacity(0.12) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: gold ? _goldAccent.withOpacity(0.35) : Colors.white.withOpacity(0.09),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: gold ? _goldLight : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Barre de progression segmentée : un segment allumé par lieu visité.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.total, required this.filled, required this.color});

  final int total;
  final int filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    return Row(
      children: List.generate(total, (i) {
        final bool on = i < filled;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 380 + i * 35),
              curve: Curves.easeOutCubic,
              height: 10,
              decoration: BoxDecoration(
                color: on ? null : Colors.white.withOpacity(0.08),
                gradient: on
                    ? LinearGradient(colors: [color.withOpacity(0.55), color])
                    : null,
                borderRadius: BorderRadius.circular(6),
                boxShadow: on
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Pastille « visité » animée.
class _VisitChip extends StatelessWidget {
  const _VisitChip({required this.isVisite, required this.onTap});

  final bool isVisite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isVisite ? _goldAccent.withOpacity(0.14) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isVisite ? _goldAccent.withOpacity(0.5) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isVisite ? Icons.check_circle : Icons.radio_button_unchecked,
                key: ValueKey(isVisite),
                color: isVisite ? _goldAccent : Colors.white38,
                size: 15,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isVisite ? 'Lieu visité' : 'Marquer comme visité',
              style: TextStyle(
                color: isVisite ? _goldLight : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cœur favori avec rebond élastique.
class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isOn, required this.onTap});

  final bool isOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isOn ? _goldAccent.withOpacity(0.12) : Colors.white.withOpacity(0.04),
          shape: BoxShape.circle,
          border: Border.all(
            color: isOn ? _goldAccent.withOpacity(0.4) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.elasticOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isOn ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isOn),
              color: isOn ? _goldAccent : Colors.white38,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge circulaire avec anneau décoratif qui tourne en continu.
class _RotatingBadge extends StatefulWidget {
  const _RotatingBadge();

  @override
  State<_RotatingBadge> createState() => _RotatingBadgeState();
}

class _RotatingBadgeState extends State<_RotatingBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.35),
            border: Border.all(color: _goldAccent.withOpacity(0.45)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _c,
                child: Icon(Icons.explore_outlined, color: _goldAccent.withOpacity(0.55), size: 46),
              ),
              const Icon(Icons.location_city_rounded, color: _goldLight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titre avec un fin reflet doré qui balaie le texte en boucle.
class _ShimmerText extends StatefulWidget {
  const _ShimmerText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final double t = _c.value;
        final double x = -3 + 4 * t;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [Colors.white, _goldLight, Colors.white],
            stops: const [0.35, 0.5, 0.65],
            begin: Alignment(x, 0),
            end: Alignment(x + 2, 0),
          ).createShader(bounds),
          child: child,
        );
      },
      child: Text(widget.text, style: widget.style.copyWith(color: Colors.white)),
    );
  }
}

/// Bandeau défilant en boucle avec les noms des lieux.
class _MarqueeBanner extends StatefulWidget {
  const _MarqueeBanner({required this.items});

  final List<String> items;

  @override
  State<_MarqueeBanner> createState() => _MarqueeBannerState();
}

class _MarqueeBannerState extends State<_MarqueeBanner> with SingleTickerProviderStateMixin {
  final ScrollController _sc = ScrollController();
  Ticker? _ticker;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _ticker = createTicker((elapsed) {
      if (!_sc.hasClients) return;
      final double max = _sc.position.maxScrollExtent;
      if (max <= 0) return;
      _offset += 0.55;
      if (_offset >= max) _offset = 0;
      _sc.jumpTo(_offset);
    })..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final String bloc = widget.items.join('   •   ');
    final String texte = '$bloc   •   $bloc   •   $bloc';
    return Container(
      height: 38,
      color: Colors.black.withOpacity(0.35),
      alignment: Alignment.centerLeft,
      child: ListView(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              texte,
              style: const TextStyle(
                color: _goldAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carrousel d'images d'un lieu : plus grand, glissement avec aperçu latéral
/// et effet de profondeur (les images voisines sont légèrement réduites),
/// agrandissement discret au toucher avant ouverture en plein écran.
class _Carrousel extends StatefulWidget {
  const _Carrousel({required this.images, required this.onTapImage});

  final List<String> images;
  final ValueChanged<int> onTapImage;

  @override
  State<_Carrousel> createState() => _CarrouselState();
}

class _CarrouselState extends State<_Carrousel> {
  late final PageController _pc = PageController(viewportFraction: 0.94);
  int _index = 0;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pc.addListener(() {
      if (_pc.hasClients && _pc.page != null) {
        setState(() => _page = _pc.page!);
      }
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const SizedBox.shrink();
    final bool multi = images.length > 1;

    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final double diff = (i - _page).abs().clamp(0.0, 1.0);
              final double scale = 1 - diff * 0.12;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Transform.scale(
                  scale: scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _ZoomTapImage(
                      path: images[i],
                      onTap: () => widget.onTapImage(i),
                    ),
                  ),
                ),
              );
            },
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x66000000)],
                  ),
                ),
              ),
            ),
          ),
          if (multi)
            Positioned(
              top: 14,
              right: 20,
              child: _Chip(text: '${_index + 1} / ${images.length}'),
            ),
          if (multi)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index ? _goldAccent : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroInfoPill extends StatelessWidget {
  const _HeroInfoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// En-tête de quartier, affiché en tête de section (état non figé).
class _QuartierTitleBlock extends StatelessWidget {
  const _QuartierTitleBlock({required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 0),
      child: Row(
        children: [
          Text(
            index.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: _goldAccent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _paper,
                fontSize: 21,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Délégué de sliver persistant : le titre du quartier démarre grand, se
/// réduit progressivement puis reste collé en haut pendant la lecture.
class _QuartierHeaderDelegate extends SliverPersistentHeaderDelegate {
  _QuartierHeaderDelegate({required this.index, required this.title});

  final int index;
  final String title;

  static const double _maxExtent = 112;
  static const double _minExtent = 68;

  @override
  double get minExtent => _minExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double t = (shrinkOffset / (_maxExtent - _minExtent)).clamp(0.0, 1.0);
    final double fontSize = lerpDouble(21, 15, t)!;
    final double numberSize = lerpDouble(13, 11, t)!;
    final double spacer = lerpDouble(14, 8, t)!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10 * t, sigmaY: 10 * t),
        child: Container(
          color: _bgObsidian.withOpacity(0.92 * t),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: _goldAccent,
                      fontSize: numberSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacer),
              Opacity(
                opacity: 1 - t * 0.35,
                child: const SizedBox(
                  width: double.infinity,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_goldAccent, Colors.transparent]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _QuartierHeaderDelegate oldDelegate) =>
      oldDelegate.title != title || oldDelegate.index != index;
}

/// Lévitation douce d'un élément (état vide).
class _Float extends StatefulWidget {
  const _Float({required this.child});

  final Widget child;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
    );
  }
}

// =============================================================================
//  GALERIE PLEIN ÉCRAN
// =============================================================================
class _GalerieEcran extends StatefulWidget {
  const _GalerieEcran({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_GalerieEcran> createState() => _GalerieEcranState();
}

class _GalerieEcranState extends State<_GalerieEcran> {
  late final PageController _pc = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              maxScale: 5.0,
              child: Center(
                child: _img(images[i], fit: BoxFit.contain, expand: false),
              ),
            ),
          ),
          Positioned(
            top: 52,
            right: 20,
            child: _GlassIconButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: _Chip(text: '${_index + 1} / ${images.length}'),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
//  PAGE PRINCIPALE — GAND
// =============================================================================
class Anvers extends StatefulWidget {
  const Anvers({super.key});

  @override
  State<Anvers> createState() => _AnversState();
}

class _AnversState extends State<Anvers> {
  List<String> _favorisAnversFr = [];
  List<String> _lieuxVisitesAnvers = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chargerDonneesAnvers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets4/belgique/anvers/11.webp'), context);
      for (final lieu in _lieuxDe(_kQuartiersAnvers)) {
        for (final String imgPath in List<String>.from(lieu['images'] as List)) {
          precacheImage(AssetImage(imgPath), context);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  //  Données & persistance (logique inchangée)
  // ---------------------------------------------------------------------------
  Future<void> _chargerDonneesAnvers() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisAnversFr = List<String>.from(prefs.getStringList('favoris_anvers_fr') ?? []);
      _lieuxVisitesAnvers = List<String>.from(prefs.getStringList('lieux_visites_anvers_fr') ?? []);
    });
  }

  Future<void> _basculerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorisAnversFr.contains(id)) {
        _favorisAnversFr.remove(id);
      } else {
        _favorisAnversFr.add(id);
      }
    });
    await prefs.setStringList('favoris_anvers_fr', _favorisAnversFr);
  }

  Future<void> _toutAjouterFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisAnversFr = _lieuxDe(_kQuartiersAnvers).map((l) => l['id'] as String).toList();
    });
    await prefs.setStringList('favoris_anvers_fr', _favorisAnversFr);
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _favorisAnversFr.clear());
    await prefs.setStringList('favoris_anvers_fr', _favorisAnversFr);
  }

  Future<void> _basculerVisite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_lieuxVisitesAnvers.contains(id)) {
        _lieuxVisitesAnvers.remove(id);
      } else {
        _lieuxVisitesAnvers.add(id);
      }
    });
    await prefs.setStringList('lieux_visites_anvers_fr', _lieuxVisitesAnvers);
  }

  Future<void> _toutMarquerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisitesAnvers = _lieuxDe(_kQuartiersAnvers).map((l) => l['id'] as String).toList();
    });
    await prefs.setStringList('lieux_visites_anvers_fr', _lieuxVisitesAnvers);
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lieuxVisitesAnvers.clear());
    await prefs.setStringList('lieux_visites_anvers_fr', _lieuxVisitesAnvers);
  }

  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _ouvrirGalerie(List<String> images, int index) {
    Navigator.of(context).push(
      _route(_GalerieEcran(images: images, initialIndex: index), slide: false),
    );
  }

  Future<void> _ouvrirFavoris() async {
    await Navigator.of(context).push(
      _route(FavorisAnversPage(quartiersAnvers: _kQuartiersAnvers)),
    );
    _chargerDonneesAnvers();
  }

  // ---------------------------------------------------------------------------
  //  Construction de l'interface
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final int totalLieux = _lieuxDe(_kQuartiersAnvers).length;
    final int nbVisites = _lieuxVisitesAnvers.length;
    final double progression = totalLieux > 0 ? nbVisites / totalLieux : 0.0;

    Color couleurProgression = Colors.orangeAccent;
    if (progression > 0.3 && progression <= 0.7) {
      couleurProgression = _goldAccent;
    } else if (progression > 0.7) {
      couleurProgression = Colors.greenAccent;
    }

    return Scaffold(
      backgroundColor: _bgObsidian,
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHero()),
              SliverToBoxAdapter(
                child: _MarqueeBanner(
                  items: _lieuxDe(_kQuartiersAnvers).map((l) => l['titre'] as String).toList(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _Reveal(delay: 100, child: _buildIntro())),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: _Reveal(
                  delay: 180,
                  child: _buildProgressCard(totalLieux, nbVisites, progression, couleurProgression),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(child: _Reveal(delay: 240, child: _buildListesCard())),
              for (int qi = 0; qi < _kQuartiersAnvers.length; qi++) ..._buildQuartierSlivers(qi),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: _GlassIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    const String heroImage = 'assets4/belgique/anvers/11.webp';
    final int totalLieux = _lieuxDe(_kQuartiersAnvers).length;
    return Padding(
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 66, 10, 0),
      child: GestureDetector(
        onTap: () => _ouvrirGalerie(const [heroImage], 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(42),
          child: SizedBox(
            height: 520,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.2, end: 1.04),
                  duration: const Duration(milliseconds: 2400),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: _img(heroImage),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Colors.transparent, Color(0x99000000), Color(0xE60E0E10)],
                      stops: [0.0, 0.25, 0.65, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: _lime, borderRadius: BorderRadius.circular(22)),
                    child: const Text(
                      'BELGIQUE',
                      style: TextStyle(color: _ink, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 3),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anvers · Guide de voyage',
                        style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Text('La Cité', style: _serif(size: 62, weight: FontWeight.w300, height: 1.0, spacing: -1.8, color: Colors.white)),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) => const LinearGradient(colors: [_lime, _sand, Color(0xFFFFB4A2)]).createShader(b),
                        child: Text(
                          'des Lumières',
                          style: _serif(size: 46, weight: FontWeight.w300, height: 1.1, spacing: -0.8, style: FontStyle.italic, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _HeroInfoPill(label: '${_kQuartiersAnvers.length} quartier'),
                          const SizedBox(width: 8),
                          _HeroInfoPill(label: '$totalLieux lieux'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ville flamande au charme singulier, Anvers dévoile ses canaux, ses quais historiques et ses silhouettes médiévales. Entre patrimoine remarquable et énergie contemporaine, elle cultive une atmosphère aussi vivante que romantique.',
            style: _serif(size: 21, weight: FontWeight.w400, color: _paper, height: 1.55, spacing: -0.2),
          ),
          const SizedBox(height: 22),
          _TipBox(
            icon: Icons.info_outline_rounded,
            text: 'Conseils : Visiter Anvers en semaine, hors vacances scolaires et éviter les week-ends. Pensez à vérifier la météo avant de partir.',
            textColor: _ink,
            bg: _lime,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int total, int visites, double progression, Color couleur) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: couleur.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: couleur.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '$visites / $total visités',
                  style: TextStyle(
                    color: couleur,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progression),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Text(
                '${(v * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SegmentedBar(total: total, filled: visites, color: couleur),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SoftButton(
                    label: 'Tout marquer visité',
                    gold: true,
                    onTap: _toutMarquerVisite,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftButton(
                    label: 'Réinitialiser visites',
                    onTap: _toutEffacerVisite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _SoftButton(
                    label: 'Tout ajouter favoris',
                    gold: true,
                    onTap: _toutAjouterFavoris,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftButton(
                    label: 'Tout retirer favoris',
                    onTap: _toutRetirerFavoris,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Pressable(
              onTap: _ouvrirFavoris,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_goldAccent.withOpacity(0.2), _goldAccent.withOpacity(0.06)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _goldAccent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: _goldAccent, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Favoris enregistrés (${_favorisAnversFr.length})',
                      style: const TextStyle(
                        color: _goldLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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

  /// Slivers d'un quartier : en-tête figé qui rétrécit, puis la liste de ses lieux.
  List<Widget> _buildQuartierSlivers(int qi) {
    final q = _kQuartiersAnvers[qi];
    final lieux = (q['lieux'] as List).cast<Map<String, dynamic>>();
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _QuartierHeaderDelegate(index: qi + 1, title: q['quartier'] as String),
      ),
      SliverPadding(
        padding: const EdgeInsets.only(top: 18),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, li) => _Reveal(delay: 60 * li, child: _buildLieuCard(lieux[li])),
            childCount: lieux.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildLieuCard(Map<String, dynamic> lieu) {
    final String id = lieu['id'] as String;
    final String titre = lieu['titre'] as String;
    final List<String> images = List<String>.from(lieu['images'] as List);
    final bool isFavori = _favorisAnversFr.contains(id);
    final bool isVisite = _lieuxVisitesAnvers.contains(id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Carrousel(images: images, onTapImage: (i) => _ouvrirGalerie(images, i)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        titre,
                        softWrap: true,
                        style: _serif(size: 33, weight: FontWeight.w400, height: 1.08, spacing: -0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeartButton(isOn: isFavori, onTap: () => _basculerFavori(id)),
                  ],
                ),
                const SizedBox(height: 16),
                _VisitChip(isVisite: isVisite, onTap: () => _basculerVisite(id)),
                const SizedBox(height: 22),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 3,
                        decoration: BoxDecoration(color: _goldAccent, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          lieu['histoire'] as String,
                          style: const TextStyle(fontSize: 14.5, color: _fgSoft, height: 1.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _TipBox(
                  icon: Icons.lightbulb_outline_rounded,
                  text: lieu['conseil'] as String,
                  textColor: _ink,
                  bg: _sand,
                ),
                const SizedBox(height: 22),
                _GoldButton(
                  label: 'Ouvrir dans Google Maps',
                  icon: Icons.navigation_rounded,
                  onTap: () => _ouvrirMaps(lieu['mapsQuery'] as String),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  PAGE FAVORIS — GAND
// =============================================================================
class FavorisAnversPage extends StatefulWidget {
  final List<Map<String, dynamic>> quartiersAnvers;

  const FavorisAnversPage({super.key, required this.quartiersAnvers});

  @override
  State<FavorisAnversPage> createState() => _FavorisAnversPageState();
}

class _FavorisAnversPageState extends State<FavorisAnversPage> {
  List<String> _favorisAnversFr = [];
  bool _isLoading = true;

  /// Lieux en cours de retrait (animation de sortie avant suppression réelle).
  final Set<String> _sortants = {};

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisAnversFr = List<String>.from(prefs.getStringList('favoris_anvers_fr') ?? []);
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    if (_sortants.contains(id)) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() => _sortants.add(id));
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _favorisAnversFr.remove(id);
      _sortants.remove(id);
    });
    await prefs.setStringList('favoris_anvers_fr', _favorisAnversFr);
  }

  @override
  Widget build(BuildContext context) {
    final int n = _favorisAnversFr.length;

    return Scaffold(
      backgroundColor: _bgObsidian,
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            bottom: false,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _goldAccent))
                : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                const _TopBar(title: 'Favoris de Anvers'),
                _Reveal(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mes favoris',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: n),
                              duration: const Duration(milliseconds: 650),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => Text(
                                '$value',
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w200,
                                  color: _goldAccent,
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'favori${n > 1 ? 's' : ''}\nAnvers',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ..._buildGroupes(),
                if (n == 0) _buildVide(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupes() {
    final List<Widget> widgets = [];
    int index = 0;
    for (int qi = 0; qi < widget.quartiersAnvers.length; qi++) {
      final q = widget.quartiersAnvers[qi];
      final String nomQuartier = q['quartier'] as String;
      final favs = (q['lieux'] as List)
          .cast<Map<String, dynamic>>()
          .where((l) => _favorisAnversFr.contains(l['id']))
          .toList();
      if (favs.isEmpty) continue;

      widgets.add(_QuartierTitleBlock(index: qi + 1, title: nomQuartier));
      for (final lieu in favs) {
        widgets.add(
          _Reveal(
            key: ValueKey('rv_${lieu['id']}'),
            delay: 60 * index,
            child: _favoriTile(lieu),
          ),
        );
        index++;
      }
    }
    return widgets;
  }

  Widget _favoriTile(Map<String, dynamic> lieu) {
    final String id = lieu['id'] as String;
    final List<String> images = List<String>.from(lieu['images'] as List);
    final bool sortant = _sortants.contains(id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInCubic,
        offset: sortant ? const Offset(-0.35, 0) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: sortant ? 0 : 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 108,
                    height: 108,
                    child: images.isNotEmpty ? _img(images.first) : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    lieu['titre'] as String,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Pressable(
                  onTap: () => _retirerFavori(id),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: _rose.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _rose.withOpacity(0.25)),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _rose,
                      size: 22,
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

  Widget _buildVide() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const _Float(
            child: Icon(Icons.favorite_border, color: _goldAccent, size: 56),
          ),
          const SizedBox(height: 18),
          const Text(
            'Aucun favori enregistré pour Anvers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}