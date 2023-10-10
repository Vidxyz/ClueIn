import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:cluein_app/src/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static const String routeName = "about";
  
  final Color primaryAppColorSettingsValue;

  const AboutPage({
    super.key,
    required this.primaryAppColorSettingsValue,
  });

  static Route<bool> route(Color primaryAppColorSettingsValue) => MaterialPageRoute(
    settings: const RouteSettings(
        name: routeName
    ),
    builder: (_) => AboutPage(primaryAppColorSettingsValue: primaryAppColorSettingsValue),
  );

  @override
  State<StatefulWidget> createState() {
    return AboutPageState();
  }

}

class AboutPageState extends State<AboutPage> {

  _appIcon() {
    return Center(
      child: CircleAvatar(
        radius: 100,
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage("assets/icon.png")
              ),
            ),
          ),
        ),
      ),
    );
  }

  _creatorIcon() {
    return GestureDetector(
      onTap: () async {
        var url = ConstantUtils.playStoreUrl;
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
        else {
          throw "Could not launch $url";
        }
      },
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: AssetImage(ConstantUtils.creatorIconPath),
              fit: BoxFit.contain
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: TextStyle(color: widget.primaryAppColorSettingsValue),),
        iconTheme: IconThemeData(
          color: widget.primaryAppColorSettingsValue,
        ),
      ),
      body: ListView(
        children: [
          WidgetUtils.spacer(20),
          Center(
            child: _appIcon(),
          ),
          WidgetUtils.spacer(10),
          _addText("Designed and Created by Vidxyz"),
          Center(
            child: _creatorIcon(),
          ),
          WidgetUtils.spacer(10),
          _addText("Developed using Flutter SDK for Android and iOS"),
          // WidgetUtils.spacer(10),
          // Container(
          //   height: 50,
          //   child: Row(
          //     children: [
          //       Expanded(child: Container()),
          //       Expanded(child: _linkButtons(ConstantUtils.githubUrl, ConstantUtils.githubIconPath)),
          //       // Expanded(child: _linkButtons(Utils.linkedInUrl, Utils.linkedInIconPath)),
          //       Expanded(child: Container()),
          //     ],
          //   ),
          // ),
          // WidgetUtils.spacer(10),
          _addTextLink(ConstantUtils.githubIssuesUrl, "Feedback? Issues? Want to contribute? Click here for more"),
        ],
      ),
    );
  }

  Widget _addText(String text) =>
      Container(
        margin: const EdgeInsets.only(top: 15, bottom: 15),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 15
            ),
          ),
        ),
      );

  Widget _addTextLink(String url, String displayText) =>
      InkWell(
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          }
          else {
            throw "Could not launch $url";
          }
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: Center(
            child: Text(
              displayText,
              style: TextStyle(
                  color: widget.primaryAppColorSettingsValue
              ),
            ),
          ),
        ),
      );
}