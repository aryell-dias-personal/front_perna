import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/helpItem.dart';

HelpItem getHelpRoot(context) {
  return HelpItem(
    content: AppLocalizations.of(context).translate("helpRootContent"),
    subItems: <HelpItem>[
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpMarkerSmallTitle"),
        title: AppLocalizations.of(context).translate("helpMarkerTitle"),
        content: AppLocalizations.of(context).translate("helpMarkerContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpMakeOrderSmallTitle"),
        title: AppLocalizations.of(context).translate("helpMakeOrderTitle"),
        content: AppLocalizations.of(context).translate("helpMakeOrderContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpCreateExpedientSmallTitle"),
        title: AppLocalizations.of(context).translate("helpCreateExpedientTitle"),
        content: AppLocalizations.of(context).translate("helpCreateExpedientContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpCenterMapSmallTitle"),
        title: AppLocalizations.of(context).translate("helpCenterMapTitle"),
        content: AppLocalizations.of(context).translate("helpCenterMapContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpRemoveMarkerSmallTitle"),
        title: AppLocalizations.of(context).translate("helpRemoveMarkerTitle"),
        content: AppLocalizations.of(context).translate("helpRemoveMarkerContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpWhenToOrderSmallTitle"),
        title: AppLocalizations.of(context).translate("helpWhenToOrderTitle"),
        content: AppLocalizations.of(context).translate("helpWhenToOrderContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpStartRouteSmallTitle"),
        title: AppLocalizations.of(context).translate("helpStartRouteTitle"),
        content: AppLocalizations.of(context).translate("helpStartRouteContent"),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate("helpConsultHistorySmallTitle"),
        title: AppLocalizations.of(context).translate("helpConsultHistoryTitle"),
        content: AppLocalizations.of(context).translate("helpConsultHistoryContent")
      )
    ],
    title: AppLocalizations.of(context).translate("helpRootTitle"),
    smallTitle: AppLocalizations.of(context).translate("help"),
    iconData: Icons.help_outline
  );
}