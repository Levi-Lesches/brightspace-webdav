import "dart:io";
import "package:oauth2/oauth2.dart";

final authEndpoint = Uri.parse("https://auth.brightspace.com/oauth2/auth");
final tokenEndpoint = Uri.parse("https://auth.brightspace.com/core/connect/token");
final redirectUrl = Uri.parse("http://google.com");

const identifier = "{11111111-1111-1111-1111-111111111111}";
const secret = "12345";

Future<Client> createClient() async {
	final grant = AuthorizationCodeGrant(
		identifier, authEndpoint, tokenEndpoint, secret: secret,
	);

	final authUrl = grant.getAuthorizationUrl(redirectUrl, scopes: ["users:own_profile:read"]);
	await redirect(authUrl);
	final responseParameters = await listen(redirectUrl);
	return grant.handleAuthorizationResponse(responseParameters);
}

// ignore: avoid_print
Future<void> redirect(Uri url) async => print(url);

Future<Map<String, String>> listen(Uri url) async {
	stdin.readLineSync();
	return {};
}

Future<void> main() async {
	await createClient();
}
