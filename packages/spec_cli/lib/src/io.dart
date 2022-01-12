import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

final $workingDirectory = Provider((ref) => Directory.current);

final $fileChange = StreamProvider<void>((ref) {
  // TODO observe flutter assets
  final controller = StreamController<void>();
  ref.onDispose(controller.close);

  final dir = ref.watch($workingDirectory);
  final libChange = Directory(join(dir.path, 'lib')).watch(recursive: true);
  final testChange = Directory(join(dir.path, 'lib')).watch(recursive: true);

  final libSub = libChange.listen((event) => controller.add(null));
  ref.onDispose(libSub.cancel);

  final testSub = testChange.listen((event) => controller.add(null));
  ref.onDispose(testSub.cancel);

  return controller.stream;
}, dependencies: [$workingDirectory]);

final $sigint = StreamProvider<void>((ref) => ProcessSignal.sigint.watch());
final $sigterm = StreamProvider<void>((ref) => ProcessSignal.sigterm.watch());

final $isEarlyAbort = Provider<bool>((ref) {
  return ref.watch($sigint).isData || ref.watch($sigterm).isData;
}, dependencies: [$sigint, $sigterm]);

final $startTime = StateProvider<DateTime>((ref) => DateTime(0));
