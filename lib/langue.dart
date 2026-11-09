import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Importations selon votre arborescence
import 'belgique/français/home.dart' as fr;
import 'belgique/anglais/home.dart' as en;
import 'selecteur_langue.dart';

// ===========================================================================
//  PAGE D'OUVERTURE : la Belgique, décor de Bruxelles au fil du soleil.
//  Une seule page : la personne choisit elle-même sa langue (Français / English)
//  et entre directement dans l'application.
// ===========================================================================

class LanguePage extends StatefulWidget {
  const LanguePage({super.key});

  @override
  State<LanguePage> createState() => _LanguePageState();
}

class _LanguePageState extends State<LanguePage>
    with TickerProviderStateMixin {
  // Palette Luxe Belge (Noir Obsidienne & Or Impérial)
  static const Color _bgObsidian = Color(0xFF040407);
  static const Color _goldImperial = Color(0xFFD4AF37);
  static const Color _goldChampagne = Color(0xFFF3E5AB);

  late final AnimationController _sunController; // cycle lever / coucher du soleil (56 s, en boucle)
  late final AnimationController _loopController; // trains, eau, reflets (boucle)
  late final AnimationController _entranceController; // apparition des textes

  @override
  void initState() {
    super.initState();
    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 56),
    )..repeat();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _sunController.dispose();
    _loopController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // Index 0 = Français, 1 = English
  void _choisirLangue(int index) {
    HapticFeedback.mediumImpact();

    final Widget pageDestination =
    index == 1 ? const en.HomeEnglish() : const fr.Home();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pageDestination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _stagger(double start, double end, Widget child) {
    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, ch) {
        final double p = Curves.easeOutCubic.transform(
          ((_entranceController.value - start) / (end - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(0, (1 - p) * 24),
            child: ch,
          ),
        );
      },
    );
  }

  Widget _ornament() {
    Widget line(bool left) => Container(
      width: 54,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: left ? Alignment.centerLeft : Alignment.centerRight,
          end: left ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            _goldImperial.withOpacity(0.0),
            _goldChampagne.withOpacity(0.9),
          ],
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line(true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.diamond_outlined, color: _goldChampagne, size: 14),
        ),
        line(false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

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
          backgroundColor: _bgObsidian,
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ---- Scène de Bruxelles ----
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _BrusselsIntroPainter(
                          sun: _sunController,
                          loop: _loopController,
                        ),
                      ),
                    ),

                    // ---- Voile sombre en haut pour garder le texte lisible ----
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: screenHeight * 0.46,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.55),
                                Colors.black.withOpacity(0.22),
                                Colors.black.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---- Titre + choix de la langue ----
                    SafeArea(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.035),
                          _stagger(
                            0.0,
                            0.5,
                            Column(
                              children: [
                                _ornament(),
                                const SizedBox(height: 10),
                                ShaderMask(
                                  shaderCallback: (Rect r) => const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFFF6D6),
                                      Color(0xFFF3E5AB),
                                      Color(0xFFD4AF37),
                                    ],
                                  ).createShader(r),
                                  child: Text(
                                    'Belgique',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 46,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.55),
                                          blurRadius: 18,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'BONJOUR   •   HELLO',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.92),
                                    letterSpacing: 3.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Ruban Drapeau Belge discret
                                Container(
                                  height: 3,
                                  width: 84,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF000000),
                                        Color(0xFFD4AF37),
                                        Color(0xFF7A0C0C),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Pied de page : sélecteur de langue, isolé de la scène ----
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _bgObsidian,
                  border: Border(
                    top: BorderSide(color: Color(0x33D4AF37), width: 0.6),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _stagger(
                      0.35,
                      1.0,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Vous pouvez cliquer sur la langue français ou anglais',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.82),
                              letterSpacing: 0.4,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You can tap the language, French or English',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFF3E5AB).withOpacity(0.7),
                              letterSpacing: 0.4,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SelecteurLangue(
                            onFrench: () => _choisirLangue(0),
                            onEnglish: () => _choisirLangue(1),
                          ),
                        ],
                      ),
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
}

// ===========================================================================
//  DÉCOR : lever de soleil sur Bruxelles
//  Parc de Laeken (serres royales), Grand-Place, Commission européenne,
//  Parlement européen, Manneken-Pis, et le train dans son tunnel
//  (deux sens, vrais rails).
// ===========================================================================

class _BrusselsIntroPainter extends CustomPainter {
  final Animation<double> sun; // lever du soleil (une seule fois)
  final Animation<double> loop; // trains, eau, drapeaux... (en boucle)

  _BrusselsIntroPainter({required this.sun, required this.loop})
      : super(repaint: Listenable.merge([sun, loop]));

  static Color _lerp3(Color a, Color b, Color c, double p) {
    return p < 0.5
        ? Color.lerp(a, b, p * 2)!
        : Color.lerp(b, c, (p - 0.5) * 2)!;
  }

