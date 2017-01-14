import 'dart:async';
import 'dart:io';

import 'package:pubspec/pubspec.dart';
import 'package:args/command_runner.dart';
import 'package:pub_client/pub_client.dart' as pub_client;
import 'package:pub_semver/pub_semver.dart' as semver;

class InstallCommand extends Command {
  String get name => "install";
  String get description => "Install package.";
  String get invocation =>
      "${runner.executableName} $name [options] <package name>";
  InstallCommand() {
    argParser.addOption("git",
        help: """Install package from git.  parameter example:
      <git url>
      <git url>#<ref>
    """);
    argParser.addOption("path", help: "Install package from path.");
    argParser.addOption("hosted",
        help: "Install package from specify host server.");
  }

  Future<Null> run() async {
    if (argResults.rest.length < 1) {
      print("Error : please specify package name.");
      printUsage();
      exit(1);
    }

    String package_name = argResults.rest[0];
    PubSpec pubspec;
    try {
      pubspec = await PubSpec.load(Directory.current);
    } catch (e) {
      print(e);
      exit(1);
    }

    DependencyReference reference;
    if (argResults["git"] != null) {
      reference = _getGitReference(argResults["git"], package_name);
    } else if (argResults["path"] != null) {
      print("$name : " + argResults["path"]);
      reference = new PathReference(argResults["path"]);
    } else {
      reference = await _getHostedReference(package_name);
    }
    var dependencyMap = pubspec.allDependencies;
    dependencyMap[package_name] = reference;
    pubspec = pubspec.copy(dependencies: dependencyMap);
    try {
      await pubspec.save(Directory.current);
    } catch (e) {
      print(e);
    }
    exit(0);
  }

  GitReference _getGitReference(String url, name) {
    if (url.contains("#")) {
      List<String> params = url.split("#");
      String log =
          name + ": git\n" + "  url : " + params[0] + "\n  ref : " + params[1];
      print(log);
      return new GitReference(params[0], params[1]);
    } else {
      print(name + " : " + url);
      return new GitReference(url, null);
    }
  }

  Future<HostedReference> _getHostedReference(String name) async {
    print("Getting Package info from pub.dartlang.org...");
    pub_client.PubClient client = new pub_client.PubClient();
    pub_client.FullPackage package;
    try {
      package = await client.getPackage(name);
    } on pub_client.HttpException catch (e) {
      switch (e.status) {
        case 404:
          print("Error: $name is not found on pub.dartlang.org.");
          exit(1);
      }
    }
    print(name + " : " + package.latest.version);
    return new HostedReference(
        new semver.Version.parse(package.latest.version));
  }
}
