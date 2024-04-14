import 'package:chat_app/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageBottomSheet extends StatelessWidget {
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
                provider.changeLanguage("ar");
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.arabic,
                    style: provider.language == "en" ? GoogleFonts.novaSquare() : GoogleFonts.cairo(),
                  ),
                  const Spacer(),
                  Icon(
                    provider.language == "ar"
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
                provider.changeLanguage("en");
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.english,
                    style: provider.language == "en" ? GoogleFonts.novaSquare() : GoogleFonts.cairo(),
                  ),
                  const Spacer(),
                  Icon(
                    provider.language == "en"
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

  Widget getUnSelectedItemWidget(String text, BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
