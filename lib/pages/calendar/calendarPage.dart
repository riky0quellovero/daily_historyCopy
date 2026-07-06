import 'package:daily_history/global.dart';
import 'package:flutter/material.dart';

//TODO: current day with new design
//TODO: update starting time

class Month {
  final String name;
  final int days;

  Month(this.name, this.days);
}

class CalendarPage extends StatelessWidget {
  CalendarPage({super.key});

  final int currentDay = DateTime.now().day;
  final int currentMonth = DateTime.now().month;
  static const int startYear = 2020;

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      Month(context.l10n.jan, 31),
      Month(context.l10n.feb, 28),
      Month(context.l10n.mar, 31),
      Month(context.l10n.apr, 30),
      Month(context.l10n.may, 31),
      Month(context.l10n.jun, 30),
      Month(context.l10n.jul, 31),
      Month(context.l10n.aug, 31),
      Month(context.l10n.sep, 30),
      Month(context.l10n.oct, 31),
      Month(context.l10n.nov, 30),
      Month(context.l10n.dec, 31),
    ];

    final weekdays = [
      context.l10n.mon,
      context.l10n.tue,
      context.l10n.wen,
      context.l10n.thu,
      context.l10n.fri,
      context.l10n.sat,
      context.l10n.sun,
    ];

    final currentYear = DateTime.now().year;
    final totalMonths = (currentYear - startYear) * 12 + currentMonth;

    return AppPage(
      title: context.l10n.calendar,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 30),
        itemCount: totalMonths,
        itemBuilder: (context, index) {
          final year = startYear + (totalMonths - 1 - index) ~/ 12;
          final monthIndex = (totalMonths - 1 - index) % 12;
          final month = months[monthIndex];

          final daysInMonth = monthIndex == 1 && isLeapYear(year)
              ? 29
              : month.days;

          final firstWeekday = (DateTime(year, monthIndex + 1, 1).weekday - 1) % 7;
          final offset = firstWeekday;
          final totalCells = ((index != 0) ? daysInMonth : currentDay) + offset;

          return Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(month.name, style: TextStyles.month.value),
                    const SizedBox(width: 10),
                    if (monthIndex == 0)
                      Text('$year', style: TextStyles.year.value),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekdays
                        .map((d) => Text(d, style: TextStyles.day.value))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 5),
                GridView.builder(
                  padding: const EdgeInsets.only(bottom: 15),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, mainAxisSpacing: 25, crossAxisSpacing: 25),
                  itemCount: totalCells,
                  itemBuilder: (context, cellIndex) {
                    final day = cellIndex - offset + 1;
                    if (cellIndex < offset) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.colorScheme.onSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: (ThemeProvider.instance.theme.value) ? context.colorScheme.secondary : context.colorScheme.onSecondary, width: 2),
                        ),
                        child: Text('${day+months[(monthIndex+11)%12].days}', style: TextStyles.dayNum.value),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/daily', arguments: DateTime(year, monthIndex + 1, day)),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (ThemeProvider.instance.theme.value) ? Theme.of(context).colorScheme.secondary : context.colorScheme.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 2),
                          ),
                          child: Text('$day', style: TextStyles.dayNum.value),
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
              ],
            ),
          );
        },
      ),
    );

  }
}
