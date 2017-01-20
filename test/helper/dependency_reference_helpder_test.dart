@TestOn("vm")
import 'package:test/test.dart';
import 'package:pubspec/pubspec.dart';
import 'package:quiver_optional/optional.dart';

import 'package:pbsm/src/helper/dependency_reference_helper.dart';

void main() {
  group("ReferenceHelper", () {
    test("#getGitReference", () {
      var ref =
          ReferenceHelper.getGitReference("git://github.com/dart-lang/test");
      expect(ref.url, equals("git://github.com/dart-lang/test"));
      expect(ref.ref, isNull);
      ref = ReferenceHelper
          .getGitReference("git://github.com/dart-lang/test#develop");
      expect(ref.url, equals("git://github.com/dart-lang/test"));
      expect(ref.ref, equals("develop"));
    });

    test("#getPathReference", () {
      var ref = ReferenceHelper.getPathReference("/home/user/dart/test");
      expect(ref.path, "/home/user/dart/test");
    });

    test("#getHostReference", () async {
      expect(
          ReferenceHelper.getHostedReference("121asdhfagsfjkadfjas"), throws);
    });

    var map = new Map<String, DependencyReference>();
    test("#addReference", () {
      expect(
          ReferenceHelper.addReference(
              "test", new PathReference("/home/user/dart/test"), map)["test"],
          equals(new PathReference("/home/user/dart/test")));
    });

    test("#removeReference", () {
      map["test"] = new PathReference("/home/user/dart/test");
      expect(ReferenceHelper.removeReference("test", map).value,
          equals(new Map<String, DependencyReference>()));
      expect(ReferenceHelper.removeReference("test", map),
          equals(new Optional.absent()));
    });
  });
}
