import "../resource.dart";
import "properties.dart";

class DummyResource extends Resource {
	/// Creates a dummy resource at a given [Uri] with blank properties. 
	const DummyResource(super.uri, {super.exists});

	@override
	ResourceProperties get properties => ResourceProperties(
		modified: DateTime.now(),
		creationDate: DateTime.now(),
		displayName: uri.path,
		isDirectory: false,
	);
}

class DummyCollectionResource extends CollectionResource {
	/// Creates a dummy resource at a [Uri] with no properties or children.
	const DummyCollectionResource(super.uri);

	@override
	ResourceProperties get properties => ResourceProperties(
		modified: DateTime.now(),
		creationDate: DateTime.now(),
		displayName: uri.path,
		isDirectory: true,
	);

	@override
	Iterable<DummyCollectionResource> get children => const [];
}
