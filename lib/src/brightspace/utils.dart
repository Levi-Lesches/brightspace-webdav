import "dart:convert";
import "dart:typed_data";

import "package:http/http.dart" show Client, Response;

import "package:webdav/utils.dart";

class BrightspaceApiError extends Error {
	/// The response from the Brightspace API that contains the error. 
	final Response response;

	/// Creates an error caused by the Brightspace API. 
	BrightspaceApiError(this.response);

	@override
	String toString() => "BrightspaceApiError: The Brightspace API returned an error.\n"
		"  Status code: ${response.statusCode}\n"
		"  Reason: ${response.reasonPhrase}\n"
		"  Headers: ${response.headers}\n"
		"  Body: ${response.body}";
}

class BrightspaceUtils {
	/// The address of the Brightspace server.
	static const host = "localhost:8010";
	final _client = Client();

	/// Sends and parses a GET request to the Brightspace server.
	Future<Json> get(String route) async {
		final url = Uri.http(host, route);
		final response = await _client.get(url);
		switch (response.statusCode) {
			case 200: return jsonDecode(response.body);
			case 401: 
			case 403: throw BrightspaceApiError(response);
			case 404: throw BrightspaceApiError(response);
			case 500: throw BrightspaceApiError(response);
			default: throw BrightspaceApiError(response);
		}
	}

	/// Retreives the contents of the file at the given location. 
	Future<Uint8List> read(String route) => _client.readBytes(Uri.http(host, route));

	/// Disposes of resources associated with the HTTP client. 
	void dispose() => _client.close();
}
