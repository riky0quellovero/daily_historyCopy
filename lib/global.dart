import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

export 'package:daily_history/l10n/l10n.dart';
export 'package:daily_history/fontIcons.dart';
import 'package:daily_history/themes/themeProvider.dart';
export 'package:daily_history/themes/themeProvider.dart';

///global instance for firestore
late FirebaseFirestore firestore;

///custom application container with preset values
class AppContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final BoxDecoration? decoration;
  final BoxDecoration? foregroundDecoration;
  final double? height;
  final double? width;

  const AppContainer({
    super.key,
    this.child,
    this.borderRadius = 25,
    this.color,
    this.padding,
    this.margin,
    this.constraints,
    this.alignment,
    this.decoration,
    this.foregroundDecoration,
    this.height,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: color,
        padding: padding,
        margin: margin,
        constraints: constraints,
        alignment: alignment,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        child: child,
        height: height,
        width: width,
      ),
    );
  }
}

///used to manage [AppPage] top bar displacement
enum BarConfigurations {
  none,
  small,
  large
}

///custom base for app pages
///used to show the title and basic app layout
///use [showBackButton] to allow to get back with the navigator
///use [barConfiguration] to manage the top bar displacement
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = false,
    this.barConfiguration = BarConfigurations.none,
  });

  final String title;
  final Widget child;
  final bool showBackButton;
  final BarConfigurations barConfiguration;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 3, right: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                //back arrow
                if (showBackButton)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                //title
                Center(
                  child: Text(
                    title,
                    style: TextStyles.barTitle.value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            //divider
            switch (barConfiguration) {
              BarConfigurations.small =>
              const Divider(indent: 70, endIndent: 70,),
              BarConfigurations.large => const Divider(indent: 15, endIndent: 15,),
              BarConfigurations.none => const SizedBox.shrink()
            },
            //child
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: child,
              ),
            ),
          ],
        ),
      )
    );
  }
}

///custom slide button.
///show [option1] and [option2] on the sides.
///call [onPressed] on every click
class SwipeButton extends StatefulWidget {
  final String option1, option2;
  final Function(bool) onPressed;
  final bool preset;

  const SwipeButton(this.option1, this.option2, {required this.onPressed, this.preset = true, super.key});

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  late bool selected;
  var stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selected = widget.preset;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.43,
      child: AppContainer(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Stack(
            key: stackKey,
            children: [
              //rectangle selector
              Positioned.fill(
                child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: selected ? Alignment.centerLeft : Alignment
                        .centerRight,
                    child: FractionallySizedBox(
                        widthFactor: 0.55,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AppContainer(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        )
                    )
                ),
              ),
              //selectable elements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() => selected = true);
                        widget.onPressed(selected);
                      },
                      child: Padding(
                        padding: const  EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                        child: Text(
                          widget.option1,
                          style: TextStyles.settingsButton.value.copyWith(color: (!selected && ThemeProvider.instance.theme == SelectedTheme.light) ? Colors.black : Colors.white),
                        ),
                      )
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() => selected = false);
                        widget.onPressed(selected);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.option2,
                          style: TextStyles.settingsButton.value.copyWith(color: (selected && ThemeProvider.instance.theme == SelectedTheme.light) ? Colors.black : Colors.white),
                        ),
                      )
                  ),
                ],
              )
            ],
          ),
        ),
    ));
  }
}