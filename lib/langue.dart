import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// Importations selon votre arborescence
import 'belgique/français/home.dart' as fr;
import 'belgique/anglais/home.dart' as en;

class LanguePage extends StatefulWidget {
  const LanguePage({super.key});

  @override
  State<LanguePage> createState() => _LanguePageState();
}

class _LanguePageState extends State<LanguePage> {
  // Contrôleur pour le carrousel qui défile
  late PageController _pageController;
  int _selectedLanguageIndex = 0;

  // Palette 100% Luxe Belge (Noir Obsidienne & Or Impérial)
  final Color _bgObsidian = const Color(0xFF040407);
  final Color _cardOnyx = const Color(0xFF0D0F18);
  final Color _goldImperial = const Color(0xFFD4AF37);
  final Color _goldChampagne = const Color(0xFFF3E5AB);
  final Color _goldLightText = const Color(0xFFE2CA82);
  final Color _goldMutedText = const Color(0xFF8A7322);

  // Cartes de langues avec titres dynamiques et casse "Première lettre seulement"
  final List<Map<String, dynamic>> _belgianLanguages = [
    {
      'code': 'FR',
      'topTitle': 'Belgique',
      'topSubtitle': 'Édition haute joaillerie',
      'title': 'Royaume de Belgique',
      'language': 'Français',
      'objectName': 'Chocolat & praline royale',
      'objectSubtitle': 'Savoir-faire des maîtres chocolatiers',
      'icon': Icons.workspace_premium_rounded,
      'description':
      'Explorez la Belgique au-delà des classiques : les canaux romantiques de Bruges, la dynamique Bruxelles, et le riche patrimoine d\'Anvers et de Gand.',
      'buttonText': 'Entrer dans le royaume',
    },
    {
      'code': 'EN',
      'topTitle': 'Belgium',
      'topSubtitle': 'High jewelry edition',
      'title': 'Kingdom of Belgium',
      'language': 'English',
      'objectName': 'Le diamant d\'Anvers',
      'objectSubtitle': 'Capitale mondiale de la joaillerie',
      'icon': Icons.diamond_outlined,
      'description':
      'Explore Belgium beyond the classics: the romantic canals of Bruges, vibrant Brussels, and the rich heritage of Antwerp and Ghent.',
      'buttonText': 'Discover the kingdom',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _naviguerVersHome() {
    Widget pageDestination;

    if (_selectedLanguageIndex == 1) {
      pageDestination = const en.HomeEnglish();
    } else {
      pageDestination = const fr.Home();
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

  @override
  Widget build(BuildContext context) {
    final currentLanguageData = _belgianLanguages[_selectedLanguageIndex];

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
          body: Stack(
            children: [
              // Halo de lumière dorée en arrière-plan
              Positioned(
                top: -100,
                left: MediaQuery.of(context).size.width / 2 - 150,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _goldImperial.withOpacity(0.09),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    // Emblème Supérieur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 35,
                          height: 1,
                          color: _goldImperial.withOpacity(0.3),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(
                            Icons.star_rate_rounded,
                            color: _goldImperial,
                            size: 22,
                          ),
                        ),
                        Container(
                          width: 35,
                          height: 1,
                          color: _goldImperial.withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Titre Général du Haut (Dynamique selon la langue & Première lettre majuscule)
                    Text(
                      currentLanguageData['topTitle'],
                      style: GoogleFonts.cinzel(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _goldImperial,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentLanguageData['topSubtitle'],
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _goldMutedText,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ruban Drapeau Belge discret
                    Container(
                      height: 4,
                      width: 90,
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

                    const SizedBox(height: 25),

                    // Indicateur de sélection (Puces dorées)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _belgianLanguages.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _selectedLanguageIndex == index ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: _selectedLanguageIndex == index
                                ? _goldImperial
                                : _goldMutedText.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // CARROUSEL DE DÉFILEMENT DES LANGUES & OBJETS BELGES
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedLanguageIndex = index;
                          });
                        },
                        itemCount: _belgianLanguages.length,
                        itemBuilder: (context, index) {
                          final item = _belgianLanguages[index];
                          final isSelected = (_selectedLanguageIndex == index);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: _cardOnyx,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isSelected
                                    ? _goldImperial.withOpacity(0.6)
                                    : _goldMutedText.withOpacity(0.2),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Badge supérieur FR, EN
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _goldImperial.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: _goldImperial.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      item['code'],
                                      style: GoogleFonts.montserrat(
                                        color: _goldChampagne,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // Médaillon de l'objet Belge
                                Column(
                                  children: [
                                    Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF1E2235),
                                            _bgObsidian,
                                          ],
                                        ),
                                        border: Border.all(
                                          color: _goldImperial.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _goldImperial.withOpacity(0.15),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        item['icon'] as IconData,
                                        color: _goldChampagne,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item['objectName'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cinzel(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _goldChampagne,
                                      ),
                                    ),
                                    Text(
                                      item['objectSubtitle'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: _goldMutedText,
                                      ),
                                    ),
                                  ],
                                ),

                                // Nom de la Langue & Description
                                Column(
                                  children: [
                                    Text(
                                      item['language'],
                                      style: GoogleFonts.cinzel(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: _goldImperial,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['description'],
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: _goldLightText,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Bouton de Validation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF8ECB8),
                                _goldImperial,
                                const Color(0xFF9E7A1C),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _goldImperial.withOpacity(0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _naviguerVersHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentLanguageData['buttonText'],
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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