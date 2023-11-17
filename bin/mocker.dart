import "dart:convert" show jsonDecode;
import "dart:io" show HttpServer;

import "package:http/http.dart" as http;
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart";

/// We can use the API Test Tool for testing the Brightspace API.
/// 
/// Problem is, it sends its requests through a forwarder, which returns its 
/// response wrapped in some JSON. All this makes it hard to directly test the
/// API using a tool like Insomnia.
/// 
/// This script can act as the client-facing API by parsing incoming requests,
/// forwarding them to the test tool, and parsing then returning the response. 

void main() => serveBrightspaceForwarder();

Future<HttpServer> serveBrightspaceForwarder() async {
	final server = await serve(handleGet, "localhost", 8010);
	return server;
}

final client = http.Client();
const d2lUrl = "apitesttool.desire2learnvalence.com";
const d2lPath = "doRequest.php";

Future<Response> handleGet(Request request) async {
	// Parse and construct the forwarded request
	final Map<String, String> body = {
		"host": "devcop.brightspace.com",
		"port": "443",
		"scheme": "https",
		"anon": "false",
		"apiRequest": "/${request.url.path}",
		"apiMethod": request.method,
		"contentType": "application/json",
		"data": await request.readAsString(),
		"appId": "31brpbcCLsVim_K4jJ8vzw",
		"appKey": "sagYSTT_HOts39qrGQTFWA",
		"userId": "YBQZCnjR041iW6D9GYmKQm",
		"userKey": "laTd-zDfdGSOCn7dcpf955",
	};
	final Uri url = Uri(scheme: "https", host: d2lUrl, path: d2lPath);

	// Send and parse the response. The actual response is a *field* in the response
	final http.Response d2lResponse = await client.post(url, body: body);
	if (d2lResponse.statusCode != 200) return Response.internalServerError(body: "Error serving $url");
  if (d2lResponse.body.isEmpty) {
    return Response(
      d2lResponse.statusCode,
      // body: null,
    );
  } else {
    final Map json = jsonDecode(d2lResponse.body);
    final String response = json["response"];
    return Response(
      d2lResponse.statusCode,
      body: response,
      // headers: d2lResponse.headers,
    );
  }
}
