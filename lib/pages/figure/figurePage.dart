import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_history/global.dart';
import 'package:daily_history/pages/figure/databaseBuilder.dart';
import 'package:daily_history/pages/saved/savedProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/sch
import 'package:share_plus/share_plus.dart';eduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../analyticsManager.dart';
import '../../cookieProvider.dart';

class FigurePage extends StatelessWidget {
  final DateTime date;
  final bool showBackButton;

  //TODO: remove debug value
  FigurePage({super.key, DateTime? date})
      : date = date ?? //DateTime.now();
      DateTime.fromMillisecondsSinceEpoch(1757491200000),
        showBackButton = date != null {
    AnalyticsManager.instance.LectureMetricReader(_scrollController, Timestamp.fromDate(date!));
  }

  final ValueNotifier<bool>isPressed = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (CookieProvider.instance.pref == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) => showCustomBanner(context));
    }
//TODO: dispose controller
    return AppPage(
      showBackButton: showBackButton,
      title: 'Daily History',
      barConfiguration: BarConfigurations.small,
      child: SingleChildScrollView(
        controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedAvatar(date: date),
              const SizedBox(height: 30,),
              FutureBuilder(
                  future: Future.wait([getName(date), getFigureTags(date), getPageContentW(date)]),
                  builder: (context, snapshot) {
                    bool loading = snapshot.connectionState == ConnectionState.waiting;
                    if(loading)
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                        children: [
                          AspectRatio(
                            aspectRatio: 7.6,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: AppContainer(
                                  color: context.colorScheme.outline,
                                ),
                              )
                          ),
                          SizedBox(height: 30,),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: AppContainer(
                                color: context.colorScheme.outline,
                              ),
                            )
                          )
                        ],
                    );

                    if(snapshot.hasError) print(snapshot.error);

                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (snapshot.data?[0] ?? Text('dio1')) as Widget,
                          (snapshot.data?[1] ?? Text('dio2')) as Widget,
                          ...(snapshot.data?[2] ?? [Text('dio'), Text('dio')]) as List<Widget>,
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 3),

                              //review app
                              Expanded(
                                flex: 10,
                                child: GestureDetector(
                                  onTap: () async {
                                    Uri url;

                                    //TODO: insert the actual app ids

                                    if (Platform.isAndroid) {
                                      // Reindirizza direttamente all'app Play Store se presente, altrimenti via browser
                                      url = Uri.parse("https://play.google.com/store/apps/details?id=AndroidAppId");
                                    } else if (Platform.isIOS) {
                                      // Reindirizza all'App Store di Apple
                                      url = Uri.parse("https://apps.apple.com/app/IosAppId");
                                    } else {
                                      return;
                                    }

                                    // Verifica se l'URL può essere aperto e lo lancia
                                    if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication, // Forza l'apertura dello store esterno
                                    );
                                    } else {
                                    throw 'Impossibile aprire lo store: $url';
                                    }
                                  },
                                  child: AppContainer(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    color: context.colorScheme.secondary,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.l10n.reviewApp,
                                          style: TextStyles.share.value,
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(CustomIcons.review, color: Colors.black, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(flex: 1),

                              //share button
                              Expanded(
                                flex: 10,
                                child:
                                GestureDetector(
                                  onTap: () async {
                                    // Personalizza il testo del messaggio e i link della tua app
                                    //TODO: finalize and localize message
                                    const String messaggio =
                                        "Ehi! Guarda questa app fantastica, devi provarla assolutamente! \n\n"
                                        "Scaricala per Android: https://play.google.com/store/apps/details?id=IL_TUO_PACCHETTO_ANDROID \n"
                                        "Scaricala per iOS: https://apps.apple.com/app/idID_APP_IOS";

                                    // Mostra il foglio di condivisione nativo
                                    final box = context.findRenderObject() as RenderBox?;

                                    await Share.share(
                                      messaggio,
                                      subject: 'Scarica la mia App!', // Oggetto (usato principalmente se condividono via Email)
                                      // sharePositionOrigin è fondamentale su iPad per evitare crash:
                                      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                                    );
                                    //TODO: implement share and fulfill analytics
                                    AnalyticsManager.instance.shareTracing(contenutoId: date.millisecondsSinceEpoch.toString(), tipoContenuto: 'share', metodoCondivisione: 'idk');
                                  },
                                  child: AppContainer(
                                    //alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    color: context.colorScheme.secondary,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          context.l10n.share,
                                          style: TextStyles.share.value,
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.share, color: Colors.black, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(flex: 3,)
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(
                              color: context.colorScheme.onPrimary,
                            ),
                          ),
                          Center(
                            child: Text(
                              context.l10n.reviewText,
                              style: TextStyles.review.value,
                            ),
                          ),
                          StarBar(date: date.toString())
                        ],
                      ),
                    );
                  }
              ),

            ],
          )
        )

    );
  }
}

class StarBar extends StatefulWidget {
  const StarBar({required this.date, super.key});
  final String date;

  @override
  State<StarBar> createState() => _StarBarState();
}

