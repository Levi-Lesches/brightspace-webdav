import "package:xml/xml.dart";

extension on DateTime {
	/// WebDAV has trouble using partial seconds, so we trim them out.
	String prettyPrint() => "${toIso8601String().split('.').first}Z";
}

class ResourceProperties {
	/// When this resource was created or modified.
	final DateTime creationDate, modified;

	/// A user-facing name for this resource. 
	final String displayName;

	/// Whether this resource is a collection resource.
	final bool isDirectory;

	/// The size, in bytes, of this resource. 
	/// 
	/// May be null to indicate an unknown size. 
	final int? size;

	/// Creates a new [ResourceProperties].
	const ResourceProperties({
		required this.displayName,
		required this.creationDate,
		required this.isDirectory,
		required this.modified,
		this.size,
	});

	/// Serializes these properties as XML.
	void buildXml(XmlBuilder builder) => builder.element("D:prop", nest: () => builder
		..element("D:creationdate", nest: creationDate.toUtc().prettyPrint())
		..element("D:displayname", nest: displayName)
		..element("D:getcontentlength", nest: size ?? 0)
		..element("D:getlastmodified", nest: modified.toUtc().prettyPrint())
		..element("D:resourcetype", nest: () {
			if (isDirectory) builder.element("D:collection");
		})
	);
}
