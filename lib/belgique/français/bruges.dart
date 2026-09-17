import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Bruges extends StatefulWidget {
  const Bruges({super.key});

  @override
  State<Bruges> createState() => _BrugesState();
}

class _BrugesState extends State<Bruges> {
  List<String> _favorisBrugesFr = [];
  List<String> _lieuxVisitesBruges = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _quartiersBruges = [
    {
      'quartier': 'Les Incontournables de Bruges',
      'lieux': [
        {
          'id': 'canaux_bruges',
          'titre': 'Les Canaux de Bruges',
          'images': [
            'assets4/belgique/bruges/1.webp',
            'assets4/belgique/bruges/2.jpg',
            'assets4/belgique/bruges/3.webp',
          ],
          'histoire':
          'Surnommée la "Venise du Nord", Bruges est sillonnée par un réseau de canaux romantique et envoûtant. Pour beaucoup de visiteurs, c\'est comme Venise en mieux : plus intimiste, verdoyant et préservé. Flâner le long des berges ou faire une balade en bateau offre une perspective magique sur les façades médiévales.',
          'conseil': 'Faire une promenade en bateau en début de matinée pour éviter la foule. Vérifier la météo avant de partir.',
          'mapsQuery': 'Canaux de Bruges',
        },
        {
          'id': 'quai_rosaire',
          'titre': 'Le Quai du Rosaire (Rozenhoedkaai)',
          'images': [
            'assets4/belgique/bruges/4.jpg',
            'assets4/belgique/bruges/6.jpg',
          ],
          'histoire':
          'C\'est l\'endroit le plus prisé et le plus photographié de Bruges. Avec ses vieilles façades se reflétant dans l\'eau et le Beffroi en arrière-plan, le Quai du Rosaire rappelle un peu le charme des quais de Gand (Graslei et Korenlei), tout en offrant un paysage digne d\'une carte postale.',
          'conseil': 'À admirer impérativement au coucher du soleil ou illuminé en soirée. Vérifier la météo avant de partir.',
          'mapsQuery': 'Quai du Rosaire Bruges',
        },
        {
          'id': 'beffroi_bruges',
          'titre': 'Le Beffroi de Bruges',
          'images': [
            'assets4/belgique/bruges/9.webp',
          ],
          'histoire':
          'Dominant la Grande-Place du haut de ses 83 mètres, cette tour médiévale emblématique abritait autrefois les archives, la trésorerie et le carillon de la ville. Gravir ses 366 marches offre une vue panoramique inoubliable sur Bruges et ses environs.',
          'conseil': 'Réserver son billet en ligne à l\'avance pour éviter les files d\'attente. Vérifier la météo avant de partir.',
          'mapsQuery': 'Beffroi de Bruges',
        },
        {
          'id': 'grote_markt',
          'titre': 'La Grande-Place (Grote Markt)',
          'images': [
            'assets4/belgique/bruges/11.webp',
            'assets4/belgique/bruges/12.webp',
            'assets4/belgique/bruges/14.webp',
          ],
          'histoire':
          'Cœur battant de la ville médiévale, le Grote Markt est bordé de célèbres maisons aux pignons en escalier, d\'anciennes halles aux draps et de terrasses animées. C\'est le point de départ idéal pour explorer la ville à pied ou en calèche.',
          'conseil': 'Profiter des terrasses en fin de journée pour admirer l\'animation de la place. Vérifier la météo avant de partir.',
          'mapsQuery': 'Grote Markt Bruges',
        },
        {
          'id': 'godshuizen',
          'titre': 'Les Godshuizen (Maisons de Dieu)',
          'images': [
            'assets4/belgique/bruges/15.webp',
            'assets4/belgique/bruges/16.webp',
          ],
          'histoire':
          'Ces petites maisons blanchies à la chaux, articulées autour d\'un jardin intérieur paisible, ont été construites dès le XIVe siècle par de riches citoyens ou des corporations pour loger les personnes âgées et défavorisées. Elles offrent aujourd\'hui de véritables havres de tranquillité cachés au cœur de la ville.',
          'conseil': 'Respecter le calme absolu de ces cours intérieures habitées. Vérifier la météo avant de partir.',
          'mapsQuery': 'Godshuizen Bruges',
        },
        {
          'id': 'moulins_bruges',
          'titre': 'Les Moulins à vent de Bruges',
          'images': [
            'assets4/belgique/bruges/17.jpeg',
          ],
          'histoire':
          'Situés sur les anciens remparts verdoyants au nord-est de la ville (Kruisvest), ces impressionnants moulins à vent en bois rappellent l\'époque où ils assuraient la mouture des céréales pour la cité. Le moulin Sint-Janshuis est l\'un des rares à fonctionner encore à son emplacement d\'origine.',
          'conseil': 'Idéal pour une belle promenade à pied ou à vélo le long du canal. Vérifier la météo avant de partir.',
          'mapsQuery': 'Moulins a vent Kruisvest Bruges',
        },
        {
          'id': 'basilique_saintsang',
          'titre': 'La Basilique du Saint-Sang',
          'images': [
            'assets4/belgique/bruges/20.jpg',
            'assets4/belgique/bruges/21.webp',
          ],
          'histoire':
          'Située sur la place du Burg, cette basilique se compose de deux chapelles superposées : une chapelle basse romane dédiée à saint Basile et une chapelle haute gothique abritant la relique du Saint-Sang, rapportée de Terre Sainte lors de la deuxième croisade.',
          'conseil': 'Découvrir les deux chapelles aux styles architecturaux très contrastés. Vérifier la météo avant de partir.',
          'mapsQuery': 'Basilique du Saint-Sang Bruges',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerDonneesBruges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets4/belgique/bruges/30.jpg'), context);
      for (var quartier in _quartiersBruges) {
        for (var lieu in quartier['lieux']) {
          for (String imgPath in lieu['images']) {
            precacheImage(AssetImage(imgPath), context);
          }
        }
      }
    }
  }

  Future<void> _chargerDonneesBruges() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisBrugesFr = prefs.getStringList('favoris_bruges_fr') ?? [];
      _lieuxVisitesBruges = prefs.getStringList('lieux_visites_bruges_fr') ?? [];
    });
  }

  Future<void> _basculerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorisBrugesFr.contains(id)) {
        _favorisBrugesFr.remove(id);
      } else {
        _favorisBrugesFr.add(id);
      }
      prefs.setStringList('favoris_bruges_fr', _favorisBrugesFr);
    });
  }

  Future<void> _toutAjouterFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersBruges) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _favorisBrugesFr = tousLesLieux;
      prefs.setStringList('favoris_bruges_fr', _favorisBrugesFr);
    });
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisBrugesFr.clear();
      prefs.setStringList('favoris_bruges_fr', _favorisBrugesFr);
    });
  }

  Future<void> _basculerVisite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_lieuxVisitesBruges.contains(id)) {
        _lieuxVisitesBruges.remove(id);
      } else {
        _lieuxVisitesBruges.add(id);
      }
      prefs.setStringList('lieux_visites_bruges_fr', _lieuxVisitesBruges);
    });
  }

  Future<void> _toutMarquerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersBruges) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _lieuxVisitesBruges = tousLesLieux;
      prefs.setStringList('lieux_visites_bruges_fr', _lieuxVisitesBruges);
    });
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisitesBruges.clear();
      prefs.setStringList('lieux_visites_bruges_fr', _lieuxVisitesBruges);
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
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 50),
                      ),
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
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            color: Colors.white10,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 30),
            ),
          ),
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
    for (var q in _quartiersBruges) {
      totalLieux += (q['lieux'] as List).length;
    }
    double progression = totalLieux > 0 ? _lieuxVisitesBruges.length / totalLieux : 0.0;

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
                          'Bruges',
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
                child: _buildSingleImage('assets4/belgique/bruges/19.jpeg', ['assets4/belgique/bruges/19.jpeg'], 0),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'La Venise du Nord Romantique',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cité médiévale préservée avec une authenticité remarquable, Bruges charme par ses canaux pittoresques, ses ruelles pavées et son patrimoine architectural féerique.',
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
                              'Conseils : Visiter Bruges en semaine, hors vacances scolaires et éviter les week-ends. Pensez à vérifier la météo avant de partir.',
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
                            '${_lieuxVisitesBruges.length} / $totalLieux visités',
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
                              builder: (context) => FavorisBrugesPage(quartiersBruges: _quartiersBruges),
                            ),
                          ).then((_) => _chargerDonneesBruges());
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
                          'Favoris enregistrés (${_favorisBrugesFr.length})',
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

              ..._quartiersBruges.map((quartierObj) {
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
                      final isFavori = _favorisBrugesFr.contains(idLieu);
                      final isVisite = _lieuxVisitesBruges.contains(idLieu);
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

// --- Page Dédiée des Favoris de Bruges ---
class FavorisBrugesPage extends StatefulWidget {
  final List<Map<String, dynamic>> quartiersBruges;

  const FavorisBrugesPage({super.key, required this.quartiersBruges});

  @override
  State<FavorisBrugesPage> createState() => _FavorisBrugesPageState();
}

class _FavorisBrugesPageState extends State<FavorisBrugesPage> {
  List<String> _favorisBrugesFr = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisBrugesFr = prefs.getStringList('favoris_bruges_fr') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisBrugesFr.remove(id);
      prefs.setStringList('favoris_bruges_fr', _favorisBrugesFr);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgObsidian = Color(0xFF0A0A0C);
    const Color cardObsidian = Color(0xFF141418);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color textMuted = Color(0xFF94A3B8);

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
                  'Favoris de Bruges',
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
            ...widget.quartiersBruges.map((quartierObj) {
              final lieuxFav = (quartierObj['lieux'] as List).where((lieu) => _favorisBrugesFr.contains(lieu['id'])).toList();
              if (lieuxFav.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      quartierObj['quartier'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                  ),
                  ...lieuxFav.map((lieu) {
                    final List<String> images = lieu['images'] ?? [];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: cardObsidian,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: images.isNotEmpty
                                ? Image.asset(
                              images.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.white10,
                                child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38),
                              ),
                            )
                                : Container(
                              width: 60,
                              height: 60,
                              color: Colors.white10,
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
            if (_favorisBrugesFr.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80.0),
                  child: Text(
                    'Aucun favori enregistré pour Bruges.',
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