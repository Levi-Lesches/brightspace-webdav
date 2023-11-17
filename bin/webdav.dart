import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart";

import "package:webdav/brightspace.dart";
import "package:webdav/webdav.dart";

import "mocker.dart";

final brightspace = Brightspace.instance;
const Set<String> restrictedFiles = {"desktop.ini", "Autorun.inf"};

Future<void> main(List<String> arguments) async {
	await serveBrightspaceForwarder();
	await brightspace.init();
	await serve(handler, "localhost", 8011);
	print("Serving on localhost:8011");  // ignore: avoid_print
}

const Map<String, Handler> handlers = {
	"OPTIONS": optionsHandler,
	"PROPFIND": propFindHandler,
	"HEAD": headHandler,
	"GET": getHandler,
};

Future<void> logRequest(Request request) async {
	print("\n[Server]: Received ${request.method} request for ${request.requestedUri}");  // ignore: avoid_print
	print("  Headers: ${request.headers}");  // ignore: avoid_print
	print("  body: ${await request.readAsString()}");  // ignore: avoid_print
}

Future<Response> handler(Request request) async {
	await logRequest(request);
	final methodHandler = handlers[request.method] ?? defaultHandler;
	return await methodHandler(request);
}

Future<Response> defaultHandler(Request request) async => Response.internalServerError();

Response optionsHandler(Request request) => 
	Response.ok(null, headers: {"Allow": "OPTIONS, GET, HEAD, POST, PUT, DELETE, TRACE, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, ORDERPATCH", "Dav": "1"});

Future<Response> propFindHandler(Request request) async {
	// Request validation
	final rawDepth = request.headers["depth"];
	final depth = rawDepth == null ? null : int.tryParse(rawDepth);
	if (rawDepth == null || depth == null || rawDepth.toLowerCase() == "infinity") {
		return Response.forbidden("403.22: Infinite depth forbidden");
	} else if (depth > 1) {
		return Response.forbidden("Depth larger than 1 is not allowed");
	}

	final resources = <Resource>[];
	final path = request.url.pathSegments;

	if (path.isEmpty) {  // the root 
		resources.add(DummyCollectionResource(request.requestedUri));
		if (depth == 1) {  // add all classes as well, without requesting them
			for (final course in brightspace.courses.values) {
				resources.add(ModuleResource.fromCourse(course));
			}
		}
	} else if (restrictedFiles.contains(path.last)) {  // Windows 
		resources.add(DummyResource(request.requestedUri, exists: false));
	} else {  // nested within a course
		final content = await brightspace.resolveUri(request.url);
		final Resource resource;
		if (content == null) {
		  return Response.notFound(null);
		} else if (content is Topic) {
      resource = TopicResource(content, uri: request.url);
    } else if (content is Module) {
      resource = ModuleResource(content, uri: request.url);
    } else {
      throw StateError("Unknown instance of ContentObject: ${content.runtimeType}");
    }

		resources.add(resource);
		if (depth == 1) {
			if (content is Topic) {
			  return Response(405, body: "Cannot iterate over a non-collection resource");
			} else if (resource is ModuleResource) {
        resources.addAll(resource.children);
      }
		}
	}
	return WebDavServer.propfind(resources);
}

Future<Response> headHandler(Request request) async {
	final content = await brightspace.resolveUri(request.url);
	return WebDavServer.head(doesExist: content != null);
}

Future<Response> getHandler(Request request) async {
	if (restrictedFiles.contains(request.url.pathSegments.last)) return Response.notFound(null);
	final content = await brightspace.resolveUri(request.url);
	if (content == null) {
	  return Response.notFound(null);
	} else if (content is Module) {
    return Response(405, body: "Cannot GET a collection resource");
  }
	else if (content is Topic) {
    final data = await brightspace.getFile(content);
    return WebDavServer.get(data);
  } else {
    throw StateError("Unknown instance of ContentObject: ${content.runtimeType}");
  }
}
