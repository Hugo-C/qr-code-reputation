import 'dart:convert';
import 'package:http/http.dart' as http;

class VirusTotal {
  Future<VirusTotalUrlResult> getUrlReport(String url) async {
    url = "http://google.com";
    var urlInB64 = base64.encode(utf8.encode(url));
    urlInB64 = urlInB64.substring(0, urlInB64.length - 1);  // Remove ending = char
    const apiKey = 'XXX_API_KEY_XXX';
    var headers = {'x-apikey': apiKey};
    var res = await http.get(
        Uri.parse('https://www.virustotal.com/api/v3/urls/$urlInB64'),
        headers: headers,
    );
    if (res.statusCode == 404) {
      throw Exception('Url not known to virus total');
    }
    var json = jsonDecode(res.body);
    return VirusTotalUrlResult.fromJson(json);
  }
}

class VirusTotalUrlResult {
  final String id;
  final String finalUrl;
  final int nbAvMatches;
  final int communityOpinion;

  const VirusTotalUrlResult({
    required this.id,
    required this.finalUrl,
    required this.nbAvMatches,
    required this.communityOpinion,
  });

  factory VirusTotalUrlResult.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    var attributes = data['attributes'];

    var lastAnalysisStats = attributes['last_analysis_stats'];
    var nbAvMatches = lastAnalysisStats['malicious'] + lastAnalysisStats['suspicious'];

    var totalVotes = attributes['total_votes'];
    var communityOpinion = totalVotes['harmless'] - totalVotes['malicious'];
    return VirusTotalUrlResult(
      id: data['id'],
      finalUrl: attributes['last_final_url'],
      nbAvMatches: nbAvMatches,
      communityOpinion: communityOpinion,
    );
  }
}