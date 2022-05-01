import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

const maxVtScanTime = 60;

class UrlNotFoundInVirusTotal implements Exception {
  UrlNotFoundInVirusTotal();
}

class VirusTotal {
  Future<VirusTotalUrlResult> getUrlReport(String url) async {
    try {
      log('Fetching existing report for $url');
      return await _fetchReport(url);
    } on UrlNotFoundInVirusTotal catch(_) {
      log('Existing report not found, requesting a Scan');
      await _submitUrl(url);
    }

    // Try to wait for the url scan to be ready
    var waitTime = 10;  // increasing sleep, 10; 20; 40; 80 then fail
    var timeSpentWaiting = 0;
    while (timeSpentWaiting <= maxVtScanTime) {
      // Sleep first, query after
      await Future.delayed(Duration(seconds: waitTime));
      timeSpentWaiting += waitTime;
      try {
        return await _fetchReport(url);
      } on UrlNotFoundInVirusTotal catch(_) {
        waitTime *= 2;
      }
    }
    throw Exception(
        "VT failed to return a scan report in time ($timeSpentWaiting seconds)"
    );
  }

  Future<VirusTotalUrlResult> _fetchReport(String url) async {
    var formattedUrl = _formatUrl(url);
    const apiKey = 'XXX_API_KEY_XXX';
    var headers = {'x-apikey': apiKey};
    var res = await http.get(
        Uri.parse('https://www.virustotal.com/api/v3/urls/$formattedUrl'),
        headers: headers,
    );
    if (res.statusCode == 404) {
      throw UrlNotFoundInVirusTotal();
    }
    var json = jsonDecode(res.body);
    return VirusTotalUrlResult.fromJson(json);
  }

  Future<void> _submitUrl(String url) async {
    const apiKey = 'XXX_API_KEY_XXX';
    var headers = {
      'x-apikey': apiKey,
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var body = 'url=$url';  // Url must not be formatted in POST requests
    var res = await http.post(
      Uri.parse('https://www.virustotal.com/api/v3/urls'),
      headers: headers,
      body: body,
    );
    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

  /// Format a URL for VT API by converting it to base64 without padding
  /// see https://developers.virustotal.com/reference/url#url-identifiers
  String _formatUrl(String url) {
    var urlInB64 = base64.encode(utf8.encode(url));
    while (urlInB64.endsWith("=")) {
      urlInB64 = urlInB64.substring(0, urlInB64.length - 1);  // Remove ending "=" chars
    }
    return urlInB64;
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