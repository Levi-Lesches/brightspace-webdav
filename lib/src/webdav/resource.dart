import "package:xml/xml.dart";
import "resource/properties.dart";

export "resource/brightspace_resource.dart";
export "resource/dummy_resource.dart";
export "resource/file_resource.dart";

abstract class Resource {	
	/// The address of the WebDav server.
	static const host = "localhost:8011";

	/// The location of this resource. 
	final Uri uri;

	/// Whether this resource is available.
	final bool exists; 

	/// Creates a [Resource] representing a file.
	const Resource(this.uri, {this.exists = true});

	/// The properties of this resource. 
	ResourceProperties get properties;

	/// Serializes this resource to XML, according to WebDAV specification.
	/// 
	/// See http://webdav.org/specs/rfc4918.html#ELEMENT_response
	void buildXml(XmlBuilder builder) {
		builder.element("D:response", nest: () => builder
			..element("D:href", nest: uri)
			..element("D:propstat", nest: () {
				properties.buildXml(builder);
				builder.element("D:status", nest: exists ? "HTTP/1.1 200 OK" : "HTTP/1.1 404 NOT FOUND");
			})
		);
	}
}

abstract class CollectionResource extends Resource {
	/// All children resources of this resource. 
	Iterable<Resource> get children;

	/// Creates a [CollectionResource] representing a directory.
	const CollectionResource(Uri uri) : super(uri);
}
