import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// =============================================================================
//  DESIGN TOKENS  (identiques à Gand)
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

// Teintes supplémentaires (page Eurostar)
const Color _lilac = Color(0xFFC9B8FF);
const Color _sea = Color(0xFF7AE0C3);
const Color _sky = Color(0xFFA8D8FF);
const Color _blush = Color(0xFFFFB4A2);
const Color _sun = Color(0xFFFFD166);

// Alias (même palette, noms utilisés par la scène du train)
const Color _bg = _bgObsidian;
const Color _fg = _paper;
const Color _card = _surface;

/// Icônes de la barre d'état claires sur fond sombre.
Widget _statusScope(Widget child) => AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle.light,
  child: child,
);

double _c01(double v) => v < 0 ? 0.0 : (v > 1 ? 1.0 : v);

/// Titres éditoriaux (serif).
TextStyle _serif({
  double size = 24,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? spacing,
  FontStyle? style,
  Paint? foreground,
}) => TextStyle(
  fontFamily: 'Georgia',
  fontFamilyFallback: const ['Times New Roman', 'serif'],
  fontSize: size,
  fontWeight: weight,
  color: foreground == null ? (color ?? _paper) : null,
  foreground: foreground,
  height: height,
  letterSpacing: spacing,
  fontStyle: style,
);

