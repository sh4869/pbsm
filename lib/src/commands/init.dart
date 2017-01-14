import 'dart:io';

import 'package:pubspec/pubspec.dart';
import 'package:args/command_runner.dart';
import 'package:prompt/prompt.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

import '../util.dart';

class InitCommand extends Command {
  String get name => "init";
  String get description => "init pubspec.yaml.";

  @override
  String get invocation => "${runner.executableName} $name [directory]";

  bool get setTarget => argResults.rest.length > 0;

  Directory get targetdir {
    if (setTarget) {
      return new Directory(argResults.rest[0]);
    } else {
      return Directory.current;
    }
  }

  InitCommand() {
    argParser.addFlag("yes",
        abbr: "y",
        help: "init pubspec without asking you.\nsame as --force option.");
    argParser.addFlag("force",
        abbr: "f",
        help: "init pubspec without asking you.\nsame as --yes option.");
  }

  void run() {
    if (argResults.rest.length > 1) {
      print("Error: target directory must be one.");
      exit(1);
    }
    PubSpec spec;
    if (argResults["yes"] || argResults["force"]) {
      spec = _createSpecWithoutPrompt();
    } else {
      spec = _createSpec();
    }
    if (setTarget) {
      createDir(argResults.rest[0]);
    }
    spec.save(targetdir);
    close();
  }

  PubSpec _createSpecWithoutPrompt() {
    String name = _getDefaultName();
    semver.Version version = new semver.Version.parse("1.0.0");
    String author = _getDefaultAuthor();
    return new PubSpec(name: name, version: version, author: author);
  }

  PubSpec _createSpec() {
    String name = _askParams(
        new Question("name", defaultsTo: _getDefaultName()), (str) => str);
    semver.Version version = _askParams(
        new Question("version", defaultsTo: "1.0.0"),
        (str) => new semver.Version.parse(str));
    String author = _askParams(
        new Question("author", defaultsTo: _getDefaultAuthor()), (str) => str);
    String desc = _askParams(new Question("description"), (str) => str);
    String homepage = _askParams(new Question("homepage"), (str) => str);

    PubSpec spec = new PubSpec(
        name: name,
        description: desc,
        author: author,
        homepage: homepage,
        version: version);
    return spec;
  }

  T _askParams<T>(Question q, T parse(String ans)) {
    T ans;
    while (true) {
      try {
        ans = parse(askSync(q));
        break;
      } on FormatException catch (e) {
        print(e.message);
      } catch (e) {}
    }
    return ans;
  }

  String _getDefaultName() {
    if (setTarget) {
      return argResults.rest[0];
    } else {
      if (Platform.isWindows) {
        return targetdir.path.split("\\").last;
      } else {
        return targetdir.path.split("/").last;
      }
    }
  }

  String _getDefaultAuthor() {
    ProcessResult nameResult, emailResult;
    if (new Directory(targetdir.path + "/.git").existsSync()) {
      nameResult = Process.runSync("git", ["config", "user.name"],
          workingDirectory: targetdir.path);
      emailResult = Process.runSync("git", ["config", "user.email"],
          workingDirectory: targetdir.path);
    } else {
      nameResult = Process.runSync("git", ["config", "--global", "user.name"]);
      emailResult =
          Process.runSync("git", ["config", "--global", "user.email"]);
    }
    if (nameResult.exitCode == 0 && emailResult.exitCode == 0) {
      return nameResult.stdout.trim() + " <" + emailResult.stdout.trim() + ">";
    } else {
      return "";
    }
  }
}
