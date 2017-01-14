# pbsm

[![pub package](https://img.shields.io/pub/v/pbsm.svg)](https://pub.dartlang.org/packages/pbsm)

A pubspec maintenance tool. 

## Install

```
pub global activate pbsm
```

## Commands

### init

Inialize pubspec.yaml.

```
pbsm init # inialize pubspec.yaml in current directory
pbsm init target # inialize pubspec.yaml in target directory
pbsm init -y # inialize pubspec.yaml without prompt
```

### install

Install package and update pubspec.yaml.

```
pbsm install test # install test package from pub.dartlang.org
pbsm install --git git://github.com/dart-lang/test.git test # install package from git url
```

### uninstall

Uninstall package and update pubspec.yaml.

```
pbsm uninstall test 
```

## LICENSE

MIT