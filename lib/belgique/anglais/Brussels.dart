import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Brussels extends StatefulWidget {
  const Brussels({super.key});

  @override
  State<Brussels> createState() => _BruxellesState();
}

class _BruxellesState extends State<Brussels> {
  List<String> _favorisEn = [];
  List<String> _lieuxVisites = [];
  bool _isPrecached = false;

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _quartiersBruxelles = [
    {
      'quartier': 'European Quarter',
      'lieux': [
        {
          'id': 'parlement',
          'titre': 'European Parliament',
          'images': [
            'assets4/belgique/bruxelles/1.jpg',
            'assets4/belgique/bruxelles/2.jpg',
            'assets4/belgique/bruxelles/3.jpg',
          ],
          'histoire':
          'The European Parliament is one of the major institutions of the European Union. If Brussels was chosen as its principal seat (alongside Strasbourg and Luxembourg), it is due to its central position in the heart of Europe, its historical bilingualism (French-Dutch), and its diplomatic tradition, thus avoiding favoring major historical national capitals like Paris or more out-of-the-way locations. It is the political and decision-making heart for over 450 million European citizens.',
          'conseil': 'Visit on weekdays, outside school holidays and avoid weekends. Check the weather before leaving.',
          'mapsQuery': 'European Parliament Brussels',
        },
        {
          'id': 'cinquantenaire',
          'titre': 'Cinquantenaire Park',
          'images': [
            'assets4/belgique/bruxelles/4.jpg',
            'assets4/belgique/bruxelles/5.png',
          ],
          'histoire':
          'Created under the reign of Leopold II to celebrate the fiftieth anniversary of Belgium\'s independence during the national exhibition of 1880, the park is dominated by its majestic triumphal arches and major national museums (Army Museum, Autoworld). Located a stone\'s throw from the European Quarter, it constitutes an immense green space steeped in architectural and memorial history.',
          'conseil': 'Ideal in autumn and spring to enjoy the magnificent colors. Check the weather before leaving.',
          'mapsQuery': 'Cinquantenaire Park Brussels',
        },
        {
          'id': 'leopold',
          'titre': 'Leopold Park',
          'images': [
            'assets4/belgique/bruxelles/7.jpg',
          ],
          'histoire':
          'Located right behind the European Parliament (and very close to the Cinquantenaire), this historic park offers a lush green natural setting and houses unusual remains, including an authentic fragment of the Berlin Wall erected in memory of European geopolitical upheavals. Formerly Brussels\' zoological garden, it testifies to the capital\'s urban transition.',
          'conseil': 'Ideal on a sunny day. Check the weather before leaving.',
          'mapsQuery': 'Leopold Park Brussels',
        },
      ],
    },
    {
      'quartier': 'Historic Center',
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
          'The beating historic heart of Brussels, the Grand-Place is world-renowned for the richness of its ornamental and architectural decoration, bringing together opulent guild houses, the Gothic Town Hall, and the King\'s House. Largely rebuilt after the destructive bombardment of 1695 by French troops, it is a UNESCO World Heritage site.',
          'conseil': 'A must-see both day and night. Check the weather before leaving.',
          'mapsQuery': 'Grand-Place Brussels',
        },
        {
          'id': 'mannekenpis',
          'titre': 'Manneken-Pis and Jeanneke-Pis',
          'images': [
            'assets4/belgique/bruxelles/12.webp',
            'assets4/belgique/bruxelles/14.jpg',
          ],
          'histoire':
          'Located in the immediate vicinity of the Grand-Place, Manneken-Pis is a small bronze fountain representing a urinating boy, symbol of the independent, defiant, and humorous spirit of the people of Brussels (dressed in traditional costumes on various occasions). Jeanneke-Pis, its female counterpart located in a neighboring alley (Impasse de la Fidélité), was created later in 1987 to promote local folklore and support charities.',
          'conseil': 'Plan a quick walk through the pedestrian alleys. Check the weather before leaving.',
          'mapsQuery': 'Manneken-Pis Brussels',
        },
        {
          'id': 'galeries',
          'titre': 'Royal Saint-Hubert Galleries',
          'images': [
            'assets4/belgique/bruxelles/15.jpg',
          ],
          'histoire':
          'Inaugurated in 1847 a stone\'s throw from the Grand-Place, these superb covered shopping galleries (divided into Gallery of the Queen, the King, and the Princes) are among the oldest and most elegant in Europe. Designed by architect Jean-Pierre Cluysenaar, they are famous for their luxury display windows, historic artisan chocolate shops, theaters, and luminous glass roof.',
          'conseil': 'Taste the artisan chocolates on site. Check the weather before leaving.',
          'mapsQuery': 'Royal Saint-Hubert Galleries Brussels',
        },
        {
          'id': 'montdesarts',
          'titre': 'Mont des Arts',
          'images': [
            'assets4/belgique/bruxelles/16.jpg',
            'assets4/belgique/bruxelles/17.webp',
          ],
          'histoire':
          'Originally laid out for the 1910 International Exhibition and then completely redesigned in the 1950s during the city\'s major urban renewal projects, the Mont des Arts links the Upper Town (museum and royal palace district) and the Lower Town (historic center). It offers a sloping geometric garden and one of the most spectacular panoramas over the rooftops of Brussels and the Town Hall.',
          'conseil': 'Magnificent view at sunset. Check the weather before leaving.',
          'mapsQuery': 'Mont des Arts Brussels',
        },
        {
          'id': 'palaisjustice',
          'titre': 'Palace of Justice',
          'images': [
            'assets4/belgique/bruxelles/18.jpg',
            'assets4/belgique/bruxelles/19.webp',
            'assets4/belgique/bruxelles/20.webp',
            'assets4/belgique/bruxelles/21.jpg',
          ],
          'histoire':
          'Built between 1866 and 1883 by architect Joseph Poelaert, this colossal building dominates the Marolles district and offers a breathtaking view of the city. It is one of the largest courthouse buildings constructed in 19th-century Europe, surpassing certain basilicas in its ground surface area. Its monumental architecture mixes Greco-Roman and Assyrian inspirations.',
          'conseil': 'Admire the sheer scale of the architecture. Check the weather before leaving.',
          'mapsQuery': 'Palace of Justice Brussels',
        },
      ],
    },
    {
      'quartier': 'Heysel / North',
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
          'Designed for the 1958 Brussels World\'s Fair (Expo 58) by architect André Waterkeyn and engineers Pol and Jean Cornellie, the Atomium represents the elementary unit of an iron crystal magnified 165 billion times. A true Belgian version of the Eiffel Tower, it symbolizes bold faith in scientific progress, modernity, and the post-war atomic era. From its summit or at its feet, one can also listen to and observe the impressive ballet of planes taking off and landing, with Zaventem airport located right next door.',
          'conseil': 'Visit on weekdays, outside school holidays and avoid weekends. Check the weather before leaving.',
          'mapsQuery': 'Atomium Brussels',
        },
        {
          'id': 'minieurope',
          'titre': 'Mini-Europe',
          'images': [
            'assets4/belgique/bruxelles/25.webp',
            'assets4/belgique/bruxelles/26.jpg',
          ],
          'histoire':
          'Inaugurated in 1989 right at the foot of the Atomium (the two sites are thus ideally visited together), the Mini-Europe park allows visitors to tour the European Union in a few steps through nearly 350 landmark European monuments reproduced at a 1/25 scale with impressive attention to detail, animations, and sound effects.',
          'conseil': 'Visit on weekdays, outside school holidays and avoid weekends. Check the weather before leaving.',
          'mapsQuery': 'Mini-Europe Brussels',
        },
      ],
    },
    {
      'quartier': 'Laeken (North-West)',
      'lieux': [
        {
          'id': 'laeken',
          'titre': 'Royal Greenhouses of Laeken',
          'images': [
            'assets4/belgique/bruxelles/27.webp',
            'assets4/belgique/bruxelles/28.jpg',
            'assets4/belgique/bruxelles/29.webp',
          ],
          'histoire':
          'Royal residential district housing the Castle of Laeken (residence of the Belgian royal family) and its famous monumental iron and glass greenhouses. Designed by architect Alphonse Balat for King Leopold II in the late 19th century, they constitute a masterpiece of metal architecture and house rare botanical collections, open to the public only a few weeks a year in spring.',
          'conseil': 'Exceptional opening in spring. Check the weather before leaving.',
          'mapsQuery': 'Castle of Laeken Brussels',
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
      _favorisEn = prefs.getStringList('favoris_bruxelles_en') ?? [];
      _lieuxVisites = prefs.getStringList('lieux_visites_bruxelles_en') ?? [];
    });
  }

  Future<void> _basculerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorisEn.contains(id)) {
        _favorisEn.remove(id);
      } else {
        _favorisEn.add(id);
      }
      prefs.setStringList('favoris_bruxelles_en', _favorisEn);
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
      _favorisEn = tousLesLieux;
      prefs.setStringList('favoris_bruxelles_en', _favorisEn);
    });
  }

  Future<void> _toutRetirerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisEn.clear();
      prefs.setStringList('favoris_bruxelles_en', _favorisEn);
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
      prefs.setStringList('lieux_visites_bruxelles_en', _lieuxVisites);
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
      prefs.setStringList('lieux_visites_bruxelles_en', _lieuxVisites);
    });
  }

  Future<void> _toutEffacerVisite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lieuxVisites.clear();
      prefs.setStringList('lieux_visites_bruxelles_en', _lieuxVisites);
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
                          'Brussels',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Travel guide',
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
                      'The Elegance of the Capital',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sovereign capital of Belgium and institutional nerve center of the European Union, Brussels fuses exceptional architectural heritage, cultural avant-gardism, and a rare elegance in lifestyle.',
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
                              'Tips : Visit Brussels on weekdays, outside school holidays and avoid weekends. Remember to check the weather before leaving.',
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
                                'Eurostar Anecdotes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Click to read anecdotes',
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
                            'Progress',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_lieuxVisites.length} / $totalLieux visited',
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
                              child: const Text('Mark all as visited', style: TextStyle(color: goldAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
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
                              child: const Text('Reset visits', style: TextStyle(color: Colors.white54, fontSize: 11.5, fontWeight: FontWeight.bold)),
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
                            child: const Text('Add all to favorites', style: TextStyle(color: goldAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
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
                            child: const Text('Remove all from favorites', style: TextStyle(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.bold)),
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
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const FavorisBruxellesPage(),
                              transitionDuration: Duration.zero,
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
                          'Saved favorites (${_favorisEn.length})',
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
                      final isFavori = _favorisEn.contains(idLieu);
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
                                                isVisite ? 'Visited place' : 'Mark as visited',
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
                                        'Open in Google Maps',
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

// --- Dedicated Brussels Favorites Page (Key: 'favoris_bruxelles_en') ---
class FavorisBruxellesPage extends StatefulWidget {
  const FavorisBruxellesPage({super.key});

  @override
  State<FavorisBruxellesPage> createState() => _FavorisBruxellesPageState();
}

class _FavorisBruxellesPageState extends State<FavorisBruxellesPage> {
  List<String> _favorisEn = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisEn = prefs.getStringList('favoris_bruxelles_en') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _retirerFavori(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisEn.remove(id);
      prefs.setStringList('favoris_bruxelles_en', _favorisEn);
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
        'quartier': 'European Quarter',
        'lieux': [
          {'id': 'parlement', 'titre': 'European Parliament', 'images': ['assets4/belgique/bruxelles/1.jpg']},
          {'id': 'cinquantenaire', 'titre': 'Cinquantenaire Park', 'images': ['assets4/belgique/bruxelles/4.jpg']},
          {'id': 'leopold', 'titre': 'Leopold Park', 'images': ['assets4/belgique/bruxelles/7.jpg']},
        ],
      },
      {
        'quartier': 'Historic Center',
        'lieux': [
          {'id': 'grandplace', 'titre': 'Grand-Place', 'images': ['assets4/belgique/bruxelles/9.jpg']},
          {'id': 'mannekenpis', 'titre': 'Manneken-Pis and Jeanneke-Pis', 'images': ['assets4/belgique/bruxelles/12.webp']},
          {'id': 'galeries', 'titre': 'Royal Saint-Hubert Galleries', 'images': ['assets4/belgique/bruxelles/15.jpg']},
          {'id': 'montdesarts', 'titre': 'Mont des Arts', 'images': ['assets4/belgique/bruxelles/16.jpg']},
          {'id': 'palaisjustice', 'titre': 'Palace of Justice', 'images': ['assets4/belgique/bruxelles/18.jpg']},
        ],
      },
      {
        'quartier': 'Heysel / North',
        'lieux': [
          {'id': 'atomium', 'titre': 'Atomium', 'images': ['assets4/belgique/bruxelles/22.jpg']},
          {'id': 'minieurope', 'titre': 'Mini-Europe', 'images': ['assets4/belgique/bruxelles/25.webp']},
        ],
      },
      {
        'quartier': 'Laeken (North-West)',
        'lieux': [
          {'id': 'laeken', 'titre': 'Royal Greenhouses of Laeken', 'images': ['assets4/belgique/bruxelles/27.webp']},
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
                  'Brussels Favorites',
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
              final lieuxFav = (quartierObj['lieux'] as List).where((lieu) => _favorisEn.contains(lieu['id'])).toList();
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
            if (_favorisEn.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    'No favorites saved for Brussels.',
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
                    'Eurostar Anecdotes',
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
                            'Immersion aboard Eurostar',
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

                    const Text('Weekdays', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'On weekdays, Eurostar takes on its emblematic nickname of "business train". Whether in first-class coaches or second-class rows, the morning and twilight bustle reveals a population of dedicated commuters. Laptops open right from departure, transforming the space into a true mobile office. Strategic discussions and impromptu meetings stretch all the way into the bar car, which has become the nerve center for informal exchanges and professional networking. Amidst this corporate effervescence, the presence of a few stray tourists creates a particularly striking visual and atmospheric contrast.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('Midday on weekdays', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'In the middle of the day on weekdays, after the hustle and bustle of morning departures, the atmosphere on board undergoes a radical metamorphosis. The rhythm of the train harmonizes with the rural panorama rolling by on either side of the windows. A muted calm settles enduringly in the carriages, offering the few passengers a sanctuary of serenity ideal for concentration, reviewing complex files, or a spell of studious rest.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('Weekend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'From Friday evening and throughout the weekend, Eurostar\'s appearance changes completely. Strict suits and professional briefcases definitively give way to casual attire and light travel bags. The atmosphere takes on a festive lightness, with carriages echoing the cheerful voices of couples on romantic getaways, circles of friends, and travelers eager to immerse themselves in Brussels\' cultural and gastronomic effervescence.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('School holidays', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'During school holiday periods, Eurostar transforms into an eminently lively and family-oriented space. Storage areas fill with bulky suitcases and strollers, while carriages come alive to the rhythm of children\'s laughter and enthusiastic conversations. The general atmosphere breathes the excitement of major getaways, contrasting sharply with the rigor of usual business flows.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('School holidays + weekend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'When school holidays coincide with weekend crowds, the train\'s occupancy rate reaches its peak. This is the configuration of major tourist migration movements: families, groups of friends, and vacationers cross paths in numbers through the corridors, infusing a dynamic of permanent animation and collective effervescence characteristic of great moments of escape.',
                      style: TextStyle(fontSize: 13, color: textMuted, height: 1.6),
                    ),
                    const SizedBox(height: 20),

                    const Text('School holidays + work (weekdays)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldAccent)),
                    const SizedBox(height: 6),
                    const Text(
                      'This singular configuration illustrates the hybrid daily life of the modern, connected traveler. On weekdays, in the middle of a school holiday period, it is not uncommon to observe parents skillfully juggling between accompanying their traveling family and managing urgent professional files on their tablet, embodying the perfect juxtaposition between career imperatives and moments of personal sharing.',
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