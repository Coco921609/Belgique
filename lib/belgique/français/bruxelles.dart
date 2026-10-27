import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final List<Map<String, dynamic>> _quartiersBruxelles = [
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
          'conseil': 'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
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
          'conseil': 'Idéal en automne et printemps pour profiter des magnifiques couleurs. Vérifier la météo avant de partir.',
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
          'conseil': 'À voir absolument de jour comme de nuit. Vérifier la météo avant de partir.',
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
          'Situés à proximité immédiate de la Grand-Place, Manneken-Pis est une petite fontaine en bronze représentant un petit garçon urinant, symbole de l\'esprit indépendant, frondeur et humoristique des Bruxellois (plusieurs fois habillé de costumes traditionnels). Jeanneke-Pis, sa pendant féminine située dans une allée voisine (l\'impasse de la Fidélité), a été créée plus tard en 1987 pour promouvoir le folklore local et soutenir des œuvres caritatives.',
          'conseil': 'Prévoir un passage rapide dans les ruelles piétonnes. Vérifier la météo avant de partir.',
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
          'conseil': 'Goûter les chocolats artisanaux sur place. Vérifier la météo avant de partir.',
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
          'conseil': 'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
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
          'conseil': 'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
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

  @override
  void initState() {
    super.initState();
    _chargerDonneesVoyage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets4/belgique/bruxelles/30.jpg'), context);
      for (var quartier in _quartiersBruxelles) {
        for (var lieu in quartier['lieux']) {
          for (String imgPath in lieu['images']) {
            precacheImage(AssetImage(imgPath), context);
          }
        }
      }
    }
  }

  Future<void> _chargerDonneesVoyage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisFr = prefs.getStringList('favoris_bruxelles_fr') ?? [];
      _lieuxVisites = prefs.getStringList('lieux_visites_bruxelles_fr') ?? [];
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
      prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
    });
  }

  Future<void> _toutAjouterFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersBruxelles) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _favorisFr = tousLesLieux;
      prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
    });
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisFr.clear();
      prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
    });
  }

  Future<void> _basculerVisite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_lieuxVisites.contains(id)) {
        _lieuxVisites.remove(id);
      } else {
        _lieuxVisites.add(id);
      }
      prefs.setStringList('lieux_visites_bruxelles_fr', _lieuxVisites);
    });
  }

  Future<void> _toutMarquerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersBruxelles) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _lieuxVisites = tousLesLieux;
      prefs.setStringList('lieux_visites_bruxelles_fr', _lieuxVisites);
    });
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisites.clear();
      prefs.setStringList('lieux_visites_bruxelles_fr', _lieuxVisites);
    });
  }

  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _ouvrirGaleriePleinEcran(BuildContext context, List<String> images, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  maxScale: 5.0,
                  child: Center(
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 60,
              right: 24,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(String imagePath, List<String> allImages, int index) {
    return GestureDetector(
      onTap: () => _ouvrirGaleriePleinEcran(context, allImages, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgObsidian = Color(0xFF0A0A0C);
    const Color cardObsidian = Color(0xFF141418);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color textMuted = Color(0xFF94A3B8);

    int totalLieux = 0;
    for (var q in _quartiersBruxelles) {
      totalLieux += (q['lieux'] as List).length;
    }
    double progression = totalLieux > 0 ? _lieuxVisites.length / totalLieux : 0.0;

    Color couleurProgression = Colors.orangeAccent;
    if (progression > 0.3 && progression <= 0.7) {
      couleurProgression = goldAccent;
    } else if (progression > 0.7) {
      couleurProgression = Colors.greenAccent;
    }

    return Scaffold(
      backgroundColor: bgObsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardObsidian,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    const Column(
                      children: [
                        Text(
                          'Bruxelles',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Guide de voyage',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSingleImage('assets4/belgique/bruxelles/30.jpg', ['assets4/belgique/bruxelles/30.jpg'], 0),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'L\'Élégance de la Capitale',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Capitale souveraine de la Belgique et cœur névralgique et institutionnel de l\'Union européenne, Bruxelles fusionne un patrimoine architectural d\'exception, un avant-gardisme culturel et un art de vivre d\'une élégance rare.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: textMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardObsidian,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: goldAccent.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: goldAccent, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Conseils : Visiter Bruxelles en semaine, hors vacances scolaires et éviter les week-ends. Pensez à vérifier la météo avant de partir.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.amber.shade100,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const EurostarAnecdotesPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardObsidian,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goldAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.train, color: goldAccent, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anecdotes sur l\'Eurostar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Cliquez pour lire les anecdotes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: goldAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: goldAccent, size: 16),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardObsidian,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progression',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_lieuxVisites.length} / $totalLieux visités',
                            style: TextStyle(color: couleurProgression, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progression,
                          backgroundColor: bgObsidian,
                          color: couleurProgression,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _toutMarquerVisite,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: goldAccent.withOpacity(0.12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Tout marquer visité', style: TextStyle(color: goldAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextButton(
                              onPressed: _toutEffacerVisite,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: Colors.white.withOpacity(0.04),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Réinitialiser visites', style: TextStyle(color: Colors.white54, fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _toutAjouterFavoris,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: goldAccent.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Tout ajouter favoris', style: TextStyle(color: goldAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _toutRetirerFavoris,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Tout retirer favoris', style: TextStyle(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavorisBruxellesPage(),
                            ),
                          ).then((_) => _chargerDonneesVoyage());
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cardObsidian,
                          side: BorderSide(color: goldAccent.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(
                          Icons.favorite,
                          color: goldAccent,
                          size: 18,
                        ),
                        label: Text(
                          'Favoris enregistrés (${_favorisFr.length})',
                          style: const TextStyle(
                            color: goldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ..._quartiersBruxelles.map((quartierObj) {
                final List lieuxFiltres = quartierObj['lieux'] as List;

                if (lieuxFiltres.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                      child: Text(
                        quartierObj['quartier'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: goldAccent,
                        ),
                      ),
                    ),
                    ...lieuxFiltres.map<Widget>((section) {
                      final String idLieu = section['id'];
                      final isFavori = _favorisFr.contains(idLieu);
                      final isVisite = _lieuxVisites.contains(idLieu);
                      final List<String> images = section['images'] ?? [];

                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        decoration: BoxDecoration(
                          color: cardObsidian,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          section['titre'],
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () => _basculerVisite(idLieu),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isVisite ? Icons.check_circle : Icons.radio_button_unchecked,
                                                color: isVisite ? goldAccent : Colors.white38,
                                                size: 15,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isVisite ? 'Lieu visité' : 'Marquer comme visité',
                                                style: TextStyle(
                                                  color: isVisite ? goldAccent : Colors.white38,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _basculerFavori(idLieu),
                                    icon: Icon(
                                      isFavori ? Icons.favorite : Icons.favorite_border,
                                      color: isFavori ? goldAccent : Colors.white38,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (images.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  children: List.generate(
                                    images.length,
                                        (imgIndex) => Padding(
                                      padding: EdgeInsets.only(bottom: imgIndex == images.length - 1 ? 0 : 12.0),
                                      child: _buildSingleImage(images[imgIndex], images, imgIndex),
                                    ),
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    section['histoire'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: textMuted,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: bgObsidian,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.lightbulb_outline, color: goldAccent, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            section['conseil'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _ouvrirMaps(section['mapsQuery']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: goldAccent,
                                        foregroundColor: bgObsidian,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.navigation_outlined, size: 16),
                                      label: const Text(
                                        'Ouvrir dans Google Maps',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Page Dédiée des Favoris de Bruxelles ---
class FavorisBruxellesPage extends StatefulWidget {
  const FavorisBruxellesPage({super.key});

  @override
  State<FavorisBruxellesPage> createState() => _FavorisBruxellesPageState();
}

class _FavorisBruxellesPageState extends State<FavorisBruxellesPage> {
  List<String> _favorisFr = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisFr = prefs.getStringList('favoris_bruxelles_fr') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisFr.remove(id);
      prefs.setStringList('favoris_bruxelles_fr', _favorisFr);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgObsidian = Color(0xFF0A0A0C);
    const Color cardObsidian = Color(0xFF141418);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color textMuted = Color(0xFF94A3B8);

    final List<Map<String, dynamic>> quartiersBruxelles = [
      {
        'quartier': 'Quartier Européen',
        'lieux': [
          {'id': 'parlement', 'titre': 'Parlement Européen', 'images': ['assets4/belgique/bruxelles/1.jpg']},
          {'id': 'cinquantenaire', 'titre': 'Parc du Cinquantenaire', 'images': ['assets4/belgique/bruxelles/4.jpg']},
          {'id': 'leopold', 'titre': 'Parc Léopold', 'images': ['assets4/belgique/bruxelles/7.jpg']},
        ],
      },
      {
        'quartier': 'Centre Historique',
        'lieux': [
          {'id': 'grandplace', 'titre': 'Grand-Place', 'images': ['assets4/belgique/bruxelles/9.jpg']},
          {'id': 'mannekenpis', 'titre': 'Manneken-Pis et Jeanneke-Pis', 'images': ['assets4/belgique/bruxelles/199.jpg']},
          {'id': 'galeries', 'titre': 'Galeries Royales Saint-Hubert', 'images': ['assets4/belgique/bruxelles/15.jpg']},
          {'id': 'montdesarts', 'titre': 'Mont des Arts', 'images': ['assets4/belgique/bruxelles/16.jpg']},
          {'id': 'palaisjustice', 'titre': 'Palais de Justice', 'images': ['assets4/belgique/bruxelles/18.jpg']},
        ],
      },
      {
        'quartier': 'Heyzel / Nord',
        'lieux': [
          {'id': 'atomium', 'titre': 'Atomium', 'images': ['assets4/belgique/bruxelles/22.jpg']},
          {'id': 'minieurope', 'titre': 'Mini-Europe', 'images': ['assets4/belgique/bruxelles/25.webp']},
        ],
      },
      {
        'quartier': 'Laeken (Nord-Ouest)',
        'lieux': [
          {'id': 'laeken', 'titre': 'Serres Royales de Laeken', 'images': ['assets4/belgique/bruxelles/27.webp']},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: bgObsidian,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: goldAccent))
            : ListView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardObsidian,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
                const Text(
                  'Favoris de Bruxelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 25),
            ...quartiersBruxelles.map((quartierObj) {
              final lieuxFav = (quartierObj['lieux'] as List).where((lieu) => _favorisFr.contains(lieu['id'])).toList();
              if (lieuxFav.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quartierObj['quartier'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...lieuxFav.map((lieu) {
                    final List<String> images = lieu['images'] ?? [];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: cardObsidian,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          if (images.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                images.first,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              lieu['titre'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _retirerFavori(lieu['id']),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }),
            if (_favorisFr.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    'Aucun favori enregistré pour Bruxelles.',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EurostarAnecdotesPage extends StatelessWidget {
  const EurostarAnecdotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgObsidian = Color(0xFF0A0A0C);
    const Color cardObsidian = Color(0xFF141418);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color textMuted = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgObsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardObsidian,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const Text(
                    'Anecdotes sur l\'Eurostar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardObsidian,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: goldAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.train, color: goldAccent, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Immersion à bord de l\'Eurostar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('En semaines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'En semaine, l\'Eurostar endosse son surnom emblématique de « train d\'affaires ». Qu\'il s\'agisse des voitures de première classe ou des rangées de seconde classe, le tumulte matinal et crépusculaire révèle une population de navetteurs assidus. Les ordinateurs portables s\'ouvrent dès le départ, transformant l\'espace en un véritable bureau itinérant. Les discussions stratégiques et les réunions improvisées s\'étirent jusque dans la voiture bar, devenue le point névralgique des échanges informels et du réseautage professionnel. Au milieu de cette effervescence corporative, la présence de rares touristes égarés crée un contraste visuel et atmosphérique particulièrement saisissant.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('En semaine de la journée', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'Au cœur de la journée en semaine, après l\'effervescence des départs matinaux, l\'atmosphère à bord subit une métamorphose radicale. Le rythme du train s\'harmonise avec le panorama rural qui défile de part et d\'autre des fenêtres. Un calme feutré s\'installe durablement dans les wagons, offrant aux rares passagers un sanctuaire de sérénité idéal pour la concentration, la relecture de dossiers complexes ou une parenthèse de repos studieux.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('Week-end', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'Dès le vendredi soir et tout au long du week-end, la physionomie de l\'Eurostar change du tout au tout. Les costumes stricts et les mallettes professionnelles cèdent définitivement la place aux tenues décontractées et aux sacs de voyage légers. L\'ambiance se pare d\'une légèreté festive, les wagons résonnant des éclats de voix de couples en escapade romantique, de cercles d\'amis et de voyageurs impatients de s\'immiscer dans l\'effervescence culturelle et gastronomique bruxelloise.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('Vacances scolaires', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'Pendant les périodes de vacances scolaires, l\'Eurostar se mue en un espace éminemment vivant et familial. Les espaces de rangement se gorgent de valises volumineuses et de poussettes, tandis que les wagons s\'animent au rythme des rires d\'enfants et des discussions enthousiastes. L\'atmosphère générale respire l\'exaltation des grands départs, contrastant fortement avec la rigueur des flux d\'affaires habituels.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('Vacances scolaires + week-end', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'Lorsque les vacances scolaires coïncident avec l\'affluence d\'un week-end, le taux d\'occupation de la rame atteint son paroxysme. C\'est la configuration des grands mouvements migratoires touristiques : les familles, les tribus d\'amis et les vacanciers se croisent en nombre dans les couloirs, insuffleant une dynamique d\'animation permanente et une effervescence collective characteristic des grands moments d\'évasion.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('Vacances scolaires + travail (en semaines)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'Cette configuration singulière illustre le quotidien hybride du voyageur moderne et connecté. En semaine, au cœur d\'une période de vacances scolaires, il n\'est pas rare d\'observer des parents jonglant habilement entre l\'accompagnement de leur famille en voyage et la gestion de dossiers professionnels urgents sur leur tablette, incarnant la juxtaposition parfaite entre impératifs de carrière et moments de partage personnel.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}