/// Contour seul (chiffres géants).
Paint _outline(Color c, {double width = 1.2}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..color = c;

/// Verre dépoli.
class _Glass extends StatelessWidget {
  const _Glass({
    required this.child,
    this.radius = 24,
    this.padding = EdgeInsets.zero,
    this.blur = 20,
    this.tint = 0.08,
    this.color = Colors.white,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: br,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(_c01(tint + 0.05)),
                color.withOpacity(_c01(tint * 0.4)),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

// =============================================================================
//  DONNÉES (source unique pour les trois écrans)
// =============================================================================

final List<Map<String, dynamic>> _kQuartiersBruxelles = [
  {
    'quartier': 'Quartier Européen',
    'lieux': [
      {
        'id': 'parlement',
        'titre': 'Parlement Européen',
        'images': [
          'assets4/belgique/bruxelles/1.jpg',
          'assets4/belgique/bruxelles/2.jpg',
          'assets4/belgique/bruxelles/3.jpg',
        ],
        'histoire':
        'Le Parlement européen est l\'une des institutions majeures de l\'Union européenne. Si Bruxelles a été choisie comme siège principal (aux côtés de Strasbourg et Luxembourg), c\'est en raison de sa position centrale au cœur de l\'Europe, de son bilinguisme historique (français-néerlandais) et de sa tradition diplomatique, évitant ainsi de privilégier des capitales nationales historiques majeures comme Paris ou des localités plus excentrées. C\'est le cœur politique et décisionnel de plus de 450 millions de citoyens européens.',
        'conseil':
        'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
        'mapsQuery': 'Parlement Européen Bruxelles',
      },
      {
        'id': 'cinquantenaire',
        'titre': 'Parc du Cinquantenaire',
        'images': [
          'assets4/belgique/bruxelles/4.jpg',
          'assets4/belgique/bruxelles/5.png',
        ],
        'histoire':
        'Créé sous le règne de Léopold II pour célébrer le cinquantenaire de l\'indépendance de la Belgique lors de l\'exposition nationale de 1880, le parc est dominé par ses majestueuses arcades de triomphe et ses grands musées nationaux (Musée de l\'Armée, Autoworld). Situé à deux pas du Quartier Européen, il constitue un immense espace de verdure chargé d\'histoire architecturale et mémorielle.',
        'conseil':
        'Idéal en automne et printemps pour profiter des magnifiques couleurs. Vérifier la météo avant de partir.',
        'mapsQuery': 'Parc du Cinquantenaire Bruxelles',
      },
      {
        'id': 'leopold',
        'titre': 'Parc Léopold',
        'images': [
          'assets4/belgique/bruxelles/7.jpg',
        ],
        'histoire':
        'Situé juste derrière le Parlement Européen (et tout près du Cinquantenaire), ce parc historique offre un cadre naturel verdoyant et abrite des vestiges insolites, dont un fragment authentique du Mur de Berlin érigé en mémoire des bouleversements géopolitiques européens. Anciennement jardin zoologique de Bruxelles, il témoigne de la transition urbaine de la capitale.',
        'conseil': 'Idéal en journée ensoleillée. Vérifier la météo avant de partir.',
        'mapsQuery': 'Parc Léopold Bruxelles',
      },
    ],
  },
  {
    'quartier': 'Centre Historique',
    'lieux': [
      {
        'id': 'grandplace',
        'titre': 'Grand-Place',
        'images': [
          'assets4/belgique/bruxelles/9.jpg',
          'assets4/belgique/bruxelles/10.jpg',
          'assets4/belgique/bruxelles/11.jpg',
        ],
        'histoire':
        'Cœur battant et historique de Bruxelles, la Grand-Place est mondialement connue pour la richesse de son décor ornemental et architectural, regroupant les opulentes maisons des corporations, l\'Hôtel de Ville gothique et la Maison du Roi. Reconstruite en grande partie après le bombardement destructeur de 1695 par les troupes françaises, elle est classée au patrimoine mondial de l\'UNESCO.',
        'conseil':
        'À voir absolument de jour comme de nuit. Vérifier la météo avant de partir.',
        'mapsQuery': 'Grand-Place Bruxelles',
      },
      {
        'id': 'mannekenpis',
        'titre': 'Manneken-Pis et Jeanneke-Pis',
        'images': [
          'assets4/belgique/bruxelles/199.jpg',
          'assets4/belgique/bruxelles/14.jpg',
        ],
        'histoire':
        'Situés à proximité immédiate de la Grand-Place, Manneken-Pis est une petite fontaine en bronze représentant un petit garçon urinant, symbole de l\'esprit indépendant, frondeur et humoristique des Bruxellois (plusieurs fois habillé de costumes traditionnels). Jeanneke-Pis, son pendant féminin situé dans une allée voisine (l\'impasse de la Fidélité), a été créée plus tard en 1987 pour promouvoir le folklore local et soutenir des œuvres caritatives.',
        'conseil':
        'Prévoir un passage rapide dans les ruelles piétonnes. Vérifier la météo avant de partir.',
        'mapsQuery': 'Manneken-Pis Bruxelles',
      },
      {
        'id': 'galeries',
        'titre': 'Galeries Royales Saint-Hubert',
        'images': [
          'assets4/belgique/bruxelles/15.jpg',
        ],
        'histoire':
        'Inaugurées en 1847 à deux pas de la Grand-Place, ces superbes galeries commerçantes couvertes (divisées en Galerie de la Reine, du Roi et des Princes) comptent parmi les plus anciennes et les plus élégantes d\'Europe. Conçues par l\'architecte Jean-Pierre Cluysenaar, elles sont célèbres pour leurs vitrines de luxe, leurs chocolateries artisanales historiques, leurs théâtres et leur verrière lumineuse.',
        'conseil':
        'Goûter les chocolats artisanaux sur place. Vérifier la météo avant de partir.',
        'mapsQuery': 'Galeries Royales Saint-Hubert Bruxelles',
      },
      {
        'id': 'montdesarts',
        'titre': 'Mont des Arts',
        'images': [
          'assets4/belgique/bruxelles/16.jpg',
          'assets4/belgique/bruxelles/17.webp',
        ],
        'histoire':
        'Aménagé à l\'origine pour l\'Exposition internationale de 1910 puis entièrement redessiné dans les années 1950 lors des grands travaux urbanistiques de la ville, le Mont des Arts relie la Ville Haute (quartier des musées et palais royal) et la Ville Basse (centre historique). Il offre un jardin géométrique en pente et l\'un des panoramas les plus spectaculaires sur les toits de Bruxelles et l\'Hôtel de Ville.',
        'conseil': 'Magnifique vue au coucher du soleil. Vérifier la météo avant de partir.',
        'mapsQuery': 'Mont des Arts Bruxelles',
      },
      {
        'id': 'palaisjustice',
        'titre': 'Palais de Justice',
        'images': [
          'assets4/belgique/bruxelles/18.jpg',
          'assets4/belgique/bruxelles/19.webp',
          'assets4/belgique/bruxelles/20.webp',
          'assets4/belgique/bruxelles/21.jpg',
        ],
        'histoire':
        'Construit entre 1866 et 1883 par l\'architecte Joseph Poelaert, ce bâtiment colossal domine le quartier des Marolles et offre une vue imprenable sur la ville. C\'est l\'un des plus grands édifices de justice construits au XIXe siècle en Europe, surpassant par sa superficie de base certaines basiliques. Son architecture monumentale mélange des inspirations gréco-romaines et assyriennes.',
        'conseil': 'Admirer la démesure de l\'architecture. Vérifier la météo avant de partir.',
        'mapsQuery': 'Palais de Justice de Bruxelles',
      },
    ],
  },
  {
    'quartier': 'Heyzel / Nord',
    'lieux': [
      {
        'id': 'atomium',
        'titre': 'Atomium',
        'images': [
          'assets4/belgique/bruxelles/22.jpg',
          'assets4/belgique/bruxelles/23.jpg',
          'assets4/belgique/bruxelles/24.jpg',
        ],
        'histoire':
        'Conçu pour l\'Exposition universelle de Bruxelles de 1958 (l\'Expo 58) par l\'architecte André Waterkeyn et les ingénieurs Pol et Jean Cornellie, l\'Atomium représente la maille élémentaire d\'un cristal de fer agrandie 165 milliards de fois. Véritable Tour Eiffel version belge, il symbolise la foi audacieuse dans le progrès scientifique, la modernité et l\'ère atomique d\'après-guerre. Depuis son sommet ou à ses pieds, on peut également écouter et observer le ballet impressionnant des avions qui décollent et atterrissent, l\'aéroport de Zaventem se trouvant juste à côté.',
        'conseil':
        'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
        'mapsQuery': 'Atomium Bruxelles',
      },
      {
        'id': 'minieurope',
        'titre': 'Mini-Europe',
        'images': [
          'assets4/belgique/bruxelles/25.webp',
          'assets4/belgique/bruxelles/26.jpg',
        ],
        'histoire':
        'Inauguré en 1989 juste au pied de l\'Atomium (les deux sites se visitent donc idéalement ensemble), le parc Mini-Europe permet de parcourir l\'Union européenne en quelques pas à travers près de 350 monuments phares européens reproduits à l\'échelle 1/25e avec un souci impressionnant du détail, des animations et des effets sonores.',
        'conseil':
        'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
        'mapsQuery': 'Mini-Europe Bruxelles',
      },
    ],
  },
  {
    'quartier': 'Laeken (Nord-Ouest)',
    'lieux': [
      {
        'id': 'laeken',
        'titre': 'Serres Royales de Laeken',
        'images': [
          'assets4/belgique/bruxelles/27.webp',
          'assets4/belgique/bruxelles/28.jpg',
          'assets4/belgique/bruxelles/29.webp',
        ],
        'histoire':
        'Quartier résidentiel royal abritant le Château de Laeken (résidence de la famille royale belge) et ses célèbres serres monumentales en fer et verre. Conçues par l\'architecte Alphonse Balat pour le roi Léopold II à la fin du XIXe siècle, elles constituent un chef-d\'œuvre de l\'architecture métallique et abritent des collections botaniques rares, ouvertes au public seulement quelques semaines par an au printemps.',
        'conseil': 'Ouverture exceptionnelle au printemps. Vérifier la météo avant de partir.',
        'mapsQuery': 'Château de Laeken Bruxelles',
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
  const _Reveal({
    super.key,
    required this.child,
    this.delay = 0,
    this.from = const Offset(0, 0.08),
  });

  final Widget child;
  final int delay;
  final Offset from;

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
        position: Tween<Offset>(begin: widget.from, end: Offset.zero).animate(curved),
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
  _QuartierHeaderDelegate({required this.index, required this.title, required this.topPad});

  final int index;
  final String title;
  final double topPad;

  static const double _maxBase = 112;
  static const double _minBase = 68;

  double get _maxExtent => _maxBase + topPad;
  double get _minExtent => _minBase + topPad;

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
          padding: EdgeInsets.fromLTRB(lerpDouble(20, 76, t)!, 0, 20, 14),
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
      oldDelegate.title != title || oldDelegate.index != index || oldDelegate.topPad != topPad;
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



/// Lignes de vitesse animées (fond de la carte Eurostar).
class _SpeedLines extends StatefulWidget {
  const _SpeedLines();

  @override
  State<_SpeedLines> createState() => _SpeedLinesState();
}

class _SpeedLinesState extends State<_SpeedLines> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

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
        builder: (context, _) => CustomPaint(painter: _SpeedLinesPainter(_c.value)),
      ),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  _SpeedLinesPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 7; i++) {
      final double p = (t * (1 + i % 3) + i * 0.23) % 1.0;
      final double y = size.height * (0.12 + 0.125 * i);
      final double len = 50.0 + i * 14;
      final double x = size.width * 1.15 - p * size.width * 1.5;
      final double alpha = math.sin(p * math.pi) * 0.28;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + len, y),
        Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedLinesPainter old) => old.t != t;
}



// =============================================================================
//  PAGE PRINCIPALE — BRUXELLES
// =============================================================================
class Bruxelles extends StatefulWidget {
  const Bruxelles({super.key});

  @override
  State<Bruxelles> createState() => _BruxellesState();
}

class _BruxellesState extends State<Bruxelles> {
  List<String> _favorisFr = [];
  List<String> _lieuxVisites = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chargerDonneesVoyage();
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
      precacheImage(const AssetImage('assets4/belgique/bruxelles/30.jpg'), context);
      for (final lieu in _lieuxDe(_kQuartiersBruxelles)) {
        for (final String imgPath in List<String>.from(lieu['images'] as List)) {
          precacheImage(AssetImage(imgPath), context);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  //  Données & persistance (logique inchangée)
  // ---------------------------------------------------------------------------
  Future<void> _chargerDonneesVoyage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisFr = List<String>.from(prefs.getStringList('favoris_bruxelles_fr') ?? []);
      _lieuxVisites = List<String>.from(prefs.getStringList('lieux_visites_bruxelles_fr') ?? []);
    });
  }

  Future<void> _basculerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorisFr.contains(id)) {
        _favorisFr.remove(id);
      } else {
        _favorisFr.add(id);
      }
    });
    await prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
  }

  Future<void> _toutAjouterFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisFr = _lieuxDe(_kQuartiersBruxelles).map((l) => l['id'] as String).toList();
    });
    await prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _favorisFr.clear());
    await prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
  }

  Future<void> _basculerVisite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_lieuxVisites.contains(id)) {
        _lieuxVisites.remove(id);
      } else {
        _lieuxVisites.add(id);
      }
    });
    await prefs.setStringList('lieux_visites_bruxelles_fr', _lieuxVisites);
  }

  Future<void> _toutMarquerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisites = _lieuxDe(_kQuartiersBruxelles).map((l) => l['id'] as String).toList();
    });
    await prefs.setStringList('lieux_visites_bruxelles_fr', _lieuxVisites);
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lieuxVisites.clear());
    await prefs.setStringList('lieux_visites_bruxelles_fr', _lieuxVisites);
  }

  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _ouvrirAnecdotes() {
    Navigator.of(context).push(_route(const EurostarAnecdotesPage()));
  }

  void _ouvrirGalerie(List<String> images, int index) {
    Navigator.of(context).push(
      _route(_GalerieEcran(images: images, initialIndex: index), slide: false),
    );
  }

  Future<void> _ouvrirFavoris() async {
    await Navigator.of(context).push(
      _route(const FavorisBruxellesPage()),
    );
    _chargerDonneesVoyage();
  }

  // ---------------------------------------------------------------------------
  //  Construction de l'interface
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final int totalLieux = _lieuxDe(_kQuartiersBruxelles).length;
    final int nbVisites = _lieuxVisites.length;
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
                  items: _lieuxDe(_kQuartiersBruxelles).map((l) => l['titre'] as String).toList(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _Reveal(delay: 100, child: _buildIntro())),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: _Reveal(
                  delay: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildEurostarCard(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: _Reveal(
                  delay: 180,
                  child: _buildProgressCard(totalLieux, nbVisites, progression, couleurProgression),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(child: _Reveal(delay: 240, child: _buildListesCard())),
              for (int qi = 0; qi < _kQuartiersBruxelles.length; qi++) ..._buildQuartierSlivers(qi),
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
    const String heroImage = 'assets4/belgique/bruxelles/30.jpg';
    final int totalLieux = _lieuxDe(_kQuartiersBruxelles).length;
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
                        'Bruxelles · Guide de voyage',
                        style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Text('L\'Élégance', style: _serif(size: 62, weight: FontWeight.w300, height: 1.0, spacing: -1.8, color: Colors.white)),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) => const LinearGradient(colors: [_lime, _sand, Color(0xFFFFB4A2)]).createShader(b),
                        child: Text(
                          'de la Capitale',
                          style: _serif(size: 46, weight: FontWeight.w300, height: 1.1, spacing: -0.8, style: FontStyle.italic, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _HeroInfoPill(label: '${_kQuartiersBruxelles.length} quartiers'),
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
            'Capitale souveraine de la Belgique et cœur névralgique et institutionnel de l\'Union européenne, Bruxelles fusionne un patrimoine architectural d\'exception, un avant-gardisme culturel et un art de vivre d\'une élégance rare.',
            style: _serif(size: 21, weight: FontWeight.w400, color: _paper, height: 1.55, spacing: -0.2),
          ),
          const SizedBox(height: 22),
          _TipBox(
            icon: Icons.info_outline_rounded,
            text: 'Conseils : Visiter Bruxelles en semaine, hors vacances scolaires et éviter les week-ends. Pensez à vérifier la météo avant de partir.',
            textColor: _ink,
            bg: _lime,
          ),
        ],
      ),
    );
  }

  Widget _buildEurostarCard() {
    return _Pressable(
      onTap: _ouvrirAnecdotes,
      child: SizedBox(
        height: 190,
        child: ClipPath(
          clipper: const _TicketClipper(notchY: 0.68),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8E0F18), Color(0xFFD7191F), Color(0xFFFF4D43)],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: _SpeedLines()),
                Positioned(
                  left: 22,
                  right: 22,
                  top: 0,
                  bottom: 190 * 0.32 - 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const _Glass(
                            radius: 18,
                            blur: 12,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.train_rounded, color: Colors.white, size: 25),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'EUROSTAR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_outward_rounded, color: Color(0xFFD7191F), size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Anecdotes sur l\'Eurostar',
                        softWrap: true,
                        style: _serif(size: 24, weight: FontWeight.w500, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cliquez pour lire les anecdotes',
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  top: 190 * 0.68 - 1,
                  height: 1.5,
                  child: const CustomPaint(painter: _DashPainter(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
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
                      'Favoris enregistrés (${_favorisFr.length})',
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
    final q = _kQuartiersBruxelles[qi];
    final lieux = (q['lieux'] as List).cast<Map<String, dynamic>>();
    final double topPad = MediaQuery.of(context).padding.top;
    return [
      SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _QuartierHeaderDelegate(
              index: qi + 1,
              title: q['quartier'] as String,
              topPad: topPad,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 18),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, li) => _Reveal(child: _buildLieuCard(lieux[li])),
                childCount: lieux.length,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildLieuCard(Map<String, dynamic> lieu) {
    final String id = lieu['id'] as String;
    final String titre = lieu['titre'] as String;
    final List<String> images = List<String>.from(lieu['images'] as List);
    final bool isFavori = _favorisFr.contains(id);
    final bool isVisite = _lieuxVisites.contains(id);

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
//  PAGE ANECDOTES — EUROSTAR
// =============================================================================
class _Anecdote {
  const _Anecdote(this.titre, this.texte);

  final String titre;
  final String texte;
}

const List<_Anecdote> _kAnecdotes = [
  _Anecdote(
    'En semaines',
    'En semaine, l\'Eurostar endosse son surnom emblématique de « train d\'affaires ». Qu\'il s\'agisse des voitures de première classe ou des rangées de seconde classe, le tumulte matinal et crépusculaire révèle une population de navetteurs assidus. Les ordinateurs portables s\'ouvrent dès le départ, transformant l\'espace en un véritable bureau itinérant. Les discussions stratégiques et les réunions improvisées s\'étirent jusque dans la voiture bar, devenue le point névralgique des échanges informels et du réseautage professionnel. Au milieu de cette effervescence corporative, la présence de rares touristes égarés crée un contraste visuel et atmosphérique particulièrement saisissant.',
  ),
  _Anecdote(
    'En semaine de la journée',
    'Au cœur de la journée en semaine, après l\'effervescence des départs matinaux, l\'atmosphère à bord subit une métamorphose radicale. Le rythme du train s\'harmonise avec le panorama rural qui défile de part et d\'autre des fenêtres. Un calme feutré s\'installe durablement dans les wagons, offrant aux rares passagers un sanctuaire de sérénité idéal pour la concentration, la relecture de dossiers complexes ou une parenthèse de repos studieux.',
  ),
  _Anecdote(
    'Week-end',
    'Dès le vendredi soir et tout au long du week-end, la physionomie de l\'Eurostar change du tout au tout. Les costumes stricts et les mallettes professionnelles cèdent définitivement la place aux tenues décontractées et aux sacs de voyage légers. L\'ambiance se pare d\'une légèreté festive, les wagons résonnant des éclats de voix de couples en escapade romantique, de cercles d\'amis et de voyageurs impatients de s\'immiscer dans l\'effervescence culturelle et gastronomique bruxelloise.',
  ),
  _Anecdote(
    'Vacances scolaires',
    'Pendant les périodes de vacances scolaires, l\'Eurostar se mue en un espace éminemment vivant et familial. Les espaces de rangement se gorgent de valises volumineuses et de poussettes, tandis que les wagons s\'animent au rythme des rires d\'enfants et des discussions enthousiastes. L\'atmosphère générale respire l\'exaltation des grands départs, contrastant fortement avec la rigueur des flux d\'affaires habituels.',
  ),
  _Anecdote(
    'Vacances scolaires + week-end',
    'Lorsque les vacances scolaires coïncident avec l\'affluence d\'un week-end, le taux d\'occupation de la rame atteint son paroxysme. C\'est la configuration des grands mouvements migratoires touristiques : les familles, les tribus d\'amis et les vacanciers se croisent en nombre dans les couloirs, insufflant une dynamique d\'animation permanente et une effervescence collective caractéristique des grands moments d\'évasion.',
  ),
  _Anecdote(
    'Vacances scolaires + travail (en semaines)',
    'Cette configuration singulière illustre le quotidien hybride du voyageur moderne et connecté. En semaine, au cœur d\'une période de vacances scolaires, il n\'est pas rare d\'observer des parents jonglant habilement entre l\'accompagnement de leur famille en voyage et la gestion de dossiers professionnels urgents sur leur tablette, incarnant la juxtaposition parfaite entre impératifs de carrière et moments de partage personnel.',
  ),
];

class EurostarAnecdotesPage extends StatelessWidget {
  const EurostarAnecdotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _statusScope(Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 60),
              children: [
                const SizedBox(height: 66),
                const _Reveal(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: _TrainScene(),
                  ),
                ),
                const SizedBox(height: 34),
                _Reveal(
                  delay: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _lime,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Text(
                            'ANECDOTES SUR L\'EUROSTAR',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Immersion à bord de l\'Eurostar',
                          style: _serif(size: 42, weight: FontWeight.w400, height: 1.05, spacing: -1.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_kAnecdotes.length} situations de voyage',
                          style: TextStyle(color: _fgSoft, fontSize: 13.5, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                for (int i = 0; i < _kAnecdotes.length; i++)
                  _Reveal(
                    from: Offset(i.isEven ? -0.10 : 0.10, 0.04),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      child: _TimelineItem(
                        anecdote: _kAnecdotes[i],
                        index: i,
                        last: i == _kAnecdotes.length - 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: _GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ));
  }
}

/// Scène animée : train rouge, cycle lever / coucher du soleil, parallaxe.
class _TrainScene extends StatefulWidget {
  const _TrainScene();

  @override
  State<_TrainScene> createState() => _TrainSceneState();
}

class _TrainSceneState extends State<_TrainScene> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _phase(double t) {
    if (t < 0.08) return 'Lever du soleil';
    if (t < 0.45) return 'Plein jour';
    if (t < 0.58) return 'Coucher du soleil';
    if (t < 0.68) return 'Crépuscule';
    if (t < 0.88) return 'Nuit';
    return 'Aube';
  }

  IconData _phaseIcon(double t) {
    if (t < 0.08) return Icons.wb_twilight_rounded;
    if (t < 0.45) return Icons.wb_sunny_rounded;
    if (t < 0.58) return Icons.wb_twilight_rounded;
    if (t < 0.88) return Icons.nightlight_round;
    return Icons.wb_twilight_rounded;
  }

  String _clock(double t) {
    final double hours = (6 + t * 24) % 24;
    final int h = hours.floor();
    final int m = ((hours - h) * 60).floor();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD7191F).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final double t = _c.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(size: Size.infinite, painter: _TrainPainter(t)),
                Positioned(
                  top: 16,
                  left: 16,
                  child: _Glass(
                    radius: 20,
                    blur: 14,
                    tint: 0.16,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_phaseIcon(t), color: Colors.white, size: 15),
                        const SizedBox(width: 7),
                        Text(
                          _phase(t),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _clock(t),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrainPainter extends CustomPainter {
  _TrainPainter(this.t);

  final double t;

  // Ciel selon l'heure : (phase, haut, milieu, horizon)
  static const List<List<dynamic>> _sky = [
    [0.00, Color(0xFF2B2A5E), Color(0xFFB9568A), Color(0xFFFFA45C)], // lever
    [0.10, Color(0xFF3F74C8), Color(0xFF8EB8E8), Color(0xFFFFD9A8)], // matin
    [0.25, Color(0xFF2E7BD6), Color(0xFF6FB6F0), Color(0xFFBFE3FA)], // midi
    [0.40, Color(0xFF3A6FC0), Color(0xFF9DB4DC), Color(0xFFFFCB94)], // après-midi
    [0.50, Color(0xFF3A2466), Color(0xFFD0476B), Color(0xFFFF8A3C)], // coucher
    [0.60, Color(0xFF14123A), Color(0xFF2A1B52), Color(0xFF7A3A6A)], // crépuscule
    [0.75, Color(0xFF050716), Color(0xFF0C1030), Color(0xFF1A1F4A)], // nuit
    [0.90, Color(0xFF0E1033), Color(0xFF2A2557), Color(0xFF6B4A7A)], // aube
    [1.00, Color(0xFF2B2A5E), Color(0xFFB9568A), Color(0xFFFFA45C)], // lever
  ];

  Color _skyAt(double p, int slot) {
    for (int i = 0; i < _sky.length - 1; i++) {
      final double a = _sky[i][0] as double;
      final double b = _sky[i + 1][0] as double;
      if (p >= a && p <= b) {
        final double k = (p - a) / (b - a);
        return Color.lerp(_sky[i][slot] as Color, _sky[i + 1][slot] as Color, k)!;
      }
    }
    return _sky.first[slot] as Color;
  }

  void _skyline(
      Canvas canvas,
      Size size, {
        required int n,
        required int speed,
        required double baseY,
        required double maxH,
        required Color color,
        required int seed,
      }) {
    final double period = size.width;
    final double bw = period / n;
    final double off = (t * speed * period) % period;
    final Paint pt = Paint()..color = color;
    for (int copy = 0; copy < 2; copy++) {
      final double dx = -off + copy * period;
      for (int i = 0; i < n; i++) {
        final double bh = maxH * (0.35 + 0.65 * (((i * seed) % 7) / 6));
        canvas.drawRect(Rect.fromLTWH(dx + i * bw, baseY - bh, bw + 1, bh + 2), pt);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double a = t * 2 * math.pi;
    final Rect all = Offset.zero & size;
    final double ground = h * 0.80;

    final double dayF = 0.5 + 0.5 * math.cos((t - 0.25) * 2 * math.pi); // 1 = midi
    final double nightF = _c01(1 - (t - 0.75).abs() / 0.2); // 1 = pleine nuit

    // Ciel
    canvas.drawRect(
      all,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyAt(t, 1), _skyAt(t, 2), _skyAt(t, 3)],
          stops: const [0.0, 0.6, 0.9],
        ).createShader(all),
    );

    // Étoiles (nuit)
    if (nightF > 0) {
      for (int i = 0; i < 30; i++) {
        final double x = ((i * 53) % 100) / 100 * w;
        final double y = ((i * 37) % 55) / 100 * h;
        final double r = 0.7 + (i % 3) * 0.4;
        final double tw = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(a * 10 + i));
        canvas.drawCircle(
            Offset(x, y), r, Paint()..color = Colors.white.withOpacity(0.8 * tw * nightF));
      }
    }

    // Soleil (0 → 0.5) puis lune (0.5 → 1) : arc de l'horizon gauche à l'horizon droit
    final bool isSun = t < 0.5;
    final double u = isSun ? t / 0.5 : (t - 0.5) / 0.5;
    final double arc = math.sin(u * math.pi);
    final Offset body = Offset(w * (0.08 + 0.84 * u), ground - arc * h * 0.62);
    if (isSun) {
      final Color sunCol = Color.lerp(const Color(0xFFFF6A3D), const Color(0xFFFFF1B8), arc)!;
      canvas.drawCircle(
        body,
        h * (0.5 - 0.1 * arc),
        Paint()
          ..shader = RadialGradient(colors: [sunCol.withOpacity(0.6), sunCol.withOpacity(0)])
              .createShader(Rect.fromCircle(center: body, radius: h * 0.5)),
      );
      canvas.drawCircle(body, 28 + 4 * (1 - arc), Paint()..color = sunCol);
    } else {
      canvas.drawCircle(
        body,
        h * 0.32,
        Paint()
          ..shader = RadialGradient(
            colors: [const Color(0xFFCFE0FF).withOpacity(0.28), const Color(0xFFCFE0FF).withOpacity(0)],
          ).createShader(Rect.fromCircle(center: body, radius: h * 0.32)),
      );
      canvas.drawCircle(body, 20, Paint()..color = const Color(0xFFEAF1FF));
      canvas.drawCircle(body.translate(7, -4), 18, Paint()..color = _skyAt(t, 1).withOpacity(0.9));
    }

    // Nuages (jour)
    if (dayF > 0.15) {
      for (int i = 0; i < 3; i++) {
        final double cx = ((i * 0.37 + t * 3) % 1.3 - 0.15) * w;
        final double cy = h * (0.16 + 0.12 * i);
        final Paint cp = Paint()..color = Colors.white.withOpacity(0.5 * dayF);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 90, height: 22), cp);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 22, cy - 9), width: 56, height: 22), cp);
      }
    }

    // Villes en parallaxe
    _skyline(canvas, size,
        n: 14,
        speed: 4,
        baseY: ground,
        maxH: h * 0.34,
        color: Color.lerp(const Color(0xFF1E1838), const Color(0xFF5C7FA8), dayF)!,
        seed: 5);
    _skyline(canvas, size,
        n: 9,
        speed: 10,
        baseY: ground,
        maxH: h * 0.24,
        color: Color.lerp(const Color(0xFF120E26), const Color(0xFF3A5578), dayF)!,
        seed: 3);

    // Sol + rails
    canvas.drawRect(
      Rect.fromLTWH(0, ground, w, h - ground),
      Paint()..color = Color.lerp(const Color(0xFF0D0B1E), const Color(0xFF2B3342), dayF)!,
    );
    final double railY = h * 0.885;
    canvas.drawLine(
      Offset(0, railY),
      Offset(w, railY),
      Paint()
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.35),
    );
    final double spacing = w / (w / 28).round();
    final double sOff = (t * w * 40) % spacing;
    for (double x = -spacing + sOff; x < w + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, railY + 4),
        Offset(x - 8, h),
        Paint()
          ..strokeWidth = 3
          ..color = Colors.white.withOpacity(0.08),
      );
    }

    // Train rouge
    final double bob = 1.2 * math.sin(a * 120);
    final double x0 = w * 0.08;
    final double x1 = w * 0.90;
    final double yB = ground + 4 + bob;
    final double yT = yB - 56;

    for (int i = 0; i < 7; i++) {
      final double p = (t * 14 + i * 0.17) % 1.0;
      final double ly = yT + 6 + i * 7.0;
      final double sx = x0 - 6 - p * w * 0.55;
      canvas.drawLine(
        Offset(sx, ly),
        Offset(sx - 34 - i * 6, ly),
        Paint()
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity((1 - p) * 0.45),
      );
    }

    canvas.drawOval(
      Rect.fromLTWH(x0, yB + 2, x1 - x0, 10),
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final Path shell = Path()
      ..moveTo(x0 + 10, yT)
      ..lineTo(x1 - 80, yT)
      ..cubicTo(x1 - 28, yT, x1 - 2, yT + 26, x1, yB)
      ..lineTo(x0, yB)
      ..lineTo(x0, yT + 10)
      ..quadraticBezierTo(x0, yT, x0 + 10, yT)
      ..close();

    canvas.drawPath(
      shell,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0414A), Color(0xFFB3121F), Color(0xFF8A0D18)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTRB(x0, yT, x1, yB)),
    );

    canvas.save();
    canvas.clipPath(shell);
    canvas.drawRect(
      Rect.fromLTRB(x0, yT, x1, yT + 6),
      Paint()..color = Colors.white.withOpacity(0.22),
    );
    canvas.drawRect(
      Rect.fromLTRB(x0, yT + 36, x1, yT + 38),
      Paint()..color = const Color(0xFFFFE3DC).withOpacity(0.85),
    );
    canvas.drawRect(
      Rect.fromLTRB(x0, yT + 44, x1, yB),
      Paint()..color = const Color(0xFF3A0A12),
    );
    // lueur du soleil / de la lune qui glisse sur le toit
    canvas.drawRect(
      Rect.fromLTRB(x0, yT, x1, yT + 14),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            (isSun ? const Color(0xFFFFD08A) : const Color(0xFFCFE0FF)).withOpacity(0.22 * arc),
            Colors.transparent,
          ],
          stops: [
            _c01(body.dx / w - 0.25),
            _c01(body.dx / w),
            _c01(body.dx / w + 0.25),
          ],
        ).createShader(Rect.fromLTRB(x0, yT, x1, yT + 14)),
    );
    canvas.restore();

    // fenêtres (s'éclairent la nuit)
    final Color winCol = Color.lerp(const Color(0xFF1A1020), const Color(0xFFFFD58A), nightF)!;
    for (double x = x0 + 22; x < x1 - 100; x += 34) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, yT + 10, 22, 14), const Radius.circular(4)),
        Paint()..color = winCol,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + 2, yT + 12, 8, 4), const Radius.circular(2)),
        Paint()..color = Colors.white.withOpacity(0.3),
      );
    }

    final Path glass = Path()
      ..moveTo(x1 - 76, yT + 8)
      ..lineTo(x1 - 44, yT + 8)
      ..quadraticBezierTo(x1 - 14, yT + 14, x1 - 8, yT + 32)
      ..lineTo(x1 - 76, yT + 32)
      ..close();
    canvas.drawPath(glass, Paint()..color = const Color(0xFF1A1020));

    final Offset lamp = Offset(x1 - 5, yT + 44);
    canvas.drawCircle(
      lamp,
      9 + 5 * nightF,
      Paint()
        ..color = _sun.withOpacity(0.55 + 0.4 * nightF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(lamp, 3, Paint()..color = Colors.white);

    for (final double fx in [0.16, 0.34, 0.52, 0.70, 0.84]) {
      final double bx = x0 + (x1 - x0) * fx;
      canvas.drawCircle(Offset(bx, yB + 3), 6, Paint()..color = const Color(0xFF0D0B1E));
      canvas.drawCircle(Offset(bx, yB + 3), 2.4, Paint()..color = Colors.white.withOpacity(0.5));
    }
  }

  @override
  bool shouldRepaint(covariant _TrainPainter old) => old.t != t;
}

