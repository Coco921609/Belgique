import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Gand extends StatefulWidget {
  const Gand({super.key});

  @override
  State<Gand> createState() => _GandState();
}

class _GandState extends State<Gand> {
  List<String> _favorisGandFr = [];
  List<String> _lieuxVisitesGand = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _quartiersGand = [
    {
      'quartier': 'Les Incontournables de Gand',
      'lieux': [
        {
          'id': 'chateau_comtes',
          'titre': 'Le Château des Comtes',
          'images': [
            'assets4/belgique/gand/1.jpeg',
            'assets4/belgique/gand/2.jpg',
            'assets4/belgique/gand/3.jpg',
          ],
          'histoire':
          'Érigé au XIIe siècle par le comte Philippe d\'Alsace, le Château des Comtes (Gravensteen) est une imposante forteresse médiévale pratiquement intacte au cœur de la ville. Ancien siège du pouvoir comtal, prison puis usine textile, il offre un voyage captivant au temps des chevaliers et une vue panoramique impressionnante sur les toits de Gand.',
          'conseil': 'Visiter en semaine, hors vacances scolaires et éviter les week-ends. Vérifier la météo avant de partir.',
          'mapsQuery': 'Château des Comtes Gand',
        },
        {
          'id': 'beffroi_gand',
          'titre': 'Le Beffroi de Gand',
          'images': [
            'assets4/belgique/gand/4.jpg',
          ],
          'histoire':
          'Symbole de l\'indépendance et des libertés communales de la ville depuis le XIVe siècle, le Beffroi de Gand s\'élève à 91 mètres de hauteur. Couronné par son célèbre dragon en cuivre doré qui veille sur la cité, le beffroi abrite un superbe carillon et fait partie du patrimoine mondial de l\'UNESCO.',
          'conseil': 'Prendre l\'ascenseur pour profiter de la vue imprenable sans trop s\'épuiser. Vérifier la météo avant de partir.',
          'mapsQuery': 'Beffroi de Gand',
        },
        {
          'id': 'saint_bavon',
          'titre': 'La Cathédrale Saint-Bavon',
          'images': [
            'assets4/belgique/gand/5.jpg',
            'assets4/belgique/gand/6.jpg',
          ],
          'histoire':
          'Mélange harmonieux de styles roman, gothique rayonnant et gothique brabançon, cette majestueuse cathédrale est célèbre dans le monde entier pour abriter l\'un des plus grands chefs-d\'œuvre de la peinture flamande : "L\'Adoration de l\'Agneau mystique" des frères Van Eyck.',
          'conseil': 'Penser à réserver votre billet à l\'avance pour admirer le retable de l\'Agneau Mystique. Vérifier la météo avant de partir.',
          'mapsQuery': 'Cathédrale Saint-Bavon Gand',
        },
        {
          'id': 'quai_herbes_grains',
          'titre': 'Le Quai aux Herbes (Graslei) et le Quai aux Grains (Korenlei)',
          'images': [
            'assets4/belgique/gand/7.jpg',
          ],
          'histoire':
          'Face à face de chaque côté de la Lys, le Quai aux Herbes (Graslei) et le Quai aux Grains (Korenlei) forment le cœur historique et pittoresque du vieux port marchand de Gand. Bordés par une rangée spectaculaire de maisons de corporations allant du style roman à la Renaissance, ils offrent les plus beaux reflets de la ville et une vue architecturale d\'exception.',
          'conseil': 'L\'endroit idéal pour s\'installer en terrasse, se promener au bord de l\'eau au coucher du soleil ou embarquer à bord d\'une croisière guidée en bateau. Vérifier la météo avant de partir.',
          'mapsQuery': 'Graslei et Korenlei Gand',
        },
        {
          'id': 'pont_saint_michel',
          'titre': 'Le Pont Saint-Michel',
          'images': [
            'assets4/belgique/gand/8.webp',
            'assets4/belgique/gand/9.webp',
            'assets4/belgique/gand/12.webp',
          ],
          'histoire':
          'Construit en pierre au début du XXe siècle, ce pont emblématique offre le point de vue le plus célèbre et photographié de Gand. Depuis son sommet, on embrasse un panorama à 360 degrés englobant les trois célèbres tours alignées (Saint-Nicolas, le Beffroi et Saint-Bavon) ainsi que les quais Graslei et Korenlei.',
          'conseil': 'Surtout à visiter très tôt le matin pour les amateurs de photographie afin de profiter d\'une lumière magique et du calme. Vérifier la météo avant de partir.',
          'mapsQuery': 'Pont Saint-Michel Gand',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerDonneesGand();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets4/belgique/gand/11.webp'), context);
      for (var quartier in _quartiersGand) {
        for (var lieu in quartier['lieux']) {
          for (String imgPath in lieu['images']) {
            precacheImage(AssetImage(imgPath), context);
          }
        }
      }
    }
  }

  Future<void> _chargerDonneesGand() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisGandFr = prefs.getStringList('favoris_gand_fr') ?? [];
      _lieuxVisitesGand = prefs.getStringList('lieux_visites_gand_fr') ?? [];
    });
  }

  Future<void> _basculerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorisGandFr.contains(id)) {
        _favorisGandFr.remove(id);
      } else {
        _favorisGandFr.add(id);
      }
      prefs.setStringList('favoris_gand_fr', _favorisGandFr);
    });
  }

  Future<void> _toutAjouterFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersGand) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _favorisGandFr = tousLesLieux;
      prefs.setStringList('favoris_gand_fr', _favorisGandFr);
    });
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisGandFr.clear();
      prefs.setStringList('favoris_gand_fr', _favorisGandFr);
    });
  }

  Future<void> _basculerVisite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_lieuxVisitesGand.contains(id)) {
        _lieuxVisitesGand.remove(id);
      } else {
        _lieuxVisitesGand.add(id);
      }
      prefs.setStringList('lieux_visites_gand_fr', _lieuxVisitesGand);
    });
  }

  Future<void> _toutMarquerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersGand) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _lieuxVisitesGand = tousLesLieux;
      prefs.setStringList('lieux_visites_gand_fr', _lieuxVisitesGand);
    });
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisitesGand.clear();
      prefs.setStringList('lieux_visites_gand_fr', _lieuxVisitesGand);
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
    for (var q in _quartiersGand) {
      totalLieux += (q['lieux'] as List).length;
    }
    double progression = totalLieux > 0 ? _lieuxVisitesGand.length / totalLieux : 0.0;

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
                          'Gand',
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
                child: _buildSingleImage('assets4/belgique/gand/11.webp', ['assets4/belgique/gand/11.webp'], 0),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Le Joyau Médiéval de la Flandre',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ville d\'art et d\'histoire d\'une poésie unique, Gand fascine par ses canaux étincelants, ses monuments médiévolement majestueux et son dynamisme culturel authentique.',
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
                              'Conseils : Visiter Gand en semaine, hors vacances scolaires et éviter les week-ends. Pensez à vérifier la météo avant de partir.',
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
                            '${_lieuxVisitesGand.length} / $totalLieux visités',
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
                              builder: (context) => FavorisGandPage(quartiersGand: _quartiersGand),
                            ),
                          ).then((_) => _chargerDonneesGand());
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
                          'Favoris enregistrés (${_favorisGandFr.length})',
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

              ..._quartiersGand.map((quartierObj) {
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
                      final isFavori = _favorisGandFr.contains(idLieu);
                      final isVisite = _lieuxVisitesGand.contains(idLieu);
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

// --- Page Dédiée des Favoris de Gand (Format Liste Exact de Bruxelles) ---
class FavorisGandPage extends StatefulWidget {
  final List<Map<String, dynamic>> quartiersGand;

  const FavorisGandPage({super.key, required this.quartiersGand});

  @override
  State<FavorisGandPage> createState() => _FavorisGandPageState();
}

class _FavorisGandPageState extends State<FavorisGandPage> {
  List<String> _favorisGandFr = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisGandFr = prefs.getStringList('favoris_gand_fr') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisGandFr.remove(id);
      prefs.setStringList('favoris_gand_fr', _favorisGandFr);
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
                  'Favoris de Gand',
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
            ...widget.quartiersGand.map((quartierObj) {
              final lieuxFav = (quartierObj['lieux'] as List).where((lieu) => _favorisGandFr.contains(lieu['id'])).toList();
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
            if (_favorisGandFr.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80.0),
                  child: Text(
                    'Aucun favori enregistré pour Gand.',
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