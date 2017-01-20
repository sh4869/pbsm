import 'dart:async';
import 'dart:io';

import 'package:pubspec/pubspec.dart';
import 'package:args/command_runner.dart';

import '../helper/dependency_reference_helper.dart';
import '../helper/pubspec_helper.dart';

class InstallCommand extends Command {
  String get name => "install";
  String get description => "Install package.";
  String get invocation =>
      "${runner.executableName} $name [options] <package name>";

  Function get onPubSpecError => (e) {
        if (e is FileSystemException) {
          print(e.message);
          exit(1);
        } else {
          throw e;
        }
      };

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
    PubSpec pubspec = await PubSpecHelper.loadPubspec(onPubSpecError);

    DependencyReference reference;
    if (argResults["git"] != null) {
      reference = ReferenceHelper.getGitReference(argResults["git"]);
    } else if (argResults["path"] != null) {
      reference = ReferenceHelper.getPathReference(argResults["path"]);
    } else {
      try {
        reference = await ReferenceHelper.getHostedReference(package_name);
      } on PackageNotFoundError catch (e) {
        print(e.message);
        exit(1);
      }
    }
    print(ReferenceHelper.getDependencyInfo(reference, package_name));

    pubspec = pubspec.copy(
        dependencies: ReferenceHelper.addReference(
            package_name, reference, pubspec.allDependencies));

    await PubSpecHelper.savePubspec(pubspec, onPubSpecError);
    exit(0);
  }
}
