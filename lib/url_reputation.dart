import 'package:flutter/material.dart';
import 'package:qr_code_reputation/virus_total.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlReputation extends StatefulWidget {
  final String url;

  const UrlReputation({Key? key, required this.url}) : super(key: key);

  @override
  _UrlReputationState createState() => _UrlReputationState();
}

class _UrlReputationState extends State<UrlReputation> {
  var vt = VirusTotal();
  late Future<VirusTotalUrlResult> vtResult;
  var vtResultReady = false;

  @override
  void initState() {
    super.initState();
    vtResult = vt.getUrlReport(widget.url);
    vtResult.then((value) => vtResultReady = true);
  }

  void _goToVtLink() async {
    var vtResult = await this.vtResult;
    var url = 'https://www.virustotal.com/gui/url/${vtResult.id}';

    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontSize:24, decorationStyle: TextDecorationStyle.solid);
    return Scaffold(
        appBar: AppBar(
          title: const Text('URL reputation'),
        ),
        body: Center(
          child: Column(
          children: <Widget>[
             const Spacer(flex: 1),
            Text(
                ' ${widget.url} ',
                style: textStyle,
                overflow: TextOverflow.ellipsis
            ),
            const Spacer(flex: 1),
          Expanded(
            flex: 20,
            child: Card(
              margin:  const EdgeInsets.symmetric(horizontal: 16.0),
              child:
             FutureBuilder<VirusTotalUrlResult>(
              future: vtResult,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildVtResultWidget(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: vtResultReady ? _goToVtLink : null,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.open_in_new),
      ),
    );
  }

  Widget buildVtResultWidget(VirusTotalUrlResult result) {
    var avIcon = result.nbAvMatches > 0 ? Icons.coronavirus : Icons.check_circle;
    const iconPadding = EdgeInsets.fromLTRB(30.0, 0, 15.0, 0);
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                  padding: iconPadding,
                  child: Icon(
                    avIcon,
                    color: result.nbAvMatches > 0 ? Colors.red : Colors.green,
                    size: 24.0,
                    semanticLabel: 'antivirus icon',
                  )),
              Text('  ${result.nbAvMatches} AV match'),
              const Spacer(flex: 1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: iconPadding,
                child: Icon(
                  Icons.people,
                  color:
                      result.communityOpinion <= 0 ? Colors.red : Colors.green,
                  size: 24.0,
                  semanticLabel: 'Community score',
                ),
              ),
              Text('  ${result.communityOpinion} community score'),
              const Spacer(flex: 1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Padding(
                padding: iconPadding,
                child: Icon(
                  Icons.link,
                  color: Colors.blue,
                  size: 24.0,
                  semanticLabel: 'url icon',
                ),
              ),
              Text('final url: ${result.finalUrl}', overflow: TextOverflow.ellipsis),
            ],
          ),
        ]);
  }
}
