@TestOn("vm")
import 'dart:io';

import 'package:test/test.dart';
import 'package:pubspec/pubspec.dart';
import 'package:path/path.dart' as p;

import 'package:pbsm/src/helper/pubspec_helper.dart';

void main() {
  group("PubspecHelper", () {
    var dir = Directory.systemTemp.createTempSync("my_temp_dir");

    test("#loadPubspec", () async {
      var file = new File(p.join(dir.path, "pubspec.yaml"));
      file.createSync();
      file.writeAsStringSync(sampleSpec);
      expect((await PubSpecHelper.loadPubspec((e) => throw e, dir)).name,
          equals("test"));
      expect((await PubSpecHelper.loadPubspec((e) => throw e, dir)).description,
          equals("Test library"));

      file.delete();
    });

    test("#savePubspec", () async {
      expect(
          await PubSpecHelper.savePubspec(
              new PubSpec(name: "test", description: "test Library"),
              (e) => throw e,
              dir),
          isNull);
    });
  });
}

String sampleSpec = """
name: test
description: Test library
""";
