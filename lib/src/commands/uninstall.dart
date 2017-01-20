import 'dart:async';
import 'dart:io';

import 'package:pubspec/pubspec.dart';
import 'package:args/command_runner.dart';

import '../helper/pubspec_helper.dart';
import '../helper/dependency_reference_helper.dart';

class UninstallCommand extends Command {
  String get name => "uninstall";

  String get description => "unsinsall package.";

  String get invocation => "${runner.executableName} $name <package name>";

  UninstallCommand() {}

  Function get onPubSpecError => (e) {
        if (e is FileSystemException) {
          print(e.message);
          exit(1);
        } else {
          throw e;
        }
      };

  Future<Null> run() async {
    if (argResults.rest.length < 1) {
      print("Error : please specify package name.");
      printUsage();
      exit(1);
    }
    String package_name = argResults.rest[0];
    PubSpec spec = await PubSpecHelper.loadPubspec(onPubSpecError);
    var result =
        ReferenceHelper.removeReference(package_name, spec.allDependencies);
    if (result.isPresent) {
      spec = spec.copy(dependencies: result.value);
      await PubSpecHelper.savePubspec(spec, onPubSpecError);
      print(package_name + " is uninstalled.");
      exit(0);
    } else {
      print(package_name + " is not installed.");
      exit(1);
    }
  }
}
