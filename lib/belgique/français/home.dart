import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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

class _HomeState extends State<Home> {
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
      ),
      child: Scaffold(
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
                                'Retour',
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
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const FavorisFrPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
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
                                'Favoris',
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
                          'Découvrez la Belgique 🇧🇪',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Explorez un pays riche en traditions, en culture et en paysages urbains captivants, entre châteaux historiques et douceurs légendaires.',
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
                    'Les Villes Incontournables',
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
                'Planificateur de Visite',
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
            'Quand visiter la Belgique ? 🗓️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Obtenez les meilleures périodes de visite par ville (hors vacances scolaires, en semaine à visiter, pour éviter les week-ends trop chargés).',
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
              'Lancer le Générateur',
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
                'Indécis sur la destination ?',
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
            'La Roulette des Villes 🎲',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Laissez le hasard choisir votre prochaine ville belge en un seul clic !',
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
              'Tourner la Roulette',
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
                            'Découvrir',
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

// --- DIALOGUE DE LA ROULETTE (PAGE PRINCIPALE) ---
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
                'Roulette des Villes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _isFinished ? '✨ Ville gagnante trouvée !' : 'Tirage au sort en cours...',
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
                          'Découvrir cette ville',
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
                          'Tirer une autre ville',
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
                  'Générateur de Visite 🇧🇪',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Sélectionnez une ville pour obtenir des conseils adaptés.',
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
                          'Rappel Météo Important 🌧️',
                          style: TextStyle(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Même si la période est recommandée, vérifiez toujours la météo avant de partir !',
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
              'Sélection de la ville : vous choisissez une ville',
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
                      ? 'SÉLECTIONNEZ UNE VILLE'
                      : (estEnGenerationVitesse ? 'ANALYSE EN COURS...' : 'LANCER LA GÉNÉRATION RAPIDE'),
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
                          'Analyse annuelle pour $villeOngletActif',
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
                                      estBon ? 'BON' : 'MAUVAIS',
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

// --- PAGE DES FAVORIS SANS AUCUNE ANIMATION (OUVERTURE/FERMETURE INSTANTANÉE) ---
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

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
      ),
      child: Scaffold(
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
                          Text('Retour', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  const Text('Mes Favoris', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 70),
                ],
              ),
              const SizedBox(height: 25),
              ...dossiers.map((dossierNom) {
                final List<String> quartiers = quartiersParVille[dossierNom] ?? [];
                final bool isDossierOpen = _dossiersOuverts.contains(dossierNom);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      // Entête du dossier (Bascule instantanée)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            if (isDossierOpen) {
                              _dossiersOuverts.remove(dossierNom);
                            } else {
                              _dossiersOuverts.add(dossierNom);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dossierNom,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                isDossierOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                color: isDossierOpen ? const Color(0xFFFBBF24) : Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Contenu du dossier sans animation (Instantané)
                      if (isDossierOpen)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                          child: quartiers.isNotEmpty
                              ? Column(
                            children: quartiers.map((quartierNom) {
                              final String keyQuartier = '$dossierNom-$quartierNom';
                              final bool isQuartierOpen = _quartiersOuverts.contains(keyQuartier);

                              final List<String> currentFavorisIds = dossierNom == 'Bruxelles' ? _favorisBruxellesIds
                                  : dossierNom == 'Gand' ? _favorisGandIds
                                  : dossierNom == 'Bruges' ? _favorisBrugesIds
                                  : dossierNom == 'Anvers' ? _favorisAnversIds
                                  : _favorisLiegeIds;

                              final lieuxQuartier = currentFavorisIds
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
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Column(
                                  children: [
                                    // Entête du quartier (Bascule instantanée)
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          if (isQuartierOpen) {
                                            _quartiersOuverts.remove(keyQuartier);
                                          } else {
                                            _quartiersOuverts.add(keyQuartier);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              quartierNom,
                                              style: TextStyle(
                                                color: Colors.amber.shade100,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              isQuartierOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                              color: Colors.amber.shade200,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Contenu du quartier sans animation (Instantané)
                                    if (isQuartierOpen)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: lieuxQuartier.isEmpty
                                            ? Text('Aucun favori dans cette section.', style: TextStyle(color: Colors.grey[400], fontSize: 13))
                                            : Column(
                                          children: lieuxQuartier.map((lieu) {
                                            final List<String> images = List<String>.from(lieu['images'] ?? []);
                                            return Container(
                                              margin: const EdgeInsets.only(top: 10.0),
                                              padding: const EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.04),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(child: Text(lieu['titre'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                                                      IconButton(
                                                        onPressed: () => _retirerFavori(lieu['id'], dossierNom),
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
                              );
                            }).toList(),
                          )
                              : Text('Aucun favori pour le moment.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        ),
                    ],
                  ),
                );
              }).toList(),
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