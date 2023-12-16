import 'package:chat_app/shared/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';


class ThemeBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                provider.changeTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Text(
                          AppLocalizations.of(context)!.darkMood,
                          style:Theme.of(context).textTheme.bodyMedium,
                        ),
                  const Spacer(),
                  Icon(
                    provider.themeMode == ThemeMode.dark
                        ? Icons.check_circle_outline
                        : Icons.circle_outlined,
                    size: 35,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            InkWell(
              onTap: () {
                provider.changeTheme(ThemeMode.light);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                   Text(
                          AppLocalizations.of(context)!.lightMood,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                  const Spacer(),
                  Icon(
                    provider.themeMode == ThemeMode.light
                        ? Icons.check_circle_outline
                        : Icons.circle_outlined,
                    size: 35,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
