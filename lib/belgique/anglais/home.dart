import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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

class _HomeState extends State<HomeEnglish> {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _GenerateurWidget(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _lancerRoulettePrincipale(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _RouletteDialog(villes: villes, parentContext: context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070913),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FavorisEnPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFBBF24)),
                            SizedBox(width: 6),
                            Text(
                              'Favorites',
                              style: TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E293B).withOpacity(0.9),
                        const Color(0xFF0F172A).withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                                SizedBox(width: 6),
                                Text(
                                  'Destination',
                                  style: TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Discover Belgium 🇧🇪',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explore a country rich in traditions, culture, and captivating urban landscapes, between historical castles and legendary sweets.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                _buildGenerateurIntroCard(context),

                const SizedBox(height: 16),

                _buildRouletteMainCard(context),

                const SizedBox(height: 30),

                const Text(
                  'Must-See Cities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                ...villes.map((ville) => _buildVilleCard(
                  context,
                  nom: ville['nom']!,
                  image: ville['image']!,
                  description: ville['description']!,
                )),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateurIntroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.2),
            const Color(0xFF1E1B4B).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF60A5FA), size: 22),
              SizedBox(width: 8),
              Text(
                'Visit Planner',
                style: TextStyle(
                  color: Color(0xFF60A5FA),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'When to visit Belgium ? 🗓️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get the best visiting periods per city (avoiding school holidays, preferring weekdays to avoid crowded weekends).',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[300],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _afficherGenerateur(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            icon: const Icon(Icons.flash_on_rounded, size: 16),
            label: const Text(
              'Launch Planner',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouletteMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.2),
            const Color(0xFF1E1B4B).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.casino_rounded, color: Color(0xFFA78BFA), size: 22),
              SizedBox(width: 8),
              Text(
                'Indecisive on destination ?',
                style: TextStyle(
                  color: Color(0xFFA78BFA),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'City Roulette 🎲',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Let chance choose your next Belgian city in a single click !',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[300],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _lancerRoulettePrincipale(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text(
              'Spin Roulette',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVilleCard(
      BuildContext context, {
        required String nom,
        required String image,
        required String description,
      }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _navigateToCityPage(context, nom);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[850],
                    child: const Icon(Icons.location_city, color: Colors.white54),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Discover',
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: Color(0xFFFBBF24),
                          ),
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
    );
  }
}

// --- ROULETTE DIALOG ---
class _RouletteDialog extends StatefulWidget {
  final List<Map<String, String>> villes;
  final BuildContext parentContext;

  const _RouletteDialog({required this.villes, required this.parentContext});

  @override
  State<_RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<_RouletteDialog> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isFinished = false;
  String _selectedVille = '';

  @override
  void initState() {
    super.initState();
    _lancerAnimation();
  }

  void _lancerAnimation() {
    final random = Random();
    int steps = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex = random.nextInt(widget.villes.length);
        steps++;
      });

      if (steps >= 20) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isFinished = true;
            _selectedVille = widget.villes[_currentIndex]['nom']!;
          });
        }
      }
    });
  }

  void _relancerRoulette() {
    _timer?.cancel();
    setState(() {
      _isFinished = false;
      _selectedVille = '';
    });
    _lancerAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    final currentVille = widget.villes[_currentIndex];

    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.casino_rounded, color: Color(0xFF8B5CF6), size: 42),
              const SizedBox(height: 14),
              const Text(
                'City Roulette',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _isFinished ? '✨ Winning city found !' : 'Drawing in progress...',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        currentVille['image']!,
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 130,
                            height: 130,
                            color: Colors.grey[850],
                            child: const Icon(Icons.location_city, color: Colors.white54, size: 40),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentVille['nom']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (_isFinished)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: _naviguerVersVilleSelectionnee,
                        child: const Text(
                          'Discover this city',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _relancerRoulette,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text(
                          'Draw another city',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(
                  height: 24,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            right: -10,
            top: -10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- GENERATOR WIDGET ---
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

      if (compteurVitesse >= 20) {
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

  @override
  Widget build(BuildContext context) {
    final listeMois = _getMoisPourVille(villeOngletActif);

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.bolt_rounded, color: Color(0xFF60A5FA), size: 26),
                SizedBox(width: 8),
                Text(
                  'Visit Planner 🇧🇪',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a city to get tailored advice.',
              style: TextStyle(color: Colors.white70, fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.3),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloudy_snowing, color: Color(0xFFFBBF24), size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Important Weather Reminder 🌧️',
                          style: TextStyle(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Even if a period is recommended, always check the weather forecast before leaving !',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'City Selection : Choose a city',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: toutesLesVilles.map((ville) {
                final isSelected = (villeSelectionnee == ville);
                return FilterChip(
                  label: Text(
                    ville,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFBBF24),
                  backgroundColor: const Color(0xFF1E293B),
                  checkmarkColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFFBBF24) : Colors.white24,
                    ),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (isSelected) {
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
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (estEnGenerationVitesse || villeSelectionnee == null)
                    ? null
                    : _lancerGenerationHauteVitesse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  disabledBackgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white30,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: estEnGenerationVitesse
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.flash_on_rounded, size: 20),
                label: Text(
                  villeSelectionnee == null
                      ? 'SELECT A CITY'
                      : (estEnGenerationVitesse ? 'ANALYSIS IN PROGRESS...' : 'START FAST GENERATION'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (estEnGenerationVitesse)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.speed_rounded, size: 50, color: Color(0xFF60A5FA)),
                      const SizedBox(height: 14),
                      Text(
                        affichageVitesseTexte,
                        style: const TextStyle(
                          color: Color(0xFF60A5FA),
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (estGenere && villeSelectionnee != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_city_rounded, color: Color(0xFFFBBF24), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Annual analysis for $villeOngletActif',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...listeMois.map((m) {
                    final bool estBon = m['estBon'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: estBon
                            ? const Color(0xFF10B981).withOpacity(0.08)
                            : const Color(0xFFEF4444).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: estBon
                              ? const Color(0xFF10B981).withOpacity(0.25)
                              : const Color(0xFFEF4444).withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    m['nom'],
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${m['saison']})',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: estBon
                                      ? const Color(0xFF10B981).withOpacity(0.2)
                                      : const Color(0xFFEF4444).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      estBon ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                      size: 13,
                                      color: estBon ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      estBon ? 'GOOD' : 'BAD',
                                      style: TextStyle(
                                        color: estBon ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            m['raison'],
                            style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ],
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
    'chateau_comtes': {
      'titre': 'The Castle of the Counts',
      'images': ['assets4/belgique/gand/1.jpeg', 'assets4/belgique/gand/2.jpg', 'assets4/belgique/gand/3.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'beffroi_gand': {
      'titre': 'The Belfry of Ghent',
      'images': ['assets4/belgique/gand/4.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'saint_bavon': {
      'titre': 'Saint Bavo\'s Cathedral',
      'images': ['assets4/belgique/gand/5.jpg', 'assets4/belgique/gand/6.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'quai_herbes_grains': {
      'titre': 'The Graslei and Korenlei',
      'images': ['assets4/belgique/gand/7.jpg'],
      'quartier': 'Ghent Highlights',
      'dossier': 'Ghent'
    },
    'pont_saint_michel': {
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
    'montagne_bueren': {
      'titre': 'The Montagne de Bueren',
      'images': ['assets4/belgique/liege/1.webp', 'assets4/belgique/liege/2.webp', 'assets4/belgique/liege/1 bis.webp'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'coteaux_citadelle': {
      'titre': 'The Citadel Hillsides',
      'images': ['assets4/belgique/liege/3.jpg', 'assets4/belgique/liege/4.jpg'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'gare_liege_guillemins': {
      'titre': 'Liege-Guillemins Station',
      'images': ['assets4/belgique/liege/5.jpg', 'assets4/belgique/liege/6.webp', 'assets4/belgique/liege/7.jpg'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'cathedrale_saint_paul': {
      'titre': 'Saint Paul\'s Cathedral',
      'images': ['assets4/belgique/liege/8.jpg'],
      'quartier': 'Liege Highlights',
      'dossier': 'Liege'
    },
    'ruelles_impasses_liege': {
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

    List<String> allFavs = [];
    final keys = [
      'favoris_en',
      'favoris_bruxelles_en',
      'favoris_brussels_en',
      'favoris_bruges_en',
      'favoris_gand_en',
      'favoris_ghent_en',
      'favoris_anvers_en',
      'favoris_antwerp_en',
      'favoris_liege_en',
    ];

    for (var key in keys) {
      final list = prefs.getStringList(key);
      if (list != null) {
        for (var id in list) {
          if (!allFavs.contains(id)) {
            allFavs.add(id);
          }
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

    final keys = [
      'favoris_en',
      'favoris_bruxelles_en',
      'favoris_brussels_en',
      'favoris_bruges_en',
      'favoris_gand_en',
      'favoris_ghent_en',
      'favoris_anvers_en',
      'favoris_antwerp_en',
      'favoris_liege_en',
    ];

    setState(() {
      _favorisIds.remove(id);
      for (var key in keys) {
        List<String>? list = prefs.getStringList(key);
        if (list != null && list.contains(id)) {
          list.remove(id);
          prefs.setStringList(key, list);
        }
      }
    });
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

    return Scaffold(
      backgroundColor: const Color(0xFF070913),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFBBF24)))
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text('Back', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const Text('My Favorites', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 70),
              ],
            ),
            const SizedBox(height: 25),
            ...dossiers.map((dossierNom) {
              final List<String> quartiers = quartiersParVille[dossierNom] ?? [];
              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    boldText: false,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(dossierNom, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      iconColor: const Color(0xFFFBBF24),
                      collapsedIconColor: Colors.white70,
                      shape: const RoundedRectangleBorder(side: BorderSide.none),
                      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                      enableFeedback: false,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                          child: quartiers.isNotEmpty
                              ? Column(
                            children: quartiers.map((quartierNom) {
                              final lieuxQuartier = _favorisIds
                                  .where((id) => _tousLesLieux.containsKey(id))
                                  .map((id) {
                                var item = Map<String, dynamic>.from(_tousLesLieux[id]!);
                                item['id'] = id;
                                return item;
                              })
                                  .where((item) => item['dossier'] == dossierNom && item['quartier'] == quartierNom)
                                  .toList();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                    title: Text(quartierNom, style: TextStyle(color: Colors.amber.shade100, fontSize: 15, fontWeight: FontWeight.bold)),
                                    iconColor: Colors.amber.shade200,
                                    collapsedIconColor: Colors.white54,
                                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                                    collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                                    enableFeedback: false,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: lieuxQuartier.isEmpty
                                            ? Text('No favorites in this section.', style: TextStyle(color: Colors.grey[400], fontSize: 13))
                                            : Column(
                                          children: lieuxQuartier.map((lieu) {
                                            final List<String> images = List<String>.from(lieu['images'] ?? []);
                                            return Container(
                                              margin: const EdgeInsets.only(top: 10.0),
                                              padding: const EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(child: Text(lieu['titre'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                                                      IconButton(
                                                        onPressed: () => _retirerFavori(lieu['id']),
                                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                                        padding: EdgeInsets.zero,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: images.map((path) => ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.asset(
                                                        path,
                                                        width: 70,
                                                        height: 70,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            width: 70,
                                                            height: 70,
                                                            color: Colors.grey[850],
                                                            child: const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 24),
                                                          );
                                                        },
                                                      ),
                                                    )).toList(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                              : Text('No favorites for now.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
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