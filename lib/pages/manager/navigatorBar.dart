import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:daily_history/global.dart';


/// custom animated bottom navigation bar.
class NavigatorBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  const NavigatorBar({required this.navKey, super.key});

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  final ValueNotifier<int> selectedPage = ValueNotifier(0);

  //buttons values
  final List<GlobalKey> keys = List.generate(4, (_) => GlobalKey());

  final List<String> texts = ['Home', 'Saved', 'Calendar', 'Settings'];
  final List<String> routes = ['/daily', '/saved', '/calendar', '/settings'];

  final List<IconData> icons = [
    CustomIcons.home,
    CustomIcons.saved,
    CustomIcons.calendar,
    CustomIcons.settings,
  ];

  final List<IconData> activeIcons = [
    CustomIcons.selectedHome,
    CustomIcons.selectedSaved,
    CustomIcons.selectedCalendar,
    CustomIcons.selectedSettings,
  ];

  //ButtonBar sizes
  final Map<String, Size> _measuredSizes = {};

  @override
  void initState() {
    super.initState();
    //trigger a rebuild at app start as the rectangle values are null
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  //used by buttons to record their current size
  void _onSizeChanged(String key, Size size) {
    setState(() {
      _measuredSizes[key] = size;
    });
  }

  //calculate the position for the rectangle indicator
  double _calculateButtonPosition(int targetIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 20; // 15 padding * 2

    //calculate button widths
    List<double> buttonWidths = [for(int i = 0; i < 4; i++) _getButtonWidth(i)];

    //calculate total button width
    final totalButtonWidth = buttonWidths.reduce((a, b) => a + b);

    // calculate remaining space
    final remainingSpace = availableWidth - totalButtonWidth;

    //space between widgets
    final spaceUnit = remainingSpace / 4;

    //space before widgets (alf of mid widgets in space around)
    double position = spaceUnit / 2;

    //final calc
    for (int i = 0; i < targetIndex; i++) {
      position += buttonWidths[i] + spaceUnit;
    }

    return position;
  }

  double _getButtonWidth(int index) {
    final selectedKey = 'button_${index}_selected';
    final unselectedKey = 'button_${index}_unselected';

    Size? size;
    if (selectedPage.value == index) {
      size = _measuredSizes[selectedKey];
    } else {
      size = _measuredSizes[unselectedKey];
    }

    return size?.width ?? 55.0;
  }

  Widget _buildButton(int index, bool isSelected) {
    return AppContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[index], size: 35, color: Colors.white),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Text(
              texts[index],
              style: TextStyles.settingsButton.value,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      child: Stack(
        children: [
          //invisible widgets for measuring system
          ...List.generate(4, (i) => [
            Offstage(
              offstage: true,
              child: MeasureSize(
                onChange: (size) => _onSizeChanged('button_${i}_selected', size),
                child: _buildButton(i, true),
              ),
            ),
            Offstage(
              offstage: true,
              child: MeasureSize(
                onChange: (size) => _onSizeChanged('button_${i}_unselected', size),
                child: _buildButton(i, false),
              ),
            ),
          ]).expand((x) => x),

          //navigation bar
          AppContainer(
            color: context.colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  //animated selector
                  ValueListenableBuilder(
                    valueListenable: selectedPage,
                    builder: (context, value, child) {
                      return AnimatedPositioned(
                        left: _calculateButtonPosition(value),
                        width: _getButtonWidth(value),
                        height: 40,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AppContainer(
                          height: 40,
                          color: context.colorScheme.tertiary,
                        ),
                      );
                    },
                  ),

                  //Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (i) {
                      return BarButton(
                        navKey: widget.navKey,
                        key: keys[i],
                        selectedPage: selectedPage,
                        index: i,
                        icon: icons[i],
                        activeIcon: activeIcons[i],
                        text: texts[i],
                        route: routes[i],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarButton extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;
  final ValueNotifier<int> selectedPage;
  final IconData icon;
  final IconData activeIcon;
  final String text;
  final int index;
  final String route;

  const BarButton({
    super.key,
    required this.navKey,
    required this.selectedPage,
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.text,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selectedPage.value == index) return;
        selectedPage.value = index;

        navKey.currentState!.pushNamedAndRemoveUntil(
            route, (Route<dynamic> route) => false);
      },
      child: ValueListenableBuilder(
        valueListenable: selectedPage,
        builder: (context, value, _) {
          final isSelected = value == index;
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AppContainer(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if(isSelected) ...[
                    Icon(activeIcon, size: 35, color: Colors.white,),
                    Text(
                        text,
                        style: TextStyles.settingsButton.value.copyWith(color: Colors.white),
                    )
                  ] else
                    ...[
                      Icon(icon, size: 35, color: context.colorScheme.onPrimary),
                    ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget per misurare le dimensioni
typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderProxyBox createRenderObject(BuildContext context) {
    return _RenderSizeObserver(onChange);
  }
}

class _RenderSizeObserver extends RenderProxyBox {
  final OnWidgetSizeChange onChange;
  Size? _oldSize;

  _RenderSizeObserver(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size ?? Size.zero;
    if (_oldSize != newSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}


//smoother version for text appearing
/*AnimatedSize(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: isSelected
      ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ],
      )
      : const SizedBox.shrink(),
);*/