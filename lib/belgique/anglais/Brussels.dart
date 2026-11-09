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
//  DATA (single source for both screens)
// =============================================================================
final List<Map<String, dynamic>> _brusselsNeighborhoods = [
  {
    'neighborhood': 'European Quarter',
    'places': [
      {
        'id': 'parlement',
        'title': 'European Parliament',
        'images': [
          'assets4/belgique/bruxelles/1.jpg',
          'assets4/belgique/bruxelles/2.jpg',
          'assets4/belgique/bruxelles/3.jpg',
        ],
        'history':
        'The European Parliament is one of the major institutions of the European Union. If Brussels was chosen as its principal seat (alongside Strasbourg and Luxembourg), it is due to its central position in the heart of Europe, its historical bilingualism (French-Dutch), and its diplomatic tradition, thus avoiding favoring major historical national capitals like Paris or more out-of-the-way locations. It is the political and decision-making heart for over 450 million European citizens.',
        'tip': 'Visit on weekdays, outside school holidays and avoid weekends. Check the weather before leaving.',
        'mapsQuery': 'European Parliament Brussels',
      },
      {
        'id': 'cinquantenaire',
        'title': 'Cinquantenaire Park',
        'images': [
          'assets4/belgique/bruxelles/4.jpg',
          'assets4/belgique/bruxelles/5.png',
        ],
        'history':
        'Created under the reign of Leopold II to celebrate the fiftieth anniversary of Belgium\'s independence during the national exhibition of 1880, the park is dominated by its majestic triumphal arches and major national museums (Army Museum, Autoworld). Located a stone\'s throw from the European Quarter, it constitutes an immense green space steeped in architectural and memorial history.',
        'tip': 'Ideal in autumn and spring to enjoy the magnificent colors. Check the weather before leaving.',
        'mapsQuery': 'Cinquantenaire Park Brussels',
      },
      {
        'id': 'leopold',
        'title': 'Leopold Park',
        'images': [
          'assets4/belgique/bruxelles/7.jpg',
        ],
        'history':
        'Located right behind the European Parliament (and very close to the Cinquantenaire), this historic park offers a lush green natural setting and houses unusual remains, including an authentic fragment of the Berlin Wall erected in memory of European geopolitical upheavals. Formerly Brussels\' zoological garden, it testifies to the capital\'s urban transition.',
        'tip': 'Ideal on a sunny day. Check the weather before leaving.',
        'mapsQuery': 'Leopold Park Brussels',
      },
    ],
  },
  {
    'neighborhood': 'Historic Center',
    'places': [
      {
        'id': 'grandplace',
        'title': 'Grand-Place',
        'images': [
          'assets4/belgique/bruxelles/9.jpg',
          'assets4/belgique/bruxelles/10.jpg',
          'assets4/belgique/bruxelles/11.jpg',
        ],
        'history':
        'The beating historic heart of Brussels, the Grand-Place is world-renowned for the richness of its ornamental and architectural decoration, bringing together opulent guild houses, the Gothic Town Hall, and the King\'s House. Largely rebuilt after the destructive bombardment of 1695 by French troops, it is a UNESCO World Heritage site.',
        'tip': 'A must-see both day and night. Check the weather before leaving.',
        'mapsQuery': 'Grand-Place Brussels',
      },
      {
        'id': 'mannekenpis',
        'title': 'Manneken-Pis and Jeanneke-Pis',
        'images': [
          'assets4/belgique/bruxelles/199.jpg',
          'assets4/belgique/bruxelles/14.jpg',
        ],
        'history':
        'Located in the immediate vicinity of the Grand-Place, Manneken-Pis is a small bronze fountain representing a urinating boy, symbol of the independent, defiant, and humorous spirit of the people of Brussels (dressed in traditional costumes on various occasions). Jeanneke-Pis, its female counterpart located in a neighboring alley (Impasse de la Fidélité), was created later in 1987 to promote local folklore and support charities.',
        'tip': 'Plan a quick walk through the pedestrian alleys. Check the weather before leaving.',
        'mapsQuery': 'Manneken-Pis Brussels',
      },
      {
        'id': 'galeries',
        'title': 'Royal Saint-Hubert Galleries',
        'images': [
          'assets4/belgique/bruxelles/15.jpg',
        ],
        'history':
        'Inaugurated in 1847 a stone\'s throw from the Grand-Place, these superb covered shopping galleries (divided into Gallery of the Queen, the King, and the Princes) are among the oldest and most elegant in Europe. Designed by architect Jean-Pierre Cluysenaar, they are famous for their luxury display windows, historic artisan chocolate shops, theaters, and luminous glass roof.',
        'tip': 'Taste the artisan chocolates on site. Check the weather before leaving.',
        'mapsQuery': 'Royal Saint-Hubert Galleries Brussels',
      },
      {
        'id': 'montdesarts',
        'title': 'Mont des Arts',
        'images': [
          'assets4/belgique/bruxelles/16.jpg',
          'assets4/belgique/bruxelles/17.webp',
        ],
        'history':
        'Originally laid out for the 1910 International Exhibition and then completely redesigned in the 1950s during the city\'s major urban renewal projects, the Mont des Arts links the Upper Town (museum and royal palace district) and the Lower Town (historic center). It offers a sloping geometric garden and one of the most spectacular panoramas over the rooftops of Brussels and the Town Hall.',
        'tip': 'Magnificent view at sunset. Check the weather before leaving.',
        'mapsQuery': 'Mont des Arts Brussels',
      },
      {
        'id': 'palaisjustice',
        'title': 'Palace of Justice',
        'images': [
          'assets4/belgique/bruxelles/18.jpg',
          'assets4/belgique/bruxelles/19.webp',
          'assets4/belgique/bruxelles/20.webp',
          'assets4/belgique/bruxelles/21.jpg',
        ],
        'history':
        'Built between 1866 and 1883 by architect Joseph Poelaert, this colossal building dominates the Marolles district and offers a breathtaking view of the city. It is one of the largest courthouse buildings constructed in 19th-century Europe, surpassing certain basilicas in its ground surface area. Its monumental architecture mixes Greco-Roman and Assyrian inspirations.',
        'tip': 'Admire the sheer scale of the architecture. Check the weather before leaving.',
        'mapsQuery': 'Palace of Justice Brussels',
      },
    ],
  },
  {
    'neighborhood': 'Heysel / North',
    'places': [
      {
        'id': 'atomium',
        'title': 'Atomium',
        'images': [
          'assets4/belgique/bruxelles/22.jpg',
          'assets4/belgique/bruxelles/23.jpg',
          'assets4/belgique/bruxelles/24.jpg',
        ],
        'history':
        'Designed for the 1958 Brussels World\'s Fair (Expo 58) by architect André Waterkeyn and engineers Pol and Jean Cornellie, the Atomium represents the elementary unit of an iron crystal magnified 165 billion times. A true Belgian version of the Eiffel Tower, it symbolizes bold faith in scientific progress, modernity, and the post-war atomic era. From its summit or at its feet, one can also listen to and observe the impressive ballet of planes taking off and landing, with Zaventem airport located right next door.',
        'tip': 'Visit on weekdays, outside school holidays and avoid weekends. Check the weather before leaving.',
        'mapsQuery': 'Atomium Brussels',
      },
      {
        'id': 'minieurope',
        'title': 'Mini-Europe',
        'images': [
          'assets4/belgique/bruxelles/25.webp',
          'assets4/belgique/bruxelles/26.jpg',
        ],
        'history':
        'Inaugurated in 1989 right at the foot of the Atomium (the two sites are thus ideally visited together), the Mini-Europe park allows visitors to tour the European Union in a few steps through nearly 350 landmark European monuments reproduced at a 1/25 scale with impressive attention to detail, animations, and sound effects.',
        'tip': 'Visit on weekdays, outside school holidays and avoid weekends. Check the weather before leaving.',
        'mapsQuery': 'Mini-Europe Brussels',
      },
    ],
  },
  {
    'neighborhood': 'Laeken (North-West)',
    'places': [
      {
        'id': 'laeken',
        'title': 'Royal Greenhouses of Laeken',
        'images': [
          'assets4/belgique/bruxelles/27.webp',
          'assets4/belgique/bruxelles/28.jpg',
          'assets4/belgique/bruxelles/29.webp',
        ],
        'history':
        'Royal residential district housing the Castle of Laeken (residence of the Belgian royal family) and its famous monumental iron and glass greenhouses. Designed by architect Alphonse Balat for King Leopold II in the late 19th century, they constitute a masterpiece of metal architecture and house rare botanical collections, open to the public only a few weeks a year in spring.',
        'tip': 'Exceptional opening in spring. Check the weather before leaving.',
        'mapsQuery': 'Castle of Laeken Brussels',
      },
    ],
  },
];

