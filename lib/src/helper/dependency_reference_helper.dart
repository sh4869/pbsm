import 'dart:async';

import 'package:pubspec/pubspec.dart';
import 'package:quiver_optional/optional.dart';
import 'package:pub_client/pub_client.dart' as pub_client;
import 'package:pub_semver/pub_semver.dart' as semver;

/// Helper Class of Pubspec Reference.
class ReferenceHelper {
  /// Get Git Reference.
  static GitReference getGitReference(String url) {
    if (url.contains("#")) {
      List<String> params = url.split("#");
      return new GitReference(params[0], params[1]);
    } else {
      return new GitReference(url, null);
    }
  }

  /// Get Path Reference
  static PathReference getPathReference(String path) => new PathReference(path);

  /// Get HostedReference.
  static Future<HostedReference> getHostedReference(String name) async {
    pub_client.PubClient client = new pub_client.PubClient();
    try {
      var package = await client.getPackage(name);
      return new HostedReference(
          new semver.Version.parse(package.latest.version));
    } on pub_client.HttpException catch (e) {
      switch (e.status) {
        case 404:
          throw new PackageNotFoundError(name + " is not found.");
        default:
          throw e;
      }
    }
  }

  /// Update Reference Map.
  static Map<String, DependencyReference> addReference(String name,
      DependencyReference reference, Map<String, DependencyReference> oldMap) {
    oldMap[name] = reference;
    return oldMap;
  }

  /// Remove Pacakge from DependencyReference Map.
  static Optional<Map<String, DependencyReference>> removeReference(
      String name, Map<String, DependencyReference> oldMap) {
    if (oldMap.containsKey(name)) {
      oldMap.remove(name);
      return new Optional.of(oldMap);
    } else {
      return new Optional.absent();
    }
  }

  /// Return Information of DependencyReference
  static String getDependencyInfo(DependencyReference ref, String name) {
    if (ref is GitReference) {
      if (ref.ref != null) {
        return name + " : \n  url: ${ref.url}\n  branch: ${ref.ref}";
      } else {
        return name + " : ${ref.url}";
      }
    } else if (ref is HostedReference) {
      return name + " : " + ref.versionConstraint.toString();
    } else if (ref is PathReference) {
      return name + " : " + ref.path;
    } else {
      return "";
    }
  }
}

/// Exception thrown when a package is not found.
class PackageNotFoundError extends StateError {
  PackageNotFoundError(String msg) : super(msg);
}
