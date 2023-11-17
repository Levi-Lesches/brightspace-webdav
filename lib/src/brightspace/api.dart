import "dart:typed_data";

import "data/content_object.dart";
import "data/course.dart";
import "utils.dart";

class BrightspaceApi {
	/// A service for processing requests to the Brightspace servers.
	final BrightspaceUtils utils = BrightspaceUtils(); 
  static const version = "1.44";

	/// Returns a list of all the user's courses.
	Future<List<Course>> getCourses() async {
		const route = "/d2l/api/lp/$version/enrollments/myenrollments/";
		final Map json = await utils.get(route);
		return [
			for (final Map item in json["Items"])
				if (item["OrgUnit"]["Type"]["Id"] == 3)  // filters other group types like "organizations"
					Course.fromJson(item["OrgUnit"])
		];
	}

	/// Gets all the modules for a given course by looking at the Table of Contents.
	Future<List<Module>> getModules(Course course) async {
		final route = "/d2l/api/le/$version/${course.id}/content/toc";
		final Map json = await utils.get(route);
		return [
			for (final Map module in json["Modules"]) 
				Module.fromJson(module, course: course)
		];
	}

	/// Downloads the file of given topic. 
	Future<Uint8List> getFile(Topic topic) async {
    print("Getting ${topic.title}");
		final route = "/d2l/api/le/$version/${topic.course.id}/content/topics/${topic.id}/file";
    print(route);
		return utils.read(route);
	}

	/// Cleans up resources used by the API. 
	void dispose() {
		utils.dispose();
	}
}