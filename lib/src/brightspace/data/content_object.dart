import "package:webdav/utils.dart";

import "course.dart";

/// A unit of content in a course's "Content" page.
abstract class ContentObject {	
	/// The course this content belongs to.
	final Course course;

	/// This backend ID for this content.
	final int id;

	/// The user-facing title of the content.
	final String title;

	/// The user-facing description for the content.
	final String description;

	/// When this content was last modified.
	final DateTime lastModified;

	/// Creates a new [ContentObject].
	const ContentObject({
		required this.course,
		required this.id,
		required this.title,
		required this.lastModified,
		required this.description,
	});
}

class Topic extends ContentObject {
	/// Whether this topic contains a file. 
	/// 
	/// Corresponds to a value of 1 in [the ACTIVITYTYPE_T chart](https://docs.valence.desire2learn.com/res/content.html?highlight=module#term-ACTIVITYTYPE_T).
	/// Non-file topics can be opened directly in the browser.
	final bool isFile;

	/// The path to the URL of this file. 
	/// 
	/// Note: Accessing files is supposed to be done through an API call, but 
	/// until that works, this is the only way to access the file.
	final String urlPath;

	/// Creates a [Topic] from JSON.
	/// 
	/// See https://docs.valence.desire2learn.com/res/content.html?highlight=topic#Content.ContentObject.
	Topic.fromJson(Json json, {required super.course}) : 
		isFile = json["ActivityType"] == 1,
		urlPath = json["Url"],
		super(
			id: json["TopicId"],
			title: Uri(path: json["Url"]).pathSegments.last,
			lastModified: DateTime.parse(json["LastModifiedDate"]),
			description: json["Description"]["Text"],
		);

	@override
	String toString() => title;
}

class Module extends ContentObject {
	/// A list of sub-modules within this module.
	final List<Module> children;

	/// A list of topics within this module.
	final List<Topic> topics;

	/// Represents a course listing as a module.
	/// 
	/// This can be helpful when thinking of a course as a collection of modules
	/// and topics as found in the contents page. 
	Module.fromCourse(
		Course course,
		{List<Module>? children,}
	) : topics = [], children = children ?? [], super(
		course: course,
		title: course.name,
		description: course.name,
		id: course.id,
		lastModified: DateTime.now(),
	);

	/// Creates a [Module] from JSON.
	/// 
	/// See https://docs.valence.desire2learn.com/res/content.html?highlight=topic#Content.ContentObject.
	Module.fromJson(Json json, {required super.course}) : 
		children = [
			for (final Json item in json["Modules"])
				Module.fromJson(item, course: course),
		],
		topics = [
			for (final Json item in json["Topics"])
				if (item["ActivityType"] == 1)
					Topic.fromJson(item, course: course),
		],
		super(
			id: json["ModuleId"],
			title: json["Title"],
			lastModified: DateTime.parse(json["LastModifiedDate"]),
			description: json["Description"]["Text"],
		);

	@override
	String toString() => title;
}
