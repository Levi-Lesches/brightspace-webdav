import "dart:typed_data";

import "src/brightspace/api.dart";
import "src/brightspace/data/content_object.dart";
import "src/brightspace/data/course.dart";

export "src/brightspace/data/content_object.dart";
export "src/brightspace/data/course.dart";

extension <E> on Iterable<E> {
	E? firstWhereOrNull(bool Function(E element) test) {
	  for (final E element in this) {
	    if (test(element)) return element;
	  }
	}
}

class Brightspace {
	/// The singleton instance of this model. 
	static final instance = Brightspace();

	/// The service for interacting with the Brightspace API. 
	final api = BrightspaceApi();

	/// A collection of courses indexed by their names. 
	late final Map<String, Course> courses;

	/// Initializes the model by preloading the user's courses.
	Future<void> init() async {
		courses = {
			for (final Course unit in await api.getCourses())
				unit.name: unit,
		};
	}

	/// Resolves the given [Uri] to a specific [Module] or [Topic].
	/// 
	/// Returns null if the uri doesn't point to a valid location.
	Future<ContentObject?> resolveUri(Uri uri) async {
		final String courseName = uri.pathSegments.first;
		final Course? course = courses[courseName];
		if (course == null) return null;

		final List<Module> toc = await api.getModules(course);
		Module currentModule = Module.fromCourse(course, children: toc);
		for (int index = 1; index < uri.pathSegments.length; index++) {
			final Module? nextModule = currentModule.children.firstWhereOrNull(
				(child) => child.title == uri.pathSegments[index],
			);
			if (nextModule != null) {
				currentModule = nextModule;
				continue;
			} else if (index != uri.pathSegments.length - 1) {  // not at the end
				return null;  // some folder in the path is not a module in the course
			} else return currentModule.topics.firstWhereOrNull(
				(topic) => topic.title == uri.pathSegments[index],
			);
		}
		return currentModule;  // path ended on a module
	}

	/// Downloads the file of the given topic. 
	Future<Uint8List> getFile(Topic topic) => api.getFile(topic);

	/// Disposes of any resources being used by the [BrightspaceApi] service.
	void dispose() => api.dispose();
}
