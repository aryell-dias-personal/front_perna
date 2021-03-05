import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/helpItem.dart';

HelpItem getHelpRoot(BuildContext context) {
  return HelpItem(
    content: AppLocalizations.of(context).translate('help_root_content'),
    subItems: <HelpItem>[
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_marker_small_title'),
        title: AppLocalizations.of(context).translate('help_marker_title'),
        content: AppLocalizations.of(context).translate('help_marker_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_make_order_small_title'),
        title: AppLocalizations.of(context).translate('help_make_order_title'),
        content: AppLocalizations.of(context).translate('help_make_order_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_create_expedient_small_title'),
        title: AppLocalizations.of(context).translate('help_create_expedient_title'),
        content: AppLocalizations.of(context).translate('help_create_expedient_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_center_map_small_title'),
        title: AppLocalizations.of(context).translate('help_center_map_title'),
        content: AppLocalizations.of(context).translate('help_center_map_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_remove_marker_small_title'),
        title: AppLocalizations.of(context).translate('help_remove_marker_title'),
        content: AppLocalizations.of(context).translate('help_remove_marker_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_when_to_order_small_title'),
        title: AppLocalizations.of(context).translate('help_when_to_order_title'),
        content: AppLocalizations.of(context).translate('help_when_to_order_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_start_route_small_title'),
        title: AppLocalizations.of(context).translate('help_start_route_title'),
        content: AppLocalizations.of(context).translate('help_start_route_content'),
      ),
      HelpItem(
        smallTitle: AppLocalizations.of(context).translate('help_consult_history_small_title'),
        title: AppLocalizations.of(context).translate('help_consult_history_title'),
        content: AppLocalizations.of(context).translate('help_consult_history_content')
      )
    ],
    title: AppLocalizations.of(context).translate('help_root_title'),
    smallTitle: AppLocalizations.of(context).translate('help'),
    iconData: Icons.help_outline
  );
}