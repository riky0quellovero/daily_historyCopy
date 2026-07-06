import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_history/global.dart';
import 'package:daily_history/l10n/localeProvider.dart';
import 'package:daily_history/pages/figure/databaseBuilder.dart';
import 'package:daily_history/pages/saved/savedProvider.dart';
import 'package:daily_history/themes/darkTheme.dart';
import 'package:flutter/material.dart';

//TODO: make card open figures

ValueNotifier<String?> _selectedName = ValueNotifier(null);

bool loading = true;
bool initRun = false;
List<String> savedNames = [];

Future<void> init() async {
  initRun = true;

  print(SavedProvider.instance.savedDates.map((date) => date.millisecondsSinceEpoch.toString()));
  var snapshot = await firestore.collection('figure').where(FieldPath.documentId, whereIn: SavedProvider.instance.savedDates.map((date) => date.millisecondsSinceEpoch.toString())).get();
  print(snapshot.docs);
  savedNames = snapshot.docs.map((doc) => doc['language'][LocaleProvider.instance.locale.languageCode]['name'] as String).toList();

  print(savedNames);

  loading = false;
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({super.key});

  @override
  State<_SearchBar> createState() => _BarState();
}

class _BarState extends State<_SearchBar> with WidgetsBindingObserver {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Set<String> currentHints = {};
  static const int maxSuggestions = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => currentHints.clear());
      }
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset == 0.0 && mounted) {
      // Tastiera chiusa → chiudi suggerimenti
      setState(() => currentHints.clear());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      color: context.colorScheme.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Barra di ricerca ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyles.research.value,
                  controller: searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: context.l10n.search,
                    hintStyle: TextStyles.searchBar.value,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    _selectedName.value = null;
                    final names = savedNames;
                    if (names == null || val.isEmpty) {
                      setState(() => currentHints.clear());
                      return;
                    }
                    final results = names
                        .where((elem) =>
                        elem.toLowerCase().contains(val.toLowerCase()))
                        .toList()
                      ..sort();

                    setState(() {
                      currentHints = results
                          .take(maxSuggestions)
                          .toSet();
                    });
                  },
                ),
              ),
              const Icon(Icons.search, color: Colors.white, size: 30),
            ],
          ),

          // --- Divider ---
          if (currentHints.isNotEmpty)
            Divider(
              height: 8,
              thickness: 1,
              color: context.colorScheme.onSecondary.withOpacity(0.2),
            ),

          // --- Suggerimenti ---
          if (currentHints.isNotEmpty)
            Column(
              children: currentHints.map((e) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.search, size: 18),
                  title: Text(e, style: TextStyles.searchBar.value.copyWith(color: context.colorScheme.onPrimary),),
                  onTap: () {
                    searchController.text = e;
                    setState(() => currentHints.clear());
                    _focusNode.unfocus();
                    _selectedName.value = e;
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}


class SavedPage extends StatelessWidget {
  SavedPage({super.key});

  ValueNotifier<int> nameLoaded = new ValueNotifier(1);

  @override
  Widget build(BuildContext context) {
    //if(!initRun)
      init().then((_) => nameLoaded.value = 2);

    return AppPage(
        title: context.l10n.library,
        barConfiguration: BarConfigurations.none,

        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 50,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(context.l10n.saved, style: TextStyles.title.value,),
                ),
                const Divider(),
                const SizedBox(height: 30,),
                ListenableBuilder(
                  listenable: _selectedName,
                  builder: (context, child) {
                      return Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 30,
                              crossAxisSpacing: 30,
                              childAspectRatio: 1.14
                          ),
                          itemCount: SavedProvider.instance.savedDates.length,
                          itemBuilder: (context, index) {
                            if(_selectedName.value != null) {
                              return (index == 0) ?
                              ValueListenableBuilder<int>(
                                valueListenable: nameLoaded,
                                builder: (context, _, __) {
                                  return FigureCard(name: _selectedName.value!, date: SavedProvider.instance.savedDates[index],);
                                  },
                              ) : null;
                            }
                            return ValueListenableBuilder<int>(
                              valueListenable: nameLoaded,
                              builder: (context, _, __) {
                                String name = (savedNames.length == 0) ? '' : savedNames[index];
                                print('name:$name');
                                return FigureCard(date: SavedProvider.instance.savedDates[index], name: name);
                              },
                            );
                          },
                        ),
                      );
                  },
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: _SearchBar(),
            ),
          ],
        )
    );
  }
}

class FigureCard extends StatefulWidget {
  final Timestamp date;
  final String? name;
  const FigureCard({required this.date, required this.name, super.key});

  @override
  State<FigureCard> createState() => FigureCardState();
}

enum ImageState {loading, error, done}
class FigureCardState extends State<FigureCard> {
  String? url = null;
  final ValueNotifier<ImageState> state = ValueNotifier(ImageState.loading);

  @override
  void initState() {
    super.initState();

    getImageUrl(widget.date.toDate()).then((res) {url = res; setState(() {

    });}, onError: (_) {
      state.value = ImageState.error;
      if (state.value != ImageState.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          state.value = ImageState.error;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/daily', arguments: widget.date.toDate()),
      child: AppContainer(
        child: AspectRatio(
          aspectRatio: 1.27,
          child: Stack(
            children: [
              // immagine che riempie tutto lo spazio e si allinea in alto
              Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: url ?? '',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    placeholder: (context, _) {
                      return SizedBox.expand(
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      );
                    },
                    errorWidget: (context, _, __) {
                      if(url == null && state.value == ImageState.loading)
                        return SizedBox.expand(
                          child: Container(
                            color: Colors.grey[300],
                          ),
                        );
                      if (state.value != ImageState.error) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          state.value = ImageState.error;
                        });
                      }
                      return SizedBox.expand(
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      );
                    },
                    imageBuilder: (_, image) {
                      if (state.value != ImageState.done && !loading) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          state.value = ImageState.done;
                          setState(() {

                          });
                        });
                      }
                      return SmartImage(image: Image(image: image), focusX: 0.45, focusY: 0, zoom: 2);
                    },
                  )
              ),
              // icona salvata, spostata verso l'alto per compensare padding interno
              if(state.value == ImageState.done)
                Positioned(
                  left: 20,
                  top: 0,
                  child: Transform.translate(
                    offset: const Offset(0, -6), // sposta l'icona verso l'alto
                    child: Icon(
                      CustomIcons.selectedSaved,
                      color: context.colorScheme.tertiary,
                      size: 35,
                    ),
                  ),
                ),
              if(state.value == ImageState.done)
                Positioned(
                    bottom: 10,
                    right: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppContainer(
                            alignment: Alignment.center,
                            color: darkTheme.colorScheme.secondary.withAlpha(161),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(widget.name ?? '', style: TextStyles.day.value,),
                            )
                        )
                      ],
                    )
                )
            ],
          ),
        ),
      ),
    );
  }
}

class SmartImage extends StatelessWidget {
  final Widget image;
  final double focusX; // 0 → 1
  final double focusY; // 0 → 1
  final double zoom;

  const SmartImage({
    super.key,
    required this.image,
    required this.focusX,
    required this.focusY,
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Transform.scale(
        scale: 1.875,
        alignment: Alignment(
          0.57 * 2 - 1,
          0.23 * 2 - 1,
        ),
        child: /*Image.asset(
          'assets/images/test.jpeg',
          //fit: BoxFit.contain,
          width: 160,
          height: 141,
        ),*/
        image
      ),
    );
  }
}
