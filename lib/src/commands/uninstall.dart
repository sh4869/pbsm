import 'dart:async';
import 'dart:io';

import 'package:pubspec/pubspec.dart';
import 'package:args/command_runner.dart';

class UninstallCommand extends Command {
  String get name => "uninstall";
  String get description => "unsinsall package.";
  String get invocation => "${runner.executableName} $name <package name>";
  UninstallCommand() {}

  Future<Null> run() async {
    if (argResults.rest.length < 1) {
      print("Error : please specify package name.");
      printUsage();
      exit(1);
    }
    String package_name = argResults.rest[0];
    PubSpec spec;
    try {
      spec = await PubSpec.load(Directory.current);
    } catch (e) {
      print(e);
      exit(1);
    }
    var dependencyMap = spec.allDependencies;
    if (dependencyMap.containsKey(package_name)) {
      dependencyMap.remove(package_name);
      spec = spec.copy(dependencies: dependencyMap);
      await spec.save(Directory.current);
      print("$package_name is uninstalled.");
    } else {
      print("$package_name is not installed.");
      exit(1);
    }
    exit(0);
  }
}
