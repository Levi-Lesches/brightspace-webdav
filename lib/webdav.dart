import "package:shelf/shelf.dart";
import "package:xml/xml.dart";

import "src/webdav/resource.dart";

export "src/webdav/resource.dart";

// ignore: avoid_classes_with_only_static_members
class WebDavServer {
	/// Returns a list of acceptable methods for use on this server. 
	static Response options() => Response.ok(null, 
		// headers: {"Allow": "OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, ORDERPATCH", "Dav": "1"}
		headers: {"Allow": "OPTIONS, GET, HEAD, PROPFIND", "Dav": "1"}

	);

	/// Prepares an XML response to a PROPFIND request with the given resources.
	static Response propfind(Iterable<Resource> resources) { 
		final builder = XmlBuilder()..processing("xml", 'version="1.0"');
		builder.element("D:multistatus", namespaces: {"DAV:": "D"}, nest: () {
			for (final Resource resource in resources) resource.buildXml(builder);
		});
		final String xml = builder.buildDocument().toXmlString();
		return Response.ok(xml);
	}

	/// Returns whether the given entity exists or not.
	static Response head({required bool doesExist}) => 
		doesExist ? Response.ok(null) : Response.notFound(null);

	/// Returns data for a GET request, assuming it succeeded. 
	static Response get(Object data) => Response.ok(data);
}