  static double _smooth(double x) {
    final double c = x.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  // Cycle : nuit -> lever (0.02-0.24) -> jour -> coucher (0.56-0.80) -> nuit
  static double _daylight(double d) {
    if (d < 0.02) return 0.0;
    if (d < 0.24) return _smooth((d - 0.02) / 0.22);
    if (d < 0.56) return 1.0;
    if (d < 0.80) return 1.0 - _smooth((d - 0.56) / 0.24);
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double d = sun.value; // position dans le cycle jour / nuit (0..1)
    final double t = loop.value;
    final double sunP = _daylight(d); // luminosité : 0 = nuit, 1 = plein jour
    final bool evening = d > 0.5;
    final double w = size.width;
    final double h = size.height;
    final double groundY = h * 0.74; // niveau de la rue
    final double streetBottom = h * 0.84; // bas de la rue / haut du tunnel

    // ---- Ciel : nuit -> aube -> jour ----
    final Color skyTop = _lerp3(
      const Color(0xFF070B2A),
      evening ? const Color(0xFF4A2F86) : const Color(0xFF2E3A8C),
      const Color(0xFF5AA9E6),
      sunP,
    );
    final Color skyBottom = _lerp3(
      const Color(0xFF1E1650),
      evening ? const Color(0xFFFF5F6D) : const Color(0xFFFF7E5F),
      const Color(0xFFFFD9A0),
      sunP,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, Color.lerp(skyTop, skyBottom, 0.6)!, skyBottom],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, groundY)),
    );

    _drawStars(canvas, size, t, sunP);
    _drawSun(canvas, size, d, sunP, groundY);
    _drawClouds(canvas, size, t, sunP);

    final Color farColor =
    Color.lerp(const Color(0xFF1A1740), const Color(0xFF6B4E7A), sunP)!;

    _drawSkyline(canvas, size, groundY, farColor);
    _drawLaeken(canvas, size, groundY, sunP, t);
    _drawGrandPlace(canvas, size, groundY, sunP);
    _drawCommission(canvas, size, groundY, sunP, t);
    _drawParliament(canvas, size, groundY, sunP);
    _drawStreet(canvas, size, groundY, streetBottom, sunP, t);
    _drawMannekenPis(canvas, size, streetBottom, sunP, t);
    _drawTunnel(canvas, size, streetBottom, t, sunP);
    _drawBirds(canvas, size, t, sunP);
  }

  // ------------------------------------------------------------------------
  //  CIEL
  // ------------------------------------------------------------------------
  void _drawStars(Canvas canvas, Size size, double t, double sunP) {
    final double visible = (1 - sunP * 1.6).clamp(0.0, 1.0);
    if (visible <= 0) return;
    final Random rnd = Random(7);
    final Paint paint = Paint();
    for (int i = 0; i < 70; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height * 0.55;
      final double r = 0.6 + rnd.nextDouble() * 1.4;
      final double twinkle = 0.5 + 0.5 * sin(t * 2 * pi * 5 + i * 1.3);
      paint.color = Colors.white.withOpacity(visible * (0.35 + 0.65 * twinkle));
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  // Le soleil trace un arc : il se lève à gauche, culmine, se couche à droite.
  void _drawSun(Canvas canvas, Size size, double d, double sunP, double groundY) {
    final double a = ((d - 0.02) / 0.78).clamp(0.0, 1.0);
    final double arc = sin(pi * a);
    final double r = size.width * 0.085;
    final double startY = groundY + r;
    final double peakY = size.height * 0.34;
    final Offset center = Offset(
      size.width * (0.10 + 0.80 * a),
      startY + (peakY - startY) * arc,
    );
    final Color sunColor = Color.lerp(
      const Color(0xFFFF6A3D),
      const Color(0xFFFFE08A),
      Curves.easeOut.transform(arc),
    )!;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, groundY));
    final double glowR = r * 4.2;
    canvas.drawCircle(
      center,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            sunColor.withOpacity(0.35 + 0.35 * arc),
            sunColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: glowR)),
    );
    canvas.drawCircle(center, r, Paint()..color = sunColor);
    canvas.restore();
  }

  void _drawClouds(Canvas canvas, Size size, double t, double sunP) {
    final Paint paint = Paint()
      ..color = Color.lerp(const Color(0xFF6C5BA8), const Color(0xFFFFC9A8), sunP)!
          .withOpacity(0.38);
    final List<List<double>> clouds = [
      [0.10, 0.30, 0.9, 1],
      [0.55, 0.46, 1.2, 2],
      [0.85, 0.55, 0.8, 1],
    ];
    for (int i = 0; i < clouds.length; i++) {
      final double yy = size.height * clouds[i][1];
      final double scale = clouds[i][2];
      final double x = ((clouds[i][0] + t * 1.3 * clouds[i][3]) % 1.3 - 0.15) * size.width;
      final double cw = size.width * 0.22 * scale;
      final double ch = size.height * 0.022 * scale;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, yy), width: cw, height: ch), paint);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + cw * 0.22, yy - ch * 0.5), width: cw * 0.6, height: ch * 1.1),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - cw * 0.25, yy + ch * 0.2), width: cw * 0.5, height: ch * 0.9),
        paint,
      );
    }
  }

  void _drawSkyline(Canvas canvas, Size size, double groundY, Color color) {
    final Random rnd = Random(3);
    final Paint p = Paint()..color = color;
    double x = -4;
    while (x < size.width) {
      final double bw = size.width * (0.03 + rnd.nextDouble() * 0.04);
      final double bh = size.height * (0.03 + rnd.nextDouble() * 0.05);
      canvas.drawRect(Rect.fromLTWH(x, groundY - bh, bw, bh), p);
      x += bw - 1;
    }
  }

  // ------------------------------------------------------------------------
  //  PARC DE LAEKEN : colline, arbres, serres royales (pavillons de verre)
  // ------------------------------------------------------------------------
  void _drawLaeken(Canvas canvas, Size size, double groundY, double sunP, double t) {
    final double w = size.width;
    final double h = size.height;
    final double hw = w * 0.30;
    final Color hill = Color.lerp(const Color(0xFF0B2A22), const Color(0xFF4E8B5A), sunP)!;
    final Color treeC = Color.lerp(const Color(0xFF08201A), const Color(0xFF2F6B43), sunP)!;

    final double y0 = groundY - h * 0.06;
    final double y1 = groundY - h * 0.115;
    final double y2 = groundY - h * 0.015;

    double hillY(double x) {
      final double s = (x / hw).clamp(0.0, 1.0);
      return (1 - s) * (1 - s) * y0 + 2 * (1 - s) * s * y1 + s * s * y2;
    }

    canvas.drawPath(
      Path()
        ..moveTo(0, groundY)
        ..lineTo(0, y0)
        ..quadraticBezierTo(hw / 2, y1, hw, y2)
        ..lineTo(hw, groundY)
        ..close(),
      Paint()..color = hill,
    );

    // Serres royales : pavillons de verre et de fer à toits à pignon
    final double xc = w * 0.13;
    final double yb = hillY(xc) + 2;
    final Color glass = Color.lerp(const Color(0xFF1C4A55), const Color(0xFFBFE8E0), sunP)!;
    final Color roofC = Color.lerp(const Color(0xFF2A6270), const Color(0xFFD6F0EA), sunP)!;
    final double night = (1 - sunP * 1.4).clamp(0.0, 1.0);
    final Paint bar = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..strokeWidth = 0.8;
    final Paint ridge = Paint()
      ..color = const Color(0xFFFFD27A).withOpacity(0.35 + 0.4 * sunP)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    void pavilion(double cx, double pw, double wallH, double roofH) {
      final Rect wall = Rect.fromLTWH(cx - pw / 2, yb - wallH, pw, wallH);
      canvas.drawRect(wall, Paint()..color = glass);
      canvas.drawRect(
        wall,
        Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.32 * night),
      );
      final Path roof = Path()
        ..moveTo(cx - pw / 2 - 1.5, yb - wallH)
        ..lineTo(cx, yb - wallH - roofH)
        ..lineTo(cx + pw / 2 + 1.5, yb - wallH)
        ..close();
      canvas.drawPath(roof, Paint()..color = roofC);
      canvas.drawPath(roof, ridge);
      for (double gx = cx - pw / 2 + 5; gx < cx + pw / 2; gx += 6) {
        canvas.drawLine(Offset(gx, yb - wallH), Offset(gx, yb), bar);
      }
      canvas.drawLine(Offset(cx, yb - wallH - roofH), Offset(cx, yb - wallH), bar);
    }

    pavilion(xc - w * 0.075, w * 0.05, h * 0.022, h * 0.014);
    pavilion(xc + w * 0.075, w * 0.05, h * 0.022, h * 0.014);
    pavilion(xc, w * 0.085, h * 0.034, h * 0.026);

    // Arbres du parc
    final List<double> xs = [0.015, 0.035, 0.225, 0.245, 0.265, 0.075, 0.185];
    for (int i = 0; i < xs.length; i++) {
      final double x = w * xs[i];
      final double y = hillY(x) + (i >= 5 ? 6 : 1);
      final double cr = w * (i >= 5 ? 0.014 : 0.019);
      final double sway = sin(t * 2 * pi * 6 + i) * 0.8;
      canvas.drawRect(Rect.fromLTWH(x - 1.2, y - cr * 0.4, 2.4, cr * 0.9), Paint()..color = treeC);
      canvas.drawCircle(Offset(x + sway, y - cr * 1.1), cr, Paint()..color = treeC);
      canvas.drawCircle(Offset(x + sway - cr * 0.6, y - cr * 0.6), cr * 0.7, Paint()..color = treeC);
      canvas.drawCircle(Offset(x + sway + cr * 0.6, y - cr * 0.6), cr * 0.7, Paint()..color = treeC);
    }
  }

  // ------------------------------------------------------------------------
  //  GRAND-PLACE : maisons des corporations dorées + tour de l'Hôtel de Ville
  // ------------------------------------------------------------------------
  void _drawGrandPlace(Canvas canvas, Size size, double groundY, double sunP) {
    final double w = size.width;
    final double h = size.height;
    final Color stone = Color.lerp(const Color(0xFF15122F), const Color(0xFF8A6E64), sunP)!;
    final Color stoneAlt = Color.lerp(const Color(0xFF1B1840), const Color(0xFFA3847A), sunP)!;
    final Color gold = Color.lerp(const Color(0xFF6B5420), const Color(0xFFFFD27A), sunP)!;
    final double night = (1 - sunP * 1.5).clamp(0.0, 1.0);
    final Paint goldPaint = Paint()..color = gold;
    final Paint winPaint = Paint()
      ..color = const Color(0xFFFFE6A8).withOpacity(0.22 + 0.65 * night);

    void windows(double x, double top, double bw, double bh, int rows) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < 2; c++) {
          canvas.drawRect(
            Rect.fromLTWH(x + bw * (0.2 + 0.4 * c), top + bh * (0.22 + 0.24 * r), bw * 0.2, bh * 0.12),
            winPaint,
          );
        }
      }
    }

    void house(double fx, double fh, int style, Color c) {
      final double x = w * fx;
      final double bw = w * 0.04;
      final double top = groundY - h * fh;
      final double gh = h * 0.012;
      final Path p = Path()..moveTo(x, groundY);
      if (style == 0) {
        p
          ..lineTo(x, top + gh * 2)
          ..lineTo(x + bw * 0.2, top + gh * 2)
          ..lineTo(x + bw * 0.2, top + gh)
          ..lineTo(x + bw * 0.4, top + gh)
          ..lineTo(x + bw * 0.4, top)
          ..lineTo(x + bw * 0.6, top)
          ..lineTo(x + bw * 0.6, top + gh)
          ..lineTo(x + bw * 0.8, top + gh)
          ..lineTo(x + bw * 0.8, top + gh * 2)
          ..lineTo(x + bw, top + gh * 2);
      } else if (style == 1) {
        p
          ..lineTo(x, top + gh * 2.5)
          ..lineTo(x + bw * 0.25, top + gh * 2.5)
          ..lineTo(x + bw * 0.25, top + gh * 1.2)
          ..lineTo(x + bw * 0.4, top + gh * 1.2)
          ..lineTo(x + bw * 0.4, top)
          ..lineTo(x + bw * 0.6, top)
          ..lineTo(x + bw * 0.6, top + gh * 1.2)
          ..lineTo(x + bw * 0.75, top + gh * 1.2)
          ..lineTo(x + bw * 0.75, top + gh * 2.5)
          ..lineTo(x + bw, top + gh * 2.5);
      } else {
        p
          ..lineTo(x, top + gh * 2)
          ..lineTo(x + bw * 0.5, top)
          ..lineTo(x + bw, top + gh * 2);
      }
      p
        ..lineTo(x + bw, groundY)
        ..close();
      canvas.drawPath(p, Paint()..color = c);
      // statue dorée au sommet + corniches
      canvas.drawPath(
        Path()
          ..moveTo(x + bw * 0.5 - 1.6, top)
          ..lineTo(x + bw * 0.5, top - 5)
          ..lineTo(x + bw * 0.5 + 1.6, top)
          ..close(),
        goldPaint,
      );
      for (final double f in [0.35, 0.62]) {
        canvas.drawRect(Rect.fromLTWH(x, top + (groundY - top) * f, bw, 1.4), goldPaint);
      }
      windows(x, top, bw, groundY - top, 3);
    }

    house(0.28, 0.085, 0, stone);
    house(0.32, 0.105, 1, stoneAlt);
    house(0.36, 0.09, 2, stone);
    house(0.46, 0.10, 1, stone);
    house(0.50, 0.085, 0, stoneAlt);

    // Hôtel de Ville (gothique) : façade, toit à lucarnes, tour ajourée
    void pointed(double x, double y, double ww, double hh, Paint p) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + hh)
          ..lineTo(x, y + hh * 0.38)
          ..lineTo(x + ww / 2, y)
          ..lineTo(x + ww, y + hh * 0.38)
          ..lineTo(x + ww, y + hh)
          ..close(),
        p,
      );
    }

    final double bx = w * 0.40;
    final double bw = w * 0.06;
    final double btop = groundY - h * 0.10;
    final double bh = groundY - btop;
    final double roofTop = btop - h * 0.026;

    // Toit en pente
    canvas.drawPath(
      Path()
        ..moveTo(bx - 1.5, btop)
        ..lineTo(bx + bw * 0.1, roofTop)
        ..lineTo(bx + bw * 0.9, roofTop)
        ..lineTo(bx + bw + 1.5, btop)
        ..close(),
      Paint()..color = stone,
    );
    // Lucarnes
    for (int c = 0; c < 3; c++) {
      final double dx = bx + bw * (0.18 + 0.28 * c);
      canvas.drawPath(
        Path()
          ..moveTo(dx, btop)
          ..lineTo(dx + bw * 0.06, btop - h * 0.016)
          ..lineTo(dx + bw * 0.12, btop)
          ..close(),
        Paint()..color = stoneAlt,
      );
    }
    // Façade
    canvas.drawRect(Rect.fromLTWH(bx, btop, bw, bh), Paint()..color = stoneAlt);
    for (final double f in [0.0, 0.48]) {
      canvas.drawRect(Rect.fromLTWH(bx, btop + bh * f, bw, 1.6), goldPaint);
    }
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 6; c++) {
        pointed(
          bx + bw * (0.07 + 0.15 * c),
          btop + bh * (r == 0 ? 0.12 : 0.58),
          bw * 0.09,
          bh * 0.28,
          winPaint,
        );
      }
    }
    // Tourelles d'angle
    for (final double fx in [bx, bx + bw - 3.5]) {
      canvas.drawRect(Rect.fromLTWH(fx, btop - h * 0.012, 3.5, h * 0.012), Paint()..color = stone);
      canvas.drawPath(
        Path()
          ..moveTo(fx - 0.6, btop - h * 0.012)
          ..lineTo(fx + 1.75, btop - h * 0.03)
          ..lineTo(fx + 4.1, btop - h * 0.012)
          ..close(),
        Paint()..color = stone,
      );
    }

    // Tour : base carrée, étage octogonal, flèche gothique ajourée à croix dorée
    final double tx = bx + bw * 0.30;
    final double tw = w * 0.05;
    final double t1 = roofTop - h * 0.05;
    canvas.drawRect(Rect.fromLTRB(tx - tw / 2, t1, tx + tw / 2, roofTop + 1), Paint()..color = stone);
    canvas.drawRect(Rect.fromLTWH(tx - tw / 2, t1, tw, 1.5), goldPaint);
    pointed(tx - tw * 0.30, t1 + h * 0.012, tw * 0.2, h * 0.032, winPaint);
    pointed(tx + tw * 0.10, t1 + h * 0.012, tw * 0.2, h * 0.032, winPaint);

    final double ow = tw * 0.74;
    final double t2 = t1 - h * 0.04;
    canvas.drawRect(Rect.fromLTRB(tx - ow / 2, t2, tx + ow / 2, t1), Paint()..color = stoneAlt);
    canvas.drawRect(Rect.fromLTWH(tx - ow / 2, t2, ow, 1.5), goldPaint);
    pointed(tx - ow * 0.16, t2 + h * 0.008, ow * 0.32, h * 0.028, winPaint);
    for (final double sgn in [-1.0, 1.0]) {
      final double px = tx + sgn * ow * 0.5;
      canvas.drawPath(
        Path()
          ..moveTo(px - 2.2, t2)
          ..lineTo(px, t2 - h * 0.022)
          ..lineTo(px + 2.2, t2)
          ..close(),
        Paint()..color = stone,
      );
    }

    // Flèche gothique élancée : silhouette fine et ajourée (jamais un dôme
    // plein), avec crochets dorés le long des rampants et une croix au sommet
    // — pour rester sans équivoque une flèche d'hôtel de ville flamand.
    final double t3 = t2 - h * 0.075;
    final double spireHalf = ow * 0.22;
    final Path spire = Path()
      ..moveTo(tx - spireHalf, t2)
      ..lineTo(tx, t3)
      ..lineTo(tx + spireHalf, t2)
      ..close();
    canvas.drawPath(spire, Paint()..color = stone.withOpacity(0.55));
    canvas.drawPath(
      spire,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = stone,
    );
    canvas.drawLine(
      Offset(tx, t2),
      Offset(tx, t3),
      Paint()
        ..color = gold.withOpacity(0.5)
        ..strokeWidth = 0.8,
    );
    // Crochets (petits reliefs dorés typiques du gothique brabançon)
    for (int k = 1; k <= 3; k++) {
      final double f = k / 4;
      final double yk = t2 + (t3 - t2) * f;
      final double half = spireHalf * (1 - f);
      for (final double sgn in [-1.0, 1.0]) {
        final double cx = tx + sgn * half;
        canvas.drawPath(
          Path()
            ..moveTo(cx, yk)
            ..lineTo(cx + sgn * 2.6, yk - 1.1)
            ..lineTo(cx + sgn * 0.5, yk - 2.4)
            ..close(),
          goldPaint,
        );
      }
    }
    // Croix dorée au sommet de la flèche (statue stylisée)
    canvas.drawLine(
      Offset(tx, t3 - 8.5),
      Offset(tx, t3 + 0.5),
      Paint()
        ..color = gold
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(tx - 2.4, t3 - 5.3),
      Offset(tx + 2.4, t3 - 5.3),
      Paint()
        ..color = gold
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(tx, t3 - 8.5), 0.9, goldPaint);
  }

  // ------------------------------------------------------------------------
  //  COMMISSION EUROPÉENNE : grande façade vitrée + drapeaux européens
  // ------------------------------------------------------------------------
  void _drawCommission(Canvas canvas, Size size, double groundY, double sunP, double t) {
    final double w = size.width;
    final double h = size.height;
    final Color glassA = Color.lerp(const Color(0xFF1D2766), const Color(0xFF9CC3E8), sunP)!;
    final Color glassB = Color.lerp(const Color(0xFF141B4D), const Color(0xFF6E98C8), sunP)!;
    final Color wingL = Color.lerp(const Color(0xFF111742), const Color(0xFF5C84B4), sunP)!;
    final Color wingR = Color.lerp(const Color(0xFF181F58), const Color(0xFF7DA6D2), sunP)!;
    final double night = (1 - sunP * 1.5).clamp(0.0, 1.0);

    final double fl = w * 0.585;
    final double fw = w * 0.12;
    final double ft = groundY - h * 0.125;

    // Ailes en étoile (vues en perspective)
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.545, groundY)
        ..lineTo(w * 0.545, groundY - h * 0.082)
        ..lineTo(fl, ft)
        ..lineTo(fl, groundY)
        ..close(),
      Paint()..color = wingL,
    );
    canvas.drawPath(
      Path()
        ..moveTo(fl + fw, groundY)
        ..lineTo(fl + fw, ft)
        ..lineTo(w * 0.745, groundY - h * 0.082)
        ..lineTo(w * 0.745, groundY)
        ..close(),
      Paint()..color = wingR,
    );

    // Corps central vitré
    final Rect body = Rect.fromLTWH(fl, ft, fw, groundY - ft);
    canvas.drawRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glassA, glassB],
        ).createShader(body),
    );
    final Paint grid = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..strokeWidth = 0.8;
    for (double gx = fl + 6; gx < fl + fw; gx += 7) {
      canvas.drawLine(Offset(gx, ft), Offset(gx, groundY), grid);
    }
    final double rowH = h * 0.012;
    int row = 0;
    for (double gy = ft + rowH; gy < groundY - h * 0.012; gy += rowH) {
      canvas.drawLine(Offset(fl, gy), Offset(fl + fw, gy), grid);
      row++;
      // bureaux allumés
      for (int c = 0; c < 6; c++) {
        if (sin(row * 7.3 + c * 3.1) > 0.15) {
          canvas.drawRect(
            Rect.fromLTWH(fl + 4 + c * fw / 6.2, gy - rowH + 2, fw / 6.2 - 3, rowH - 3),
            Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.55 * night),
          );
        }
      }
    }
    // Reflet du soleil sur le verre
    canvas.drawRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.0 + 2.0 * sunP, -1),
          end: Alignment(-0.4 + 2.0 * sunP, 1),
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.20 * sunP),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(body),
    );
    // Pilotis
    canvas.drawRect(
      Rect.fromLTWH(fl, groundY - h * 0.012, fw, h * 0.012),
      Paint()..color = const Color(0xFF0C0B22),
    );
    for (double px = fl + 4; px < fl + fw; px += 14) {
      canvas.drawRect(
        Rect.fromLTWH(px, groundY - h * 0.012, 3, h * 0.012),
        Paint()..color = Colors.white.withOpacity(0.25),
      );
    }

    // Drapeaux européens (étoiles dorées en cercle sur fond bleu)
    for (int i = 0; i < 3; i++) {
      final double px = w * (0.60 + 0.04 * i);
      final double poleTop = groundY - h * 0.055;
      canvas.drawLine(
        Offset(px, groundY),
        Offset(px, poleTop),
        Paint()
          ..color = const Color(0xFFB8BCD0)
          ..strokeWidth = 1.3,
      );
      final double wave = sin(t * 2 * pi * 10 + i * 1.7) * 1.6;
      final Path flag = Path()
        ..moveTo(px, poleTop)
        ..lineTo(px + 15, poleTop + wave)
        ..lineTo(px + 15, poleTop + 10 + wave)
        ..lineTo(px, poleTop + 10)
        ..close();
      canvas.drawPath(flag, Paint()..color = const Color(0xFF1740B8));
      final Offset fc = Offset(px + 7.5, poleTop + 5 + wave * 0.5);
      for (int k = 0; k < 12; k++) {
        final double a = k * 2 * pi / 12;
        canvas.drawCircle(
          fc + Offset(cos(a), sin(a)) * 3.2,
          0.7,
          Paint()..color = const Color(0xFFFFD200),
        );
      }
    }
  }

  // ------------------------------------------------------------------------
  //  PARLEMENT EUROPÉEN : hémicycle de verre + tour inclinée
  // ------------------------------------------------------------------------
  void _drawParliament(Canvas canvas, Size size, double groundY, double sunP) {
    final double w = size.width;
    final double h = size.height;
    final Color glass = Color.lerp(const Color(0xFF1B2C5E), const Color(0xFFA9D2EA), sunP)!;
    final Color glassDark = Color.lerp(const Color(0xFF111C44), const Color(0xFF7FB0CE), sunP)!;
    final double night = (1 - sunP * 1.5).clamp(0.0, 1.0);

    // Socle
    canvas.drawRect(
      Rect.fromLTRB(w * 0.755, groundY - h * 0.03, w * 0.995, groundY),
      Paint()..color = glassDark,
    );

    // Hémicycle : long toit de verre courbe et bas
    final double cx = w * 0.835;
    final double baseY = groundY - h * 0.03;
    final double ew = w * 0.17;
    final double eh = h * 0.045;
    final Path roof = Path()
      ..moveTo(cx - ew / 2, baseY)
      ..quadraticBezierTo(cx, baseY - eh * 2, cx + ew / 2, baseY)
      ..close();
    final Rect roofRect = Rect.fromLTWH(cx - ew / 2, baseY - eh, ew, eh);
    canvas.drawPath(
      roof,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass, glassDark],
        ).createShader(roofRect),
    );
    final Paint rib = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 0.9;
    for (int k = -4; k <= 4; k++) {
      final double u = k / 4.5;
      canvas.drawLine(
        Offset(cx + u * ew / 2, baseY),
        Offset(cx + u * ew / 2, baseY - eh * (1 - u * u)),
        rib,
      );
    }
    canvas.drawPath(
      roof,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.18 + 0.3 * sunP),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - ew * 0.35, baseY - eh * 0.4, ew * 0.7, eh * 0.14),
      Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.5 * night),
    );

    // Tour à sommet incliné
    final double tx = w * 0.925;
    final double tw = w * 0.06;
    final double th = h * 0.22;
    final Rect tower = Rect.fromLTWH(tx, groundY - th, tw, th);
    canvas.drawPath(
      Path()
        ..moveTo(tx, groundY)
        ..lineTo(tx, groundY - th)
        ..lineTo(tx + tw, groundY - th * 0.84)
        ..lineTo(tx + tw, groundY)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [glass, glassDark],
        ).createShader(tower),
    );
    final Paint stripe = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..strokeWidth = 0.9;
    for (int k = 1; k < 6; k++) {
      final double sx = tx + tw * k / 6;
      canvas.drawLine(Offset(sx, groundY), Offset(sx, groundY - th * (1 - 0.16 * k / 6)), stripe);
    }
    for (int r = 1; r < 14; r++) {
      final double ry = groundY - th * r / 14;
      canvas.drawLine(Offset(tx, ry), Offset(tx + tw, ry), stripe);
      if (r % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(tx + tw * 0.15, ry + 2, tw * 0.7, th / 14 - 4),
          Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.35 * night),
        );
      }
    }
  }

  // ------------------------------------------------------------------------
  //  RUE (pavés + lampadaires)
  // ------------------------------------------------------------------------
  void _drawStreet(
      Canvas canvas,
      Size size,
      double groundY,
      double bottom,
      double sunP,
      double t,
      ) {
    final double w = size.width;
    final double h = size.height;
    final Rect rect = Rect.fromLTRB(0, groundY, w, bottom);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF1B1838), const Color(0xFF8C7A82), sunP)!,
            Color.lerp(const Color(0xFF0F0E26), const Color(0xFF5E5068), sunP)!,
          ],
        ).createShader(rect),
    );

    // Pavés
    final Paint cobble = Paint()..color = Colors.white.withOpacity(0.07);
    const int rows = 4;
    for (int r = 1; r <= rows; r++) {
      final double y = groundY + (bottom - groundY) * r / (rows + 1);
      canvas.drawLine(Offset(0, y), Offset(w, y), cobble..strokeWidth = 0.8);
      for (double x = (r.isEven ? 6.0 : 0.0); x < w; x += 12) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + (bottom - groundY) / (rows + 1)),
          cobble,
        );
      }
    }

    // Lampadaires (s'éteignent avec le jour)
    final double night = (1 - sunP * 1.5).clamp(0.0, 1.0);
    for (final double fx in [0.06, 0.20, 0.52, 0.80, 0.97]) {
      final double x = w * fx;
      final double top = bottom - h * 0.075;
      canvas.drawLine(
        Offset(x, bottom - 2),
        Offset(x, top),
        Paint()
          ..color = const Color(0xFF0C0B1E)
          ..strokeWidth = 1.8,
      );
      final Offset lc = Offset(x, top - 2);
      canvas.drawCircle(
        lc,
        16,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFE6A8).withOpacity(0.4 * night),
              const Color(0xFFFFE6A8).withOpacity(0.0),
            ],
          ).createShader(Rect.fromCircle(center: lc, radius: 16)),
      );
      canvas.drawCircle(lc, 2.4, Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.35 + 0.65 * night));
    }
  }

  // ------------------------------------------------------------------------
  //  MANNEKEN-PIS : statue sur sa fontaine, jet d'eau animé
  // ------------------------------------------------------------------------
  void _drawMannekenPis(Canvas canvas, Size size, double streetBottom, double sunP, double t) {
    final double w = size.width;
    final double h = size.height;
    final double mx = w * 0.34;
    final double baseY = streetBottom - h * 0.006;
    final Color stone = Color.lerp(const Color(0xFF2A2548), const Color(0xFFB7A8A0), sunP)!;
    final Color stoneDark = Color.lerp(const Color(0xFF1A1736), const Color(0xFF8D7F7C), sunP)!;
    final Color bronze = Color.lerp(const Color(0xFF2E2540), const Color(0xFF9A7545), sunP)!;
    final Color water = Color.lerp(const Color(0xFF3A4C8A), const Color(0xFF9EDBF5), sunP)!;

    // Vasque
    final Rect basin = Rect.fromCenter(center: Offset(mx, baseY), width: w * 0.17, height: h * 0.024);
    canvas.drawOval(basin, Paint()..color = stoneDark);
    final Rect pool = Rect.fromCenter(center: Offset(mx, baseY - 1), width: w * 0.15, height: h * 0.018);
    canvas.drawOval(pool, Paint()..color = water.withOpacity(0.85));
    for (int k = 0; k < 2; k++) {
      final double rp = ((t * 12 + k * 0.5) % 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mx + w * 0.045, baseY - 1),
          width: w * 0.05 * rp,
          height: h * 0.008 * rp,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withOpacity(0.5 * (1 - rp)),
      );
    }

    // Piédestal
    final double pedH = h * 0.038;
    final double pedTop = baseY - pedH;
    canvas.drawRect(Rect.fromLTRB(mx - w * 0.022, pedTop, mx + w * 0.022, baseY), Paint()..color = stone);
    canvas.drawRect(
      Rect.fromLTRB(mx - w * 0.028, pedTop - 3, mx + w * 0.028, pedTop),
      Paint()..color = stoneDark,
    );
    canvas.drawRect(
      Rect.fromLTRB(mx - w * 0.012, pedTop + pedH * 0.35, mx + w * 0.012, baseY - 3),
      Paint()..color = stoneDark.withOpacity(0.7),
    );

    // Le petit bonhomme
    final double bh = h * 0.05;
    final double feetY = pedTop - 3;
    final Paint b = Paint()..color = bronze;
    final Paint limb = Paint()
      ..color = bronze
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(mx, feetY - bh * 0.88), bh * 0.13, b);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(mx - bh * 0.11, feetY - bh * 0.76, mx + bh * 0.11, feetY - bh * 0.34),
        const Radius.circular(3),
      ),
      b,
    );
    canvas.drawLine(Offset(mx - bh * 0.05, feetY - bh * 0.34), Offset(mx - bh * 0.07, feetY), limb);
    canvas.drawLine(Offset(mx + bh * 0.05, feetY - bh * 0.34), Offset(mx + bh * 0.09, feetY), limb);
    canvas.drawLine(Offset(mx - bh * 0.1, feetY - bh * 0.7), Offset(mx - bh * 0.24, feetY - bh * 0.55), limb);
    canvas.drawLine(Offset(mx + bh * 0.1, feetY - bh * 0.7), Offset(mx + bh * 0.2, feetY - bh * 0.46), limb);

    // Jet d'eau
    final Offset p0 = Offset(mx + bh * 0.1, feetY - bh * 0.36);
    final double dx = w * 0.045;
    final double dropY = (baseY - 2) - p0.dy;
    final Path stream = Path()..moveTo(p0.dx, p0.dy);
    for (int i = 1; i <= 16; i++) {
      final double u = i / 16;
      stream.lineTo(
        p0.dx + dx * u,
        p0.dy - bh * 0.08 * 4 * u * (1 - u) + dropY * u * u,
      );
    }
    canvas.drawPath(
      stream,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withOpacity(0.3),
    );
    for (int i = 0; i < 10; i++) {
      final double u = ((t * 24) + i / 10) % 1.0;
      canvas.drawCircle(
        Offset(
          p0.dx + dx * u,
          p0.dy - bh * 0.08 * 4 * u * (1 - u) + dropY * u * u,
        ),
        1.2,
        Paint()..color = Colors.white.withOpacity(0.85),
      );
    }
  }

  // ------------------------------------------------------------------------
  //  TUNNEL SOUS BRUXELLES : deux voies, vrais rails, un train dans chaque sens
  // ------------------------------------------------------------------------
  void _drawTunnel(Canvas canvas, Size size, double top, double t, double sunP) {
    final double w = size.width;
    final double h = size.height;
    final double bandH = h - top;
    final Rect band = Rect.fromLTWH(0, top, w, bandH);

    canvas.drawRect(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1830), Color(0xFF0A0A18)],
        ).createShader(band),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top, w, 2.5),
      Paint()..color = Color.lerp(const Color(0xFF3A3560), const Color(0xFFB98C7A), sunP)!,
    );

    final double laneH = (bandH - 6) / 2;

    // Voie 1 : gauche -> droite
    _drawLane(canvas, size, top + 3, laneH, 1, (t * 5) % 1.0, t);
    canvas.drawRect(Rect.fromLTWH(0, top + 3 + laneH, w, 3), Paint()..color = const Color(0xFF2A2646));
    // Voie 2 : droite -> gauche
    _drawLane(canvas, size, top + 6 + laneH, laneH, -1, (t * 5 + 0.5) % 1.0, t);

    // Profondeur (vignettage latéral)
    final double vw = w * 0.14;
    canvas.drawRect(
      Rect.fromLTWH(0, top, vw, bandH),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.black.withOpacity(0.65), Colors.black.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, top, vw, bandH)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w - vw, top, vw, bandH),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.65)],
        ).createShader(Rect.fromLTWH(w - vw, top, vw, bandH)),
    );
  }

  void _drawLane(
      Canvas canvas,
      Size size,
      double laneTop,
      double laneH,
      int dir,
      double u,
      double t,
      ) {
    final double w = size.width;
    final Rect laneRect = Rect.fromLTWH(0, laneTop, w, laneH);

    canvas.save();
    canvas.clipRect(laneRect);
    if (dir < 0) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    final double railB = laneTop + laneH * 0.92; // rail avant
    final double gap = laneH * 0.15;
    final double railF = railB - gap; // rail arrière
    final double wireY = laneTop + laneH * 0.16; // caténaire

    // Paroi du tunnel
    canvas.drawRect(
      laneRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12102A), Color(0xFF1E1A3A)],
        ).createShader(laneRect),
    );

    // Piliers
    final Paint pillar = Paint()..color = const Color(0xFF0C0B1E);
    final Paint pillarEdge = Paint()..color = const Color(0xFF2C2850);
    for (double px = 20; px < w; px += 96) {
      canvas.drawRect(Rect.fromLTWH(px, laneTop, 7, laneH * 0.9), pillar);
      canvas.drawRect(Rect.fromLTWH(px, laneTop, 1, laneH * 0.9), pillarEdge);
    }

    // Luminaires de plafond
    final Paint lamp = Paint()..color = const Color(0xFFFFE9B0);
    for (double lx = 10; lx < w; lx += 48) {
      final Offset gc = Offset(lx + 8, laneTop + 4);
      canvas.drawCircle(
        gc,
        24,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFE9B0).withOpacity(0.28),
              const Color(0xFFFFE9B0).withOpacity(0.0),
            ],
          ).createShader(Rect.fromCircle(center: gc, radius: 24)),
      );
      canvas.drawRect(Rect.fromLTWH(lx, laneTop + 3, 16, 2.5), lamp);
    }

    // Fil de contact
    canvas.drawLine(
      Offset(0, wireY),
      Offset(w, wireY),
      Paint()
        ..color = const Color(0xFF6A6890)
        ..strokeWidth = 1,
    );

    // Ballast
    canvas.drawRect(
      Rect.fromLTRB(0, railF - 1, w, laneTop + laneH),
      Paint()..color = const Color(0xFF262236),
    );
    final Random gr = Random(5);
    final Paint dot = Paint()..color = const Color(0xFF4A4562);
    for (int i = 0; i < 46; i++) {
      final double gx = gr.nextDouble() * w;
      final double gy = railB + 4 + gr.nextDouble() * max(0.0, laneTop + laneH - railB - 4);
      canvas.drawCircle(Offset(gx, gy), 0.9, dot);
    }

    // Traverses
    final Paint sleeper = Paint()..color = const Color(0xFF3C3550);
    final Paint sleeperTop = Paint()..color = const Color(0xFF4D456A);
    for (double sx = 4; sx < w; sx += 15) {
      canvas.drawRect(Rect.fromLTRB(sx, railF - 2, sx + 6, railB + 3), sleeper);
      canvas.drawRect(Rect.fromLTRB(sx, railF - 2, sx + 6, railF - 0.5), sleeperTop);
    }

    // Rail arrière
    canvas.drawLine(
      Offset(0, railF),
      Offset(w, railF),
      Paint()
        ..color = const Color(0xFF8A8FA8)
        ..strokeWidth = 1.6,
    );

    // ---- Rame (4 voitures) ----
    final double cw = w * 0.27;
    const double carGap = 3;
    const int cars = 4;
    final double trainLen = cars * cw + (cars - 1) * carGap;
    final double head = u * (w + trainLen);
    final double trainH = laneH * 0.58;
    final double trainBottom = railB - gap * 0.35;
    final double trainTop = trainBottom - trainH;

    // Faisceau des phares
    final double bx = head;
    final double by = trainBottom - trainH * 0.25;
    final Rect beamRect = Rect.fromLTWH(bx, by - laneH * 0.30, w * 0.55, laneH * 0.5);
    canvas.drawPath(
      Path()
        ..moveTo(bx, by - 2)
        ..lineTo(bx + w * 0.55, by - laneH * 0.30)
        ..lineTo(bx + w * 0.55, by + laneH * 0.20)
        ..lineTo(bx, by + 2)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withOpacity(0.28), Colors.white.withOpacity(0.0)],
        ).createShader(beamRect),
    );

    for (int c = 0; c < cars; c++) {
      final double xr = head - c * (cw + carGap);
      final double xl = xr - cw;
      if (xr < -10 || xl > w + 10) continue;
      _drawCar(
        canvas,
        xl,
        trainTop,
        cw,
        trainH,
        c == 0,
        c == cars - 1,
        c == 1 || c == 2,
        wireY,
        t,
      );
    }

    // Rail avant + reflet métallique
    canvas.drawLine(
      Offset(0, railB),
      Offset(w, railB),
      Paint()
        ..color = const Color(0xFFB5BAD0)
        ..strokeWidth = 2.4,
    );
    canvas.drawLine(
      Offset(0, railB - 1),
      Offset(w, railB - 1),
      Paint()
        ..color = const Color(0xFFE4E7F5)
        ..strokeWidth = 0.8,
    );
    canvas.drawLine(
      Offset(0, railB + 1.6),
      Offset(w, railB + 1.6),
      Paint()
        ..color = const Color(0xFF55506E)
        ..strokeWidth = 1.2,
    );

    canvas.restore();
  }

  void _drawCar(
      Canvas canvas,
      double x,
      double y,
      double cw,
      double ch,
      bool front,
      bool tail,
      bool panto,
      double wireY,
      double t,
      ) {
    // Caisse
    final RRect body = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, y, cw, ch),
      topLeft: Radius.circular(tail ? 5 : 3),
      topRight: Radius.circular(front ? ch * 0.45 : 3),
      bottomLeft: Radius.circular(tail ? 3 : 2),
      bottomRight: Radius.circular(front ? 6 : 2),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF2F7), Color(0xFFC3CBD6), Color(0xFF9AA4B2)],
          stops: [0.0, 0.6, 1.0],
        ).createShader(body.outerRect),
    );

    // Toit + bandeau bleu
    canvas.drawRect(Rect.fromLTWH(x + 2, y, cw - 4, ch * 0.07), Paint()..color = const Color(0xFF5B6575));
    canvas.drawRect(Rect.fromLTWH(x, y + ch * 0.70, cw, ch * 0.12), Paint()..color = const Color(0xFF0B3C91));

    // Portes
    final Paint door = Paint()..color = const Color(0xFF7D8896);
    final Paint doorGlass = Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.9);
    for (final double f in [0.27, 0.66]) {
      canvas.drawRect(Rect.fromLTWH(x + cw * f, y + ch * 0.12, cw * 0.08, ch * 0.74), door);
      canvas.drawRect(Rect.fromLTWH(x + cw * f + cw * 0.012, y + ch * 0.17, cw * 0.056, ch * 0.5), doorGlass);
    }

    // Fenêtres
    final Paint win = Paint()..color = const Color(0xFFFFE6A8).withOpacity(0.95);
    for (final double f in [0.04, 0.13, 0.37, 0.46, 0.55, 0.76, 0.85]) {
      canvas.drawRect(Rect.fromLTWH(x + cw * f, y + ch * 0.18, cw * 0.08, ch * 0.34), win);
    }

    // Bogies et roues
    final Paint bogie = Paint()..color = const Color(0xFF1E1C2C);
    for (final double f in [0.08, 0.76]) {
      final double bx = x + cw * f;
      canvas.drawRect(Rect.fromLTWH(bx, y + ch - 1, cw * 0.16, ch * 0.08), bogie);
      for (final double wf in [0.03, 0.13]) {
        canvas.drawCircle(Offset(bx + cw * wf, y + ch + ch * 0.02), ch * 0.07, bogie);
        canvas.drawCircle(
          Offset(bx + cw * wf, y + ch + ch * 0.02),
          ch * 0.03,
          Paint()..color = const Color(0xFF6B6784),
        );
      }
    }

    // Pantographe + étincelles
    if (panto) {
      final double px = x + cw * 0.5;
      final Paint pg = Paint()
        ..color = const Color(0xFF3A3750)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(px - 8, y), Offset(px, (y + wireY) / 2 + 1), pg);
      canvas.drawLine(Offset(px + 8, y), Offset(px, (y + wireY) / 2 + 1), pg);
      canvas.drawLine(Offset(px, (y + wireY) / 2 + 1), Offset(px, wireY + 1), pg);
      canvas.drawLine(Offset(px - 10, wireY + 1), Offset(px + 10, wireY + 1), pg);
      if (sin(t * 2 * pi * 60 + x * 0.1) > 0.9) {
        canvas.drawCircle(Offset(px + 4, wireY), 1.6, Paint()..color = const Color(0xFFFFF1A8));
        canvas.drawCircle(Offset(px - 3, wireY - 1), 1.0, Paint()..color = Colors.white);
      }
    }

    // Avant : pare-brise + phares / Arrière : feu rouge
    if (front) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + cw - ch * 0.46, y + ch * 0.14, ch * 0.4, ch * 0.38),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF1B2540),
      );
      final Offset hl = Offset(x + cw - 3, y + ch * 0.78);
      canvas.drawCircle(
        hl,
        14,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: hl, radius: 14)),
      );
      canvas.drawCircle(hl, 2.4, Paint()..color = Colors.white);
    }
    if (tail) {
      canvas.drawCircle(
        Offset(x + 3, y + ch * 0.78),
        2.0,
        Paint()..color = const Color(0xFFFF3B3B),
      );
    }
  }

  void _drawBirds(Canvas canvas, Size size, double t, double sunP) {
    final double appear = ((sunP - 0.6) / 0.3).clamp(0.0, 1.0);
    if (appear <= 0) return;
    final Paint paint = Paint()
      ..color = const Color(0xFF2B2145).withOpacity(0.8 * appear)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final double x = size.width * (((t * 2.4 + i * 0.13) % 1.2) - 0.1);
      final double y = size.height * (0.30 + i * 0.035) + sin(t * 2 * pi * 3 + i) * 6;
      final double flap = sin(t * 2 * pi * 40 + i) * 2.5;
      canvas.drawPath(
        Path()
          ..moveTo(x - 6, y - flap)
          ..quadraticBezierTo(x - 3, y - 4 + flap, x, y)
          ..quadraticBezierTo(x + 3, y - 4 + flap, x + 6, y - flap),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BrusselsIntroPainter oldDelegate) => true;
}