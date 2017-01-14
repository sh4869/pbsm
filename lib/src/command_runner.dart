import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:args/args.dart';

import 'commands/init.dart';
import 'commands/install.dart';
import 'commands/uninstall.dart';

class PBSMCommandRunner extends CommandRunner {
  String get version => "0.1.0";

  PBSMCommandRunner() : super("ppm", "The pubspec maintenance tool.") {
    argParser.addFlag("version", abbr: "v", help: "Print ppm version");
    addCommand(new InitCommand());
    addCommand(new InstallCommand());
    addCommand(new UninstallCommand());
  }

  Future run(Iterable<String> args) async {
    var option;
    try {
      option = super.parse(args);
    } on UsageException catch (error) {
      print(error.message);
      exit(1);
    }
    await runCommand(option);
  }

  Future runCommand(ArgResults option) async {
    if (option["version"]) {
      print('ppm version: ${version}');
      exit(0);
    }
    try {
      super.runCommand(option);
    } catch (e) {
      print(e);
    }
  }
}
