import 'dart:io';

void createDir(String name) {
  if (!new Directory(name).existsSync()) {
    new Directory(name).createSync(recursive: true);
  }
}
