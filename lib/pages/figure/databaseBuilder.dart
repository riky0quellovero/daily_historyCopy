import 'package:daily_history/l10n/localeProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:daily_history/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
//TODO: DELETE THE USERNAME FROM THE LIST IN SOME WAY WHEN THE USER GET DELETED && CREATE USER DOC
//====================================================== TAGS ============================================================

//TODO: implement tags
//TODO: manage db exceptions

var _tagColors = [
  Colors.red,
  Colors.green,
  Colors.grey
];

var _tagTexts = [
  "dumb",
  "crazy",
  "stupid"
];

class UpvoteManager {

}

Future<String?> getImageUrl(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();

  //TODO: remove
  await Future.delayed(const Duration(seconds: 3));

  print(date.millisecondsSinceEpoch);

  // Provo a leggere l'URL dalla cache locale
  final cachedUrl = prefs.getString('avatar_url_${date.toString()}');
  if (cachedUrl != null) {
    return cachedUrl;
  }



  try {
    // Se non c'è nella cache, prendo il documento Firestore
    final url = await FirebaseStorage.instance.ref('figureImages/test.png').getDownloadURL();

    if (url != null) {
      // Salvo l'URL nella cache locale per futuri accessi
      await prefs.setString('avatar_url_${date.toString()}', url);
    }
    print(cachedUrl);
    return url;
  } catch (e) {
    print('Errore nel recuperare URL immagine: $e');
    return null;
  }
}

Future<DocumentSnapshot> docFetch(DocumentReference docRef) async {
  try {
    // 1. Prova cache
    final cached = await docRef.get(
      const GetOptions(source: Source.cache),
    );

    if (cached.exists) {
      return cached;
    }
  } catch (e) {
    // cache può fallire (es. mai scaricato)
  }

  // 2. fallback server
  return await docRef.get();
}

Future<Widget> getFigureTags(DateTime date) async {
  //final data = (await FirebaseDatabase.instance.ref('figures/${date.millisecondsSinceEpoch}/tags').get()).value!;
  //List<int> tags = (data as String).split(',').map(int.parse).toList(growable: false);

  List<int> tags;
  var doc = firestore.collection('figure').doc(date.millisecondsSinceEpoch.toString());
  var data = await docFetch(doc);
  tags = List<int>.from(data.get('tags'));

  print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  print(tags);
  var wid = List<Widget>.generate(tags.length*2-1, (index) {
    if(index % 2 == 0)
    return AppContainer(
      borderRadius: 5,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: _tagColors[index~/2],
      child: Text(_tagTexts[index~/2], style: TextStyles.tags.value,),
    );
    return const SizedBox(width: 10);
  });
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: wid,
    ),
  );
}

Future<Widget> getName(DateTime date) async {
  var doc = firestore.collection('figure').doc(date.millisecondsSinceEpoch.toString());
  var data = await docFetch(doc);
  var name = data.get('language.${LocaleProvider.instance.locale.languageCode}.name');

  print('done');

  return Text(
    name,
    style: TextStyles.figureName.value,
  );
}

//====================================================== PARAGRAPHS ============================================================

Future<List<Widget>> getPageContentW(DateTime date) async {
  String paragraphs;

  var doc = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default'
  ).collection('figure').doc(date.millisecondsSinceEpoch.toString());
  var data = await docFetch(doc);
  paragraphs = data.get('language.${LocaleProvider.instance.locale.languageCode}.paragraph');

  return await compute(getPageContent, paragraphs);
}

List<Widget> getPageContent(String data) {
  String paragraphs = data;

  final List<Widget> widgets = [];
  final RegExp pattern = RegExp(r'\\([ac-hj-z])'); // cattura sequenze tipo \t, \e, \c, \s
  int index = 0;

  String? currentTag;
  int? tagStartIndex;


  while (index < paragraphs.length) {
    final match = pattern.matchAsPrefix(paragraphs, index);

    if (match != null) {
      final tag = match.group(1)!;

      // Se è un tag riconosciuto (\t, \e, \c, \s)
      if (['t', 'e', 'c', 's'].contains(tag)) {
        if (currentTag == null) {
          // Apertura di un blocco
          currentTag = tag;
          tagStartIndex = match.end;
        } else if (currentTag == tag) {
          // Chiusura del blocco -> estrai contenuto
          final content = paragraphs.substring(tagStartIndex!, match.start);
          widgets.add(_buildWidgetForTag(currentTag, content));
          currentTag = null;
          tagStartIndex = null;
        } else {
          // Se si apre un nuovo tag prima di chiudere il precedente, trattalo come testo normale
          widgets.add(_buildWidgetForTag(null, '\\$tag'));
        }

        index = match.end;
        continue;
      }
    }

    // Se non siamo in un blocco, accumula testo normale
    if (currentTag == null) {
      // Prendi tutto fino al prossimo backslash o fine stringa
      final nextSlash = paragraphs.indexOf('\\', index);
      final end = nextSlash == -1 ? paragraphs.length : nextSlash;
      final textSegment = paragraphs.substring(index, end);
      if (textSegment.isNotEmpty) widgets.add(_buildWidgetForTag(null, textSegment));
      index = end;
    } else {
      // Siamo dentro un blocco, vai avanti finché non trovi il backslash
      final nextSlash = paragraphs.indexOf('\\', index);
      index = nextSlash == -1 ? paragraphs.length : nextSlash;
    }
  }

  // Se c’è un blocco non chiuso, aggiungilo come testo normale
  if (currentTag != null && tagStartIndex != null) {
    widgets.add(_buildWidgetForTag(null, paragraphs.substring(tagStartIndex - 2))); // include il backslash iniziale
  }
  return widgets;
}

