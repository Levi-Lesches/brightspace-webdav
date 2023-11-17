import "package:webdav/brightspace.dart";

import "../resource.dart";
import "properties.dart";

class TopicResource extends Resource {
	/// The [Topic] this resource represents. 
	final Topic topic;

	/// Creates a new [Resource] representing a [Topic] at a given location.
	TopicResource(this.topic, {required Uri uri}) : super(uri);

	@override
	ResourceProperties get properties => ResourceProperties(
		isDirectory: false, 
		creationDate: topic.lastModified,
		modified: topic.lastModified,
		displayName: topic.title,
	);

	@override
	String toString() => uri.toString();
}

class ModuleResource extends CollectionResource {
	/// The [Module] this resource represents. 
	Module module;

	/// Creates a new [CollectionResource] representing a [Module]. 
	ModuleResource(this.module, {required Uri uri}) : super(uri);

	/// Creates a new [CollectionResource] representing a [Course]. 
	ModuleResource.fromCourse(Course course) : 
		module = Module.fromCourse(course),
		super(Uri.http(Resource.host, course.name));

	/// Creates a new [CollectionResource] representing a sub-module of [module]. 
	ModuleResource childModule(Module obj) => ModuleResource(
		obj, 
		uri: Uri.http(Resource.host, "${uri.path}/${obj.title}")
	);

	/// Creates a new [Resource] representing a sub-topic of [module].
	TopicResource childTopic(Topic obj) => TopicResource(
		obj, 
		uri: Uri.http(Resource.host, "${uri.path}/${obj.title}"),
	);

	@override
	Iterable<Resource> get children => [
		for (final Module child in module.children)
			childModule(child),
		for (final Topic topic in module.topics)
			childTopic(topic),
	];

	@override
	ResourceProperties get properties => ResourceProperties(
		isDirectory: true,
		creationDate: module.lastModified,
		modified: module.lastModified,
		displayName: module.title,
	);

	@override
	String toString() => uri.toString();
}