class _StarBarState extends State<StarBar> {
  final ValueNotifier<int> _rating = ValueNotifier(0);
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _rating.dispose();
    super.dispose();
  }

  void _onStarTap(int index) {
    if(FirebaseAuth.instance.currentUser == null) return;
    if (_rating.value == index + 1) return;
    _rating.value = index + 1;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if(FirebaseAuth.instance.currentUser == null) return;
      firestore.collection('figure').doc(widget.date).collection('reviewers').doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'rating': '${_rating.value}'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
              (index) {
            return GestureDetector(
              onTap: () => _onStarTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ValueListenableBuilder(
                  valueListenable: _rating,
                  builder: (context, _, __) {
                    final isFilled = _rating.value >= index + 1;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        key: ValueKey(isFilled),
                        size: 34,
                        color: context.colorScheme.onPrimary,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CachedAvatar extends StatefulWidget {
  final DateTime date;
  const CachedAvatar({required this.date, super.key});

  @override
  State<CachedAvatar> createState() => _CachedAvatarState();
}

enum ImageState {loading, error, done}

class _CachedAvatarState extends State<CachedAvatar> {
  final ValueNotifier<ImageState> state = ValueNotifier(ImageState.loading);
  String? url;
  final ValueNotifier<bool> isPressed = ValueNotifier(false);

  @override initState() {
    super.initState();

    getImageUrl(widget.date).then((res) {url = res; setState(() {});}, onError: (_) {
      state.value = ImageState.error;
      if (state.value != ImageState.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          state.value = ImageState.error;
        });
      }
    });
  }

  Widget loadingWidget = AspectRatio(
    aspectRatio: 1.63,
    child: Image.asset(
        'assets/imageLoader.gif'
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: state,
      builder: (context, value, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: url ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, _) {
                      return loadingWidget;
                    },
                    errorWidget: (context, _, __) {
                      if(url == null && state.value == ImageState.loading)
                        return loadingWidget;
                      if (state.value != ImageState.error) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          state.value = ImageState.error;
                        });
                      }
                      return Image.asset(
                          'assets/imageLoader.gif'
                      );
                    },
                    imageBuilder: (_, image) {
                      if (state.value != ImageState.done) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          state.value = ImageState.done;
                        });
                      }
                      return Image(image: image);
                    },
                  ),
                ),
              ),
            ),
            if(state.value == ImageState.done)
              Positioned(
                top: 12,
                left: 12,
                child: ValueListenableBuilder<bool>(
                  valueListenable: isPressed,
                  builder: (context, value, _) {
                    return GestureDetector(
                      onTap: () {
                        isPressed.value = !isPressed.value;
                        SavedProvider.instance.addSaved(widget.date.toString());
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          CustomIcons.selectedSaved,
                          key: ValueKey<bool>(value),
                          color: value ? Theme
                              .of(context)
                              .colorScheme
                              .tertiary : Colors.grey, //da mettere white
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
            //TODO: put style on both and then make disapper with loading
            Positioned(
              bottom: -12,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    '${widget.date.day}/${widget.date.month}/${widget.date.year}',
                    style: TextStyles.title.value.copyWith(
                        color: state.value != ImageState.done ? context.colorScheme.secondary : TextStyles.title.value.color
                    )
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: VoteBar()
              ),
            ),
          ],
        );
      },
    );
  }
}

enum VoteState {
  none,
  upVote,
  downVote
}

class VoteBar extends StatefulWidget {
  @override
  State<VoteBar> createState() => _VoteBarState();
}

class _VoteBarState extends State<VoteBar> {
  VoteState voteState = VoteState.none;

  Timer? _debounce;
  bool send = false;

  void _onVoteChanged(VoteState newState) {
    if (voteState == newState || send) return;

    setState(() {
      voteState = newState;
    });

    _debounce?.cancel();

    _debounce = Timer(const Duration(seconds: 5), () async {
      await _saveVote();
    });
  }

  Future<void> _saveVote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    //TODO: date
    try {
      await firestore
          .collection('figure')
          .doc(DateTime.fromMillisecondsSinceEpoch(1757491200000).millisecondsSinceEpoch.toString()).collection('likers').doc(uid)
          .set({
        'liked': voteState == VoteState.upVote ? true : false
      });
      send = true;
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _onVoteChanged(VoteState.upVote),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: voteState == VoteState.upVote
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const Icon(Icons.arrow_circle_right, size: 18),
            secondChild: const Icon(Icons.arrow_circle_up_outlined, size: 18),
          ),
        ),
        const SizedBox(width: 4),
        const SizedBox(
          height: 14,
          child: VerticalDivider(thickness: 1, width: 8),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _onVoteChanged(VoteState.downVote),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: voteState == VoteState.downVote
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const Icon(Icons.arrow_drop_down_circle, size: 18),
            secondChild: const Icon(Icons.arrow_circle_down_outlined, size: 18),
          ),
        ),
      ],
    );
  }
}

/*
class VoteButton extends StatelessWidget {
  const VoteButton(this.voteState, {super.key});

  final VoteState
  final ValueNotifier<VoteState> voteState;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ,
    )
  }
}*/