import 'package:flutter/material.dart';

import 'package:daily_history/global.dart';
import 'package:daily_history/notifications/notificationsProvider.dart';

/// app page for notification settings
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
        showBackButton: true,
        title: context.l10n.notifications,
        barConfiguration: BarConfigurations.large,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  context.l10n.notifications,
                  style: TextStyles.notificationTitle.value,
                ),
                const Spacer(),
                SwipeButton(context.l10n.yes, context.l10n.no, onPressed: (enabled) => NotificationsProvider.instance.setNotificationEnable(enabled),),
              ],
            ),
            const SizedBox(height: 60,),
            Text(context.l10n.notificationsTime, style: TextStyles.notificationTitle.value,),
            Text(context.l10n.notificationsQuestion, style: TextStyles.settingsSubtitle.value),
            const SizedBox(height: 20,),
            _SelectableButtonRow(
              onSelected: (time) => NotificationsProvider.instance.setNotificationsTime(TimeOfDay(hour: int.parse(time.split(':',)[0]), minute: 0)),
              items: const [
                '9:00',
                '12:00',
                '18:00'
              ],
            )
          ],
        )
    );
  }
}

/// buttn row to selected notification time
class _SelectableButtonRow extends StatefulWidget {
  final List<String> items;
  final void Function(String) onSelected;

  const _SelectableButtonRow({
    super.key,
    required this.items,
    required this.onSelected,
  });

  @override
  _SelectableButtonRowState createState() => _SelectableButtonRowState();
}

class _SelectableButtonRowState extends State<_SelectableButtonRow> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.items.length, (index) {
        bool isSelected = selectedIndex == index;
        String item = widget.items[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onSelected(item);
          },
          child: AnimatedContainer(
            width: MediaQuery.of(context).size.width / 4,
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.secondary,
                width: 4,
              ),
            ),
            child: Center(
              child: Text(item, style: TextStyles.timeButton.value,),
            )
          ),
        );
      }),
    );
  }
}