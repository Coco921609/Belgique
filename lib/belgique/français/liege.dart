import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Liege extends StatefulWidget {
  const Liege({super.key});

  @override
  State<Liege> createState() => _LiegeState();
}

class _LiegeState extends State<Liege> {
  List<String> _favorisLiegeFr = [];
  List<String> _lieuxVisitesLiege = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _quartiersLiege = [
    {
      'quartier': 'Les Incontournables de Liège',
      'lieux': [
        {
          'id': 'montagne_bueren',
          'titre': 'La Montagne de Bueren',
          'images': [
            'assets4/belgique/liege/1.webp',
            'assets4/belgique/liege/2.webp',
            'assets4/belgique/liege/1 bis.webp',
          ],
          'histoire':
          'Célèbre escalier monumental de 374 marches construit au XIXe siècle, la Montagne de Bueren offre l\'un des défis urbains les plus pittoresques de Belgique. Son sommet dévoile un panorama époustouflant et inoubliable sur la Cité Ardente et la Meuse.',
          'conseil': 'Prendre son temps pour gravir les marches et admirer la vue au sommet. Vérifier la météo avant de partir.',
          'mapsQuery': 'Montagne de Bueren Liege',
        },
        {
          'id': 'coteaux_citadelle',
          'titre': 'Les Coteaux de la Citadelle',
          'images': [
            'assets4/belgique/liege/3.jpg',
            'assets4/belgique/liege/4.jpg',
          ],
          'histoire':
          'Véritable poumon vert suspendu au-dessus du centre-ville, les Coteaux regroupent près de 90 monuments classés, des sentiers escarpés, d\'anciens vergers et des terrasses historiques. Un havre de tranquillité plein de charme à deux pas de la ville.',
          'conseil': 'Prévoir des chaussures confortables pour parcourir les chemins pavés et les sentiers. Vérifier la météo avant de partir.',
          'mapsQuery': 'Coteaux de la Citadelle Liege',
        },
        {
          'id': 'gare_liege_guillemins',
          'titre': 'La Gare de Liège-Guillemins',
          'images': [
            'assets4/belgique/liege/5.jpg',
            'assets4/belgique/liege/6.webp',
            'assets4/belgique/liege/7.jpg',
          ],
          'histoire':
          'Conçue par le renommé architecte espagnol Santiago Calatrava, cette gare monumentale et futuriste surprend par son immense voûte autoportante en acier et en verre. Elle incarne à la perfection le renouveau et le dynamisme moderne de la ville.',
          'conseil': 'Admirer les magnifiques jeux de lumière à travers la verrière aux différentes heures de la journée. Vérifier la météo avant de partir.',
          'mapsQuery': 'Gare de Liege Guillemins',
        },
        {
          'id': 'cathedrale_saint_paul',
          'titre': 'La Cathédrale Saint-Paul',
          'images': [
            'assets4/belgique/liege/8.jpg',
          ],
          'histoire':
          'Cœur spirituel de la cité, la Cathédrale Saint-Paul marie élégamment les styles gothique et gothique rayonnant. Elle abrite de magnifiques peintures murales, des vitraux spectaculaires et un trésor d\'orfèvrerie religieuse remarquable.',
          'conseil': 'Profiter du calme du cloître attenant pour une pause sereine au cœur du centre. Vérifier la météo avant de partir.',
          'mapsQuery': 'Cathedrale Saint Paul Liege',
        },
        {
          'id': 'ruelles_impasses_liege',
          'titre': 'Les Ruelles et Impasses de Liège',
          'images': [
            'assets4/belgique/liege/10.jpg',
            'assets4/belgique/liege/15.jpg',
            'assets4/belgique/liege/12.webp',
          ],
          'histoire':
          'Loin des idées reçues, Liège regorge de trésors cachés à l\'image du quartier Hors-Château et de la Cour Saint-Antoine. Ces ruelles pavées, bordées de maisons anciennes restaurées et de verdure, révèlent un charme poétique et romantique méconnu.',
          'conseil': 'S\'aventurer dans l\'Impasse de l\'Ange ou de la Couronne pour une expérience authentique. Vérifier la météo avant de partir.',
          'mapsQuery': 'Hors Chateau Liege',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerDonneesLiege();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      _isPrecached = true;
      precacheImage(const AssetImage('assets4/belgique/liege/30.jpg'), context);
      for (var quartier in _quartiersLiege) {
        for (var lieu in quartier['lieux']) {
          for (String imgPath in lieu['images']) {
            precacheImage(AssetImage(imgPath), context);
          }
        }
      }
    }
  }

  Future<void> _chargerDonneesLiege() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorisLiegeFr = prefs.getStringList('favoris_liege_fr') ?? [];
      _lieuxVisitesLiege = prefs.getStringList('lieux_visites_liege_fr') ?? [];
    });
  }

  Future<void> _basculerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorisLiegeFr.contains(id)) {
        _favorisLiegeFr.remove(id);
      } else {
        _favorisLiegeFr.add(id);
      }
      prefs.setStringList('favoris_liege_fr', _favorisLiegeFr);
    });
  }

  Future<void> _toutAjouterFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersLiege) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _favorisLiegeFr = tousLesLieux;
      prefs.setStringList('favoris_liege_fr', _favorisLiegeFr);
    });
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLiegeFr.clear();
      prefs.setStringList('favoris_liege_fr', _favorisLiegeFr);
    });
  }

  Future<void> _basculerVisite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_lieuxVisitesLiege.contains(id)) {
        _lieuxVisitesLiege.remove(id);
      } else {
        _lieuxVisitesLiege.add(id);
      }
      prefs.setStringList('lieux_visites_liege_fr', _lieuxVisitesLiege);
    });
  }

  Future<void> _toutMarquerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tousLesLieux = [];
    for (var q in _quartiersLiege) {
      for (var l in q['lieux']) {
        tousLesLieux.add(l['id']);
      }
    }
    setState(() {
      _lieuxVisitesLiege = tousLesLieux;
      prefs.setStringList('lieux_visites_liege_fr', _lieuxVisitesLiege);
    });
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisitesLiege.clear();
      prefs.setStringList('lieux_visites_liege_fr', _lieuxVisitesLiege);
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
    for (var q in _quartiersLiege) {
      totalLieux += (q['lieux'] as List).length;
    }
    double progression = totalLieux > 0 ? _lieuxVisitesLiege.length / totalLieux : 0.0;

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
                          'Liège',
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
                child: _buildSingleImage('assets4/belgique/liege/16.jpg', ['assets4/belgique/liege/16.jpg'], 0),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Une Ville au Charme Authentique',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Beaucoup disent parfois à tort que la ville est moche, mais Liège est en réalité une cité remplie de charme ! Entre sa gare futuriste, ses ruelles médiévales secrètes, ses coteaux verdoyants et la convivialité légendaire de la Cité Ardente, elle sait surprendre et émerveiller.',
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
                              'Conseils : Visiter Liège en semaine, hors vacances scolaires et éviter les week-ends. Pensez à vérifier la météo avant de partir.',
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
                            '${_lieuxVisitesLiege.length} / $totalLieux visités',
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
                              builder: (context) => FavorisLiegePage(quartiersLiege: _quartiersLiege),
                            ),
                          ).then((_) => _chargerDonneesLiege());
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
                          'Favoris enregistrés (${_favorisLiegeFr.length})',
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

              ..._quartiersLiege.map((quartierObj) {
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
                      final isFavori = _favorisLiegeFr.contains(idLieu);
                      final isVisite = _lieuxVisitesLiege.contains(idLieu);
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

// --- Page Dédiée des Favoris de Liège ---
class FavorisLiegePage extends StatefulWidget {
  final List<Map<String, dynamic>> quartiersLiege;

  const FavorisLiegePage({super.key, required this.quartiersLiege});

  @override
  State<FavorisLiegePage> createState() => _FavorisLiegePageState();
}

class _FavorisLiegePageState extends State<FavorisLiegePage> {
  List<String> _favorisLiegeFr = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLiegeFr = prefs.getStringList('favoris_liege_fr') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLiegeFr.remove(id);
      prefs.setStringList('favoris_liege_fr', _favorisLiegeFr);
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
                  'Favoris de Liège',
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
            ...widget.quartiersLiege.map((quartierObj) {
              final lieuxFav = (quartierObj['lieux'] as List).where((lieu) => _favorisLiegeFr.contains(lieu['id'])).toList();
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
            if (_favorisLiegeFr.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80.0),
                  child: Text(
                    'Aucun favori enregistré pour Liège.',
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