/// All place entries from a list of neighborhoods, flattened.
List<Map<String, dynamic>> _getPlaces(List<Map<String, dynamic>> neighborhoods) => [
  for (final q in neighborhoods)
    ...(q['places'] as List).cast<Map<String, dynamic>>(),
];

// =============================================================================
//  SHARED UTILITIES
// =============================================================================

/// Transition: fade + slight upward slide (or fade only).
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

/// Asset image with graceful error handling.
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
//  REUSABLE WIDGETS
// =============================================================================

/// Animated background: two gold/purple halos that drift slowly.
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

/// Progressive entrance (fade + rise) on display, with an optional delay.
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

/// Touch feedback: slight scale-down on press.
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

/// Image that slightly enlarges on touch before opening the full-screen gallery.
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

/// Frosted-glass icon button.
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

/// Shared top bar (used by the Favorites screen).
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

/// Small chip (counter, legend).
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

/// Tip box.
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

/// Primary gold gradient button.
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

/// Secondary button (gold or neutral).
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

/// Segmented progress bar: one illuminated segment per visited place.
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

/// Animated “visited” chip.
class _VisitChip extends StatelessWidget {
  const _VisitChip({required this.isVisited, required this.onTap});

  final bool isVisited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isVisited ? _goldAccent.withOpacity(0.14) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isVisited ? _goldAccent.withOpacity(0.5) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isVisited ? Icons.check_circle : Icons.radio_button_unchecked,
                key: ValueKey(isVisited),
                color: isVisited ? _goldAccent : Colors.white38,
                size: 15,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isVisited ? 'Place visited' : 'Mark as visited',
              style: TextStyle(
                color: isVisited ? _goldLight : Colors.white54,
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

/// Favorite heart with an elastic bounce.
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

/// Circular badge with a continuously rotating decorative ring.
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

/// Title with a subtle gold shimmer that sweeps across the text in a loop.
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

/// Continuously scrolling banner with place names.
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

/// Place image carousel: larger, sliding with a side preview
/// and depth effect (neighboring images are slightly reduced),
/// subtle enlargement on touch before opening full screen.
class _Carousel extends StatefulWidget {
  const _Carousel({required this.images, required this.onTapImage});

  final List<String> images;
  final ValueChanged<int> onTapImage;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
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

/// Neighborhood header, displayed at the top of the section (not pinned).
class _NeighborhoodTitleBlock extends StatelessWidget {
  const _NeighborhoodTitleBlock({required this.index, required this.title});

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

/// Persistent sliver delegate: the neighborhood title starts large,
///gradually shrinks, then stays pinned at the top while scrolling.
class _NeighborhoodHeaderDelegate extends SliverPersistentHeaderDelegate {
  _NeighborhoodHeaderDelegate({required this.index, required this.title});

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
  bool shouldRebuild(covariant _NeighborhoodHeaderDelegate oldDelegate) =>
      oldDelegate.title != title || oldDelegate.index != index;
}

/// Gentle floating animation for an element (empty state).
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
//  FULL-SCREEN GALLERY
// =============================================================================
class _GalleryScreen extends StatefulWidget {
  const _GalleryScreen({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<_GalleryScreen> {
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
//  MAIN PAGE — BRUSSELS
// =============================================================================
class Brussels extends StatefulWidget {
  const Brussels({super.key});

  @override
  State<Brussels> createState() => _BrusselsState();
}

class _BrusselsState extends State<Brussels> {
  List<String> _brusselsFavorites = [];
  List<String> _visitedBrusselsPlaces = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBrusselsData();
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
      for (final place in _getPlaces(_brusselsNeighborhoods)) {
        for (final String imgPath in List<String>.from(place['images'] as List)) {
          precacheImage(AssetImage(imgPath), context);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  //  Data & persistence (logic unchanged)
  // ---------------------------------------------------------------------------
  Future<void> _loadBrusselsData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _brusselsFavorites = List<String>.from(prefs.getStringList('favoris_bruxelles_en') ?? []);
      _visitedBrusselsPlaces = List<String>.from(prefs.getStringList('lieux_visites_bruxelles_en') ?? []);
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_brusselsFavorites.contains(id)) {
        _brusselsFavorites.remove(id);
      } else {
        _brusselsFavorites.add(id);
      }
    });
    await prefs.setStringList('favoris_bruxelles_en', _brusselsFavorites);
  }

  Future<void> _addAllToFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _brusselsFavorites = _getPlaces(_brusselsNeighborhoods).map((l) => l['id'] as String).toList();
    });
    await prefs.setStringList('favoris_bruxelles_en', _brusselsFavorites);
  }

  Future<void> _removeAllFromFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _brusselsFavorites.clear());
    await prefs.setStringList('favoris_bruxelles_en', _brusselsFavorites);
  }

  Future<void> _toggleVisited(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_visitedBrusselsPlaces.contains(id)) {
        _visitedBrusselsPlaces.remove(id);
      } else {
        _visitedBrusselsPlaces.add(id);
      }
    });
    await prefs.setStringList('lieux_visites_bruxelles_en', _visitedBrusselsPlaces);
  }

  Future<void> _markAllAsVisited() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _visitedBrusselsPlaces = _getPlaces(_brusselsNeighborhoods).map((l) => l['id'] as String).toList();
    });
    await prefs.setStringList('lieux_visites_bruxelles_en', _visitedBrusselsPlaces);
  }

  Future<void> _clearVisitedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _visitedBrusselsPlaces.clear());
    await prefs.setStringList('lieux_visites_bruxelles_en', _visitedBrusselsPlaces);
  }

  Future<void> _openMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openGallery(List<String> images, int index) {
    Navigator.of(context).push(
      _route(_GalleryScreen(images: images, initialIndex: index), slide: false),
    );
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context).push(
      _route(BrusselsFavoritesPage(neighborhoods: _brusselsNeighborhoods)),
    );
    _loadBrusselsData();
  }

  // ---------------------------------------------------------------------------
  //  UI construction
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final int totalPlaces = _getPlaces(_brusselsNeighborhoods).length;
    final int visitedCount = _visitedBrusselsPlaces.length;
    final double progress = totalPlaces > 0 ? visitedCount / totalPlaces : 0.0;

    Color progressColor = Colors.orangeAccent;
    if (progress > 0.3 && progress <= 0.7) {
      progressColor = _goldAccent;
    } else if (progress > 0.7) {
      progressColor = Colors.greenAccent;
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
                  items: _getPlaces(_brusselsNeighborhoods).map((l) => l['title'] as String).toList(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(child: _Reveal(delay: 100, child: _buildIntro())),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: _Reveal(
                  delay: 180,
                  child: _buildProgressCard(totalPlaces, visitedCount, progress, progressColor),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(child: _Reveal(delay: 240, child: _buildListesCard())),
              for (int qi = 0; qi < _brusselsNeighborhoods.length; qi++) ..._buildNeighborhoodSlivers(qi),
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
    final int totalPlaces = _getPlaces(_brusselsNeighborhoods).length;
    return Padding(
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 66, 10, 0),
      child: GestureDetector(
        onTap: () => _openGallery(const [heroImage], 0),
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
                      'BELGIUM',
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
                        'Brussels · Travel guide',
                        style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Text('The Elegance', style: _serif(size: 62, weight: FontWeight.w300, height: 1.0, spacing: -1.8, color: Colors.white)),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) => const LinearGradient(colors: [_lime, _sand, Color(0xFFFFB4A2)]).createShader(b),
                        child: Text(
                          'of the Capital',
                          style: _serif(size: 46, weight: FontWeight.w300, height: 1.1, spacing: -0.8, style: FontStyle.italic, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _HeroInfoPill(label: '${_brusselsNeighborhoods.length} neighborhood'),
                          const SizedBox(width: 8),
                          _HeroInfoPill(label: '$totalPlaces places'),
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
            'Sovereign capital of Belgium and institutional nerve center of the European Union, Brussels fuses exceptional architectural heritage, cultural avant-gardism, and a rare elegance in lifestyle.',
            style: _serif(size: 21, weight: FontWeight.w400, color: _paper, height: 1.55, spacing: -0.2),
          ),
          const SizedBox(height: 22),
          _TipBox(
            icon: Icons.info_outline_rounded,
            text: 'Tips: Visit Brussels on weekdays, outside school holidays and avoid weekends. Remember to check the weather before leaving.',
            textColor: _ink,
            bg: _lime,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int total, int visited, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
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
                  'Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '$visited / $total visited',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
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
            _SegmentedBar(total: total, filled: visited, color: color),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SoftButton(
                    label: 'Mark all as visited',
                    gold: true,
                    onTap: _markAllAsVisited,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftButton(
                    label: 'Reset visited places',
                    onTap: _clearVisitedPlaces,
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
                    label: 'Add all to favorites',
                    gold: true,
                    onTap: _addAllToFavorites,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftButton(
                    label: 'Remove all from favorites',
                    onTap: _removeAllFromFavorites,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Pressable(
              onTap: _openFavorites,
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
                      'Saved favorites (${_brusselsFavorites.length})',
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

  /// Neighborhood slivers: a shrinking pinned header, followed by its places.
  List<Widget> _buildNeighborhoodSlivers(int qi) {
    final q = _brusselsNeighborhoods[qi];
    final places = (q['places'] as List).cast<Map<String, dynamic>>();
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _NeighborhoodHeaderDelegate(index: qi + 1, title: q['neighborhood'] as String),
      ),
      SliverPadding(
        padding: const EdgeInsets.only(top: 18),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, li) => _Reveal(delay: 60 * li, child: _buildPlaceCard(places[li])),
            childCount: places.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final String id = place['id'] as String;
    final String title = place['title'] as String;
    final List<String> images = List<String>.from(place['images'] as List);
    final bool isFavorite = _brusselsFavorites.contains(id);
    final bool isVisited = _visitedBrusselsPlaces.contains(id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Carousel(images: images, onTapImage: (i) => _openGallery(images, i)),
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
                        title,
                        softWrap: true,
                        style: _serif(size: 33, weight: FontWeight.w400, height: 1.08, spacing: -0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeartButton(isOn: isFavorite, onTap: () => _toggleFavorite(id)),
                  ],
                ),
                const SizedBox(height: 16),
                _VisitChip(isVisited: isVisited, onTap: () => _toggleVisited(id)),
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
                          place['history'] as String,
                          style: const TextStyle(fontSize: 14.5, color: _fgSoft, height: 1.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _TipBox(
                  icon: Icons.lightbulb_outline_rounded,
                  text: place['tip'] as String,
                  textColor: _ink,
                  bg: _sand,
                ),
                const SizedBox(height: 22),
                _GoldButton(
                  label: 'Open in Google Maps',
                  icon: Icons.navigation_rounded,
                  onTap: () => _openMaps(place['mapsQuery'] as String),
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
//  FAVORITES PAGE — ANTWERP
// =============================================================================
class BrusselsFavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> neighborhoods;

  const BrusselsFavoritesPage({super.key, required this.neighborhoods});

  @override
  State<BrusselsFavoritesPage> createState() => _BrusselsFavoritesPageState();
}

class _BrusselsFavoritesPageState extends State<BrusselsFavoritesPage> {
  List<String> _brusselsFavorites = [];
  bool _isLoading = true;

  /// Places being removed (exit animation before actual removal).
  final Set<String> _sortants = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _brusselsFavorites = List<String>.from(prefs.getStringList('favoris_bruxelles_en') ?? []);
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String id) async {
    if (_sortants.contains(id)) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() => _sortants.add(id));
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _brusselsFavorites.remove(id);
      _sortants.remove(id);
    });
    await prefs.setStringList('favoris_bruxelles_en', _brusselsFavorites);
  }

  @override
  Widget build(BuildContext context) {
    final int n = _brusselsFavorites.length;

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
                const _TopBar(title: 'Brussels Favorites'),
                _Reveal(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Favorites',
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
                                'favorite${n > 1 ? 's' : ''}\nBrussels',
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
                ..._buildGroups(),
                if (n == 0) _buildEmptyState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroups() {
    final List<Widget> widgets = [];
    int index = 0;
    for (int qi = 0; qi < widget.neighborhoods.length; qi++) {
      final q = widget.neighborhoods[qi];
      final String neighborhoodName = q['neighborhood'] as String;
      final favs = (q['places'] as List)
          .cast<Map<String, dynamic>>()
          .where((l) => _brusselsFavorites.contains(l['id']))
          .toList();
      if (favs.isEmpty) continue;

      widgets.add(_NeighborhoodTitleBlock(index: qi + 1, title: neighborhoodName));
      for (final place in favs) {
        widgets.add(
          _Reveal(
            key: ValueKey('rv_${place['id']}'),
            delay: 60 * index,
            child: _favoriteTile(place),
          ),
        );
        index++;
      }
    }
    return widgets;
  }

  Widget _favoriteTile(Map<String, dynamic> place) {
    final String id = place['id'] as String;
    final List<String> images = List<String>.from(place['images'] as List);
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
                    place['title'] as String,
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
                  onTap: () => _removeFavorite(id),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const _Float(
            child: Icon(Icons.favorite_border, color: _goldAccent, size: 56),
          ),
          const SizedBox(height: 18),
          const Text(
            'No saved favorites for Brussels.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}