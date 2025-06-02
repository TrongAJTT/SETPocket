import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/screens/random_tools/password_generator.dart';
import 'package:my_multi_tools/screens/random_tools/number_generator.dart';
import 'package:my_multi_tools/screens/random_tools/yes_no_generator.dart';
import 'package:my_multi_tools/screens/random_tools/coin_flip_generator.dart';
import 'package:my_multi_tools/screens/random_tools/rock_paper_scissors_generator.dart';
import 'package:my_multi_tools/screens/random_tools/dice_roll_generator.dart';
import 'package:my_multi_tools/screens/random_tools/color_generator.dart';
import 'package:my_multi_tools/screens/random_tools/latin_letter_generator.dart';
import 'package:my_multi_tools/screens/random_tools/playing_card_generator.dart';
import 'package:my_multi_tools/screens/random_tools/date_generator.dart';
import 'package:my_multi_tools/screens/random_tools/time_generator.dart';
import 'package:my_multi_tools/screens/random_tools/date_time_generator.dart';

class RandomToolsScreen extends StatelessWidget {
  const RandomToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 1;
    } else if (width < 1024) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.random),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: width < 600 ? 3 : 2.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 12, // Number of random tools
        itemBuilder: (context, index) {
          Widget screen;
          String title;
          IconData icon;
          Color iconColor;

          switch (index) {
            case 0:
              screen = const PasswordGeneratorScreen();
              title = loc.passwordGenerator;
              icon = Icons.password_rounded;
              iconColor = Colors.purple;
              break;
            case 1:
              screen = const NumberGeneratorScreen();
              title = loc.numberGenerator;
              icon = Icons.tag;
              iconColor = Colors.blue;
              break;
            case 2:
              screen = const YesNoGeneratorScreen();
              title = loc.yesNo;
              icon = Icons.question_answer;
              iconColor = Colors.orange;
              break;
            case 3:
              screen = const CoinFlipGeneratorScreen();
              title = loc.flipCoin;
              icon = Icons.monetization_on;
              iconColor = Colors.amber;
              break;
            case 4:
              screen = const RockPaperScissorsGeneratorScreen();
              title = loc.rockPaperScissors;
              icon = Icons.sports_mma;
              iconColor = Colors.brown;
              break;
            case 5:
              screen = const DiceRollGeneratorScreen();
              title = loc.rollDice;
              icon = Icons.casino;
              iconColor = Colors.red;
              break;
            case 6:
              screen = const ColorGeneratorScreen();
              title = loc.colorGenerator;
              icon = Icons.palette;
              iconColor = Colors.green;
              break;
            case 7:
              screen = const LatinLetterGeneratorScreen();
              title = loc.latinLetters;
              icon = Icons.text_fields;
              iconColor = Colors.teal;
              break;
            case 8:
              screen = const PlayingCardGeneratorScreen();
              title = loc.playingCards;
              icon = Icons.style;
              iconColor = Colors.indigo;
              break;
            case 9:
              screen = const DateGeneratorScreen();
              title = loc.dateGenerator;
              icon = Icons.calendar_today;
              iconColor = Colors.cyan;
              break;
            case 10:
              screen = const TimeGeneratorScreen();
              title = loc.timeGenerator;
              icon = Icons.access_time;
              iconColor = Colors.deepOrange;
              break;
            case 11:
              screen = const DateTimeGeneratorScreen();
              title = loc.dateTimeGenerator;
              icon = Icons.date_range;
              iconColor = Colors.deepPurple;
              break;
            default:
              screen = const SizedBox();
              title = "";
              icon = Icons.error;
              iconColor = Colors.grey;
          }

          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.2),
                      radius: 24,
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
