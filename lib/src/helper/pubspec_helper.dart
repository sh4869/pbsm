import 'dart:io';
import 'dart:async';

import 'package:pubspec/pubspec.dart';

typedef void onError(Exception e);

class PubSpecHelper {
  /// Load Pubspec and return pubspec class instance.
  /// If Pubspec.yaml not found in `dir`, Exit from Process.
  static Future<PubSpec> loadPubspec(onError errorHandle,
      [Directory dir]) async {
    PubSpec spec;
    try {
      if (dir != null) {
        spec = await PubSpec.load(dir);
      } else {
        spec = await PubSpec.load(Directory.current);
      }
    } catch (e) {
      errorHandle(e);
    }
    return spec;
  }

  /// Save Pubspec.
  /// If Fail to save the pubspec, return Error.
  static Future<Null> savePubspec(PubSpec spec, onError errorHandle,
      [Directory dir]) async {
    try {
      if (dir != null) {
        await spec.save(dir);
      } else {
        await spec.save(Directory.current);
      }
    } catch (e) {
      errorHandle(e);
    }
    return;
  }
}
