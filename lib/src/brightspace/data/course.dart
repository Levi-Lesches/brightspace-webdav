import "package:webdav/utils.dart";

class Course {
	/// The backend ID of this unit.
	final int id;

	/// The user-facing name of this unit. 
	final String name;

	/// Creates a [Course] from a JSON object.
	/// 
	/// See https://docs.valence.desire2learn.com/res/enroll.html?highlight=orgunitinfo#Enrollment.OrgUnitInfo.
	Course.fromJson(Json json) : 
		id = json["Id"],
		name = json["Name"];

	@override
	String toString() => name;
}