/// Restituisce un widget diverso in base al tipo di tag.
Widget _buildWidgetForTag(String? tag, String content) {

  return Padding(
    padding: EdgeInsets.only(bottom: 8, top: (tag == 't') ? 20 : 8),
    child: switch (tag) {
      't'=> _TitleParagraph(content),
      'e'=> BulletParagraph(content),
      'c' => CitParagraph(content),
      's' => BarParagraph(content),
      _ => FormattedText(content),
    }
  );

}

//====================================================== WIDGETS ============================================================

class FormattedText extends StatelessWidget {
  final String text;

  const FormattedText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final spans = _parseText(text);
    return Text.rich(TextSpan(children: spans));
  }

  List<TextSpan> _parseText(String input) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'(\^b|\^i)|([^^]+)');
    final matches = regex.allMatches(input);

    bool bold = false;
    bool italic = false;

    for (final match in matches) {
      final tag = match.group(1);
      final text = match.group(2);

      if (tag != null) {
        if (tag == r'^b') {
          bold = !bold;
        } else if (tag == r'^i') {
          italic = !italic;
        }
        continue;
      }

      if (text != null) {
        TextStyle style = TextStyles.text.value;

        if (bold && italic) {
          style = style.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          );
        } else if (bold) {
          style = style.copyWith(fontWeight: FontWeight.bold);
        } else if (italic) {
          style = style.copyWith(fontStyle: FontStyle.italic);
        }

        spans.add(TextSpan(text: text, style: style));
      }
    }

    return spans;
  }
}


class _Paragraph extends StatelessWidget {
  final text;

  const _Paragraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return FormattedText(text);
  }
}

class _TitleParagraph extends StatelessWidget {
  final text;

  const _TitleParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyles.title.value,);
  }
}

class BarParagraph extends StatelessWidget {
  final String text;

  const BarParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const VerticalDivider(
            color: Color.fromARGB(255, 207, 69, 69),
            thickness: 2,
            width: 20,
          ),
          Expanded(
            child: FormattedText(text),
          ),
        ],
      ),
    );
  }
}



class BulletParagraph extends StatelessWidget {
  late final List<String> paragraphs;

  BulletParagraph(String text, {super.key}) {
    paragraphs = text.split(r'^p');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(paragraphs.length, (index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //bullet
              Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Transform.rotate(
                    angle: 45 * 3.1415926535 / 180,
                    child: Container(
                      color: context.colorScheme.tertiary,
                      height: 6,
                      width: 6,
                    ),
                  ),
                ),

              //text
              Expanded(
                child: FormattedText(paragraphs[index]),
              )
            ],
          );
        })
    );
  }
}

class CitParagraph extends StatelessWidget {
  late final String cit;
  late final String author;

  CitParagraph(String text, {super.key}) {
    var result = text.split(r'^p');
    cit = result[0];
    author = result[1];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AppContainer(
              color: (ThemeProvider.instance.theme == SelectedTheme.light) ? context.colorScheme.secondary : null,
              decoration: (ThemeProvider.instance.theme == SelectedTheme.dark) ? BoxDecoration(
                  border: BoxBorder.all(color: context.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(25)
              ) : null,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cit, style: TextStyles.cit.value,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text('-' + author, style: TextStyles.citSign.value,),
                      )
                    ],
                  )
              )
          ),
          Positioned(
            top: -26,
            left: 25,
            child: Text('“', style: TextStyles.title.value.copyWith(fontSize: 60),),
          )
        ],
      ),
    );
  }
}