/// Élément de frise : ligne verticale + nœud coloré + billet.
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.anecdote, required this.index, required this.last});

  final _Anecdote anecdote;
  final int index;
  final bool last;

  static const List<Color> _colors = [_lilac, _sand, _lime, _blush, _sea, _sky];

  @override
  Widget build(BuildContext context) {
    final Color accent = _colors[index % _colors.length];
    return Stack(
      children: [
        Positioned(
          left: 19,
          top: 0,
          bottom: last ? 80 : -18,
          width: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_fg.withOpacity(0.5), _fg.withOpacity(0.12)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 26,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(color: _fg, width: 2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: _TicketCard(anecdote: anecdote, index: index),
        ),
      ],
    );
  }
}

/// Billet de train : partie haute (numéro, titre) + perforation + texte.
class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.anecdote, required this.index});

  final _Anecdote anecdote;
  final int index;

  static const List<IconData> _icons = [
    Icons.work_outline_rounded,
    Icons.wb_sunny_outlined,
    Icons.weekend_outlined,
    Icons.family_restroom_rounded,
    Icons.luggage_rounded,
    Icons.laptop_mac_rounded,
  ];
  static const List<Color> _colors = [_lilac, _sand, _lime, _blush, _sea, _sky];

  @override
  Widget build(BuildContext context) {
    final Color accent = _colors[index % _colors.length];
    final IconData icon = _icons[index % _icons.length];

    return Column(
      children: [
        ClipPath(
          clipper: const _NotchClipper(top: false),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: _serif(
                        size: 48,
                        weight: FontWeight.w700,
                        height: 1.0,
                        foreground: _outline(_ink, width: 1.2),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: _ink, shape: BoxShape.circle),
                      child: Icon(icon, color: accent, size: 21),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  anecdote.titre,
                  style: _serif(size: 24, weight: FontWeight.w500, color: _ink, height: 1.15, spacing: -0.3),
                ),
              ],
            ),
          ),
        ),
        ClipPath(
          clipper: const _NotchClipper(top: true),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                  child: Text(
                    anecdote.texte,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: _fgSoft,
                      height: 1.8,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  height: 1.5,
                  child: CustomPaint(painter: _DashPainter(color: _fg)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Découpe en demi-cercles sur les bords gauche et droit (perforation du billet).
class _NotchClipper extends CustomClipper<Path> {
  const _NotchClipper({required this.top});

  final bool top;

  @override
  Path getClip(Size size) {
    final double y = top ? 0.0 : size.height;
    final Path card = Path()..addRect(Offset.zero & size);
    final Path holes = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: 13))
      ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: 13));
    return Path.combine(PathOperation.difference, card, holes);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Billet arrondi avec encoches latérales à une hauteur donnée (carte Eurostar).
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({required this.notchY});

  final double notchY;

  @override
  Path getClip(Size size) {
    final Path card = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(36)));
    final double y = size.height * notchY;
    final Path holes = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: 14))
      ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: 14));
    return Path.combine(PathOperation.difference, card, holes);
  }

  @override
  bool shouldReclip(covariant _TicketClipper old) => old.notchY != notchY;
}

