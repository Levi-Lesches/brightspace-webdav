import "dart:io";

import "../resource.dart";
import "properties.dart";

final rootUri = Directory("server_root").uri;

extension on Uri {
	Uri get relative => Uri(pathSegments: pathSegments.sublist(1));
}

abstract class FileSystemResource<T extends FileSystemEntity> extends Resource {
	final Uri baseUri;
	final T entity;

	FileSystemResource(this.entity) : 
		baseUri = rootUri.resolveUri(entity.uri), 
		super(Uri.http("localhost:8011", entity.uri.path));

	static FileSystemResource fromUri(Uri uri) {
		final resolvedUri = rootUri.resolveUri(uri);
		final bool isDir = FileSystemEntity.isDirectorySync(resolvedUri.toFilePath());
		FileSystemResource resource; 
		if (isDir) { resource = DirectoryResource(resolvedUri); }
		else { resource = FileResource(resolvedUri); }
		return resource;
	}

	@override
	ResourceProperties get properties {
		final FileStat stats = entity.statSync();
		return ResourceProperties(
			creationDate: DateTime.now(),
			displayName: baseUri.relative.pathSegments.lastWhere((segment) => segment.isNotEmpty),
			isDirectory: entity is Directory,
			size: stats.size,
			modified: stats.modified,
		);
	}

	@override
	String toString() => entity.uri.toString();
}

class FileResource extends FileSystemResource<File> {
	FileResource(Uri uri) : super(File.fromUri(uri));
}

class DirectoryResource extends FileSystemResource<Directory> implements CollectionResource {
	DirectoryResource(Uri uri) : super(Directory.fromUri(uri));

	@override
	Iterable<FileSystemResource> get children => [
		for (final FileSystemEntity child in entity.listSync())
			if (child is File) FileResource(child.uri)
			else DirectoryResource(child.uri)
	];
}
