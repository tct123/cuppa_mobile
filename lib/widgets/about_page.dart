/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    about_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// About Cuppa page
// - Version and build number
// - Links to GitHub, Weblate, etc.
// - Timer usage stats

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/widgets/common.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

// About Cuppa page
class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  // Build About page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        textScaleFactor: appTextScale,
        title: AppString.about_title.translate(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 1,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              shadowColor: Theme.of(context).shadowColor,
              // Teacup icon
              leading: Container(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(appIcon, fit: BoxFit.scaleDown),
              ),
              // Cuppa version and build
              title: Text(
                '$appName ${packageInfo.version} (${packageInfo.buildNumber})',
                style: textStyleHeader.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Tutorial
                  _listItem(
                    title: AppString.tutorial.translate(),
                    subtitle: AppString.tutorial_info.translate(),
                    onTap: () {
                      // Restart tutorial on Timer page
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ShowCaseWidget.of(context)
                          .startShowCase(tutorialSteps.keys.toList());
                    },
                  ),
                  listDivider,
                  // Timer stats
                  _listItem(
                    title: AppString.stats_title.translate(),
                    onTap: () => _openTimerStats(context),
                  ),
                  listDivider,
                  // How to report issues
                  _listItem(
                    title: AppString.issues.translate(),
                    subtitle: AppString.issues_info.translate(),
                    url: issuesURL,
                  ),
                  listDivider,
                  // App localization info
                  _listItem(
                    title: AppString.help_translate.translate(),
                    subtitle: AppString.help_translate_info.translate(),
                    url: translateURL,
                  ),
                  listDivider,
                  // Changelog
                  _listItem(
                    title: AppString.version_history.translate(),
                    url: versionsURL,
                  ),
                  listDivider,
                  // Link to app source code
                  _listItem(
                    title: AppString.source_code.translate(),
                    subtitle: AppString.source_code_info.translate(),
                    url: sourceURL,
                  ),
                  listDivider,
                  // App license info
                  _listItem(
                    title: AppString.about_license.translate(),
                    url: licenseURL,
                  ),
                  listDivider,
                  // Privacy policy
                  _listItem(
                    title: AppString.privacy_policy.translate(),
                    url: privacyURL,
                  ),
                  listDivider,
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  // About text linking to app website
                  child: aboutText(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // About list item
  Widget _listItem({
    required String title,
    String? subtitle,
    String? url,
    Function()? onTap,
  }) {
    return InkWell(
      child: ListTile(
        title: Text(title, style: textStyleTitle),
        subtitle:
            subtitle != null ? Text(subtitle, style: textStyleSubtitle) : null,
        trailing: url != null ? launchIcon : null,
        onTap: url != null
            ? () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
            : onTap,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        dense: true,
      ),
    );
  }

  // Open a dialog showing the timer usage stats
  Future<void> _openTimerStats(BuildContext context) async {
    // Fetch stats
    int beginDateTime = await Stats.getMetric(MetricQuery.beginDateTime);
    int totalCount = await Stats.getMetric(MetricQuery.totalCount);
    int totalTime = await Stats.getMetric(MetricQuery.totalTime);
    String morningTea = await Stats.getString(StringQuery.morningTea);
    String afternoonTea = await Stats.getString(StringQuery.afternoonTea);
    List<Stat> summaryStats = await Stats.getTeaStats(ListQuery.summaryStats);

    // Display all stats in a dialog
    if (!context.mounted) return;
    showAdaptiveDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text(AppString.stats_title.translate()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // General metrics
                Visibility(
                  visible: beginDateTime > 0,
                  child: Stats.metricWidget(
                    metricName: AppString.stats_begin.translate(),
                    metric: formatDate(beginDateTime),
                  ),
                ),
                Stats.metricWidget(
                  metricName: AppString.stats_timer_count.translate(),
                  metric: totalCount.toString(),
                ),
                Stats.metricWidget(
                  metricName: AppString.stats_timer_time.translate(),
                  metric: formatTimer(totalTime),
                ),
                Visibility(
                  visible: morningTea.isNotEmpty,
                  child: Stats.metricWidget(
                    metricName: AppString.stats_favorite_am.translate(),
                    metric: morningTea,
                  ),
                ),
                Visibility(
                  visible: afternoonTea.isNotEmpty,
                  child: Stats.metricWidget(
                    metricName: AppString.stats_favorite_pm.translate(),
                    metric: afternoonTea,
                  ),
                ),
                // Tea timer usage summary
                Visibility(
                  visible: summaryStats.isNotEmpty,
                  child: listDivider,
                ),
                for (Stat stat in summaryStats)
                  stat.toWidget(totalCount: totalCount),
              ],
            ),
          ),
          actions: [
            adaptiveDialogAction(
              isDefaultAction: true,
              text: AppString.ok_button.translate(),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );
  }
}