class _DashPainter extends CustomPainter {
  const _DashPainter({this.color = _ink});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..strokeWidth = 1.5
      ..color = color.withOpacity(0.28);
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + 7, size.width), 0), p);
      x += 13;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}



// =============================================================================
//  PAGE FAVORIS — BRUXELLES
// =============================================================================
class FavorisBruxellesPage extends StatefulWidget {
  const FavorisBruxellesPage({super.key});

  @override
  State<FavorisBruxellesPage> createState() => _FavorisBruxellesPageState();
}

class _FavorisBruxellesPageState extends State<FavorisBruxellesPage> {
  List<String> _favorisFr = [];
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
      _favorisFr = List<String>.from(prefs.getStringList('favoris_bruxelles_fr') ?? []);
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
      _favorisFr.remove(id);
      _sortants.remove(id);
    });
    await prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
  }

  @override
  Widget build(BuildContext context) {
    final int n = _favorisFr.length;

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
                const _TopBar(title: 'Favoris de Bruxelles'),
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
                                'favori${n > 1 ? 's' : ''}\nBruxelles',
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
    for (int qi = 0; qi < _kQuartiersBruxelles.length; qi++) {
      final q = _kQuartiersBruxelles[qi];
      final String nomQuartier = q['quartier'] as String;
      final favs = (q['lieux'] as List)
          .cast<Map<String, dynamic>>()
          .where((l) => _favorisFr.contains(l['id']))
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
            'Aucun favori enregistré pour Bruxelles.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}