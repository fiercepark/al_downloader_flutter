import 'dart:async';
import 'package:flutter/foundation.dart';
import 'ALDownloader.dart';
import 'ALDownloaderHandlerInterface.dart';
import 'ALDownloaderStatus.dart';

/// ALDownloaderBatcher
///
/// batch download
/// progress = number of successful tasks / number of all tasks
class ALDownloaderBatcher {
  /// download
  ///
  /// [urls] urls
  ///
  /// [downloaderHandlerInterface] downloader handler interface
  static Future<void> downloadUrls(List<String> urls,
      {ALDownloaderHandlerInterface? downloaderHandlerInterface}) async {
    addDownloaderHandlerInterface(downloaderHandlerInterface, urls);

    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);

    for (final url in aNonDuplicatedUrls) await ALDownloader.download(url);
  }

  /// summarize the download status for a set of urls
  ///
  /// **parameters**
  ///
  /// [urls] s set of url
  ///
  /// **return**
  ///
  /// [ALDownloaderStatus] download status
  static ALDownloaderStatus getDownloadStatusForUrls(List<String> urls) {
    final Map<String, ALDownloaderStatus> aMap = {};
    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);

    for (final url in aNonDuplicatedUrls) {
      final aStatus = ALDownloader.getDownloadStatusForUrl(url);

      if (aStatus == ALDownloaderStatus.downloading) {
        // contain downloading task
        return ALDownloaderStatus.downloading;
      } else if (aStatus == ALDownloaderStatus.paused) {
        // contain paused task
        return ALDownloaderStatus.paused;
      }

      aMap[url] = aStatus;
    }

    final allStatus = aMap.values.toSet();

    if (allStatus.contains(ALDownloaderStatus.failed)) {
      // not contain downloaded task && not contain paused task && contain one failed task at least
      return ALDownloaderStatus.failed;
    } else if (allStatus.difference({ALDownloaderStatus.succeeded}).length ==
        0) {
      // not contain downloading task && not contain paused task && not contain failed task && task is all successful
      return ALDownloaderStatus.succeeded;
    }
    // not contain downloading task && not contain failed task && not contain paused task && contain unsuccessful task
    return ALDownloaderStatus.unstarted;
  }

  /// get download progress for a set of urls
  ///
  /// number of successful tasks / number of all tasks
  ///
  /// **parameters**
  ///
  /// [urls] urls
  ///
  /// **return**
  ///
  /// [double] download progress
  static double getProgressForUrls(List<String> urls) {
    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);
    final binder = _ALDownloaderBatcherBinder._(aNonDuplicatedUrls);
    final progress = binder.progress;
    return progress;
  }

  /// add a downloader handler interface
  ///
  /// **parameters**
  ///
  /// [downloaderHandlerInterface] downloader handler interface
  ///
  /// [urls] urls
  static void addDownloaderHandlerInterface(
      ALDownloaderHandlerInterface? downloaderHandlerInterface,
      List<String> urls) {
    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);

    final binder = _ALDownloaderBatcherBinder._(aNonDuplicatedUrls);

    for (final url in aNonDuplicatedUrls) {
      final aDownloaderHandlerInterface =
          ALDownloaderHandlerInterface(progressHandler: (progress) {
        debugPrint("ALDownloaderBatcher | downloading, the url = $url");

        final progressHandler = downloaderHandlerInterface?.progressHandler;
        if (progressHandler != null) progressHandler(binder.progress);
      }, succeededHandler: () {
        debugPrint("ALDownloaderBatcher | download succeeded, the url = $url");

        if (binder._isSuccess)
          _tryToCallBackForCompletion(binder, downloaderHandlerInterface);
      }, failedHandler: () {
        debugPrint("ALDownloaderBatcher | download failed, the url = $url");

        if (binder._isOver && !binder._isSuccess) {
          final failedHandler = downloaderHandlerInterface?.failedHandler;
          if (failedHandler != null) failedHandler();
        }
      }, pausedHandler: () {
        debugPrint("ALDownloaderBatcher | download paused, the url = $url");
        final pausedHandler = downloaderHandlerInterface?.pausedHandler;
        if (pausedHandler != null) pausedHandler();
      });

      ALDownloader.addDownloaderHandlerInterface(
          aDownloaderHandlerInterface, url);
    }
  }

  /// remove downloader handler interfaces
  ///
  /// **parameters**
  ///
  /// [urls] urls
  static void removeDownloaderHandlerInterfaceForUrls(List<String> urls) {
    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);

    aNonDuplicatedUrls.forEach((element) =>
        ALDownloader.removeDownloaderHandlerInterfaceForUrl(element));
  }

  /// pause download
  ///
  /// **parameters**
  ///
  /// [urls] urls
  static Future<void> pause(List<String> urls) async {
    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);

    for (final url in aNonDuplicatedUrls) await ALDownloader.pause(url);
  }

  /// remove data
  ///
  /// **parameters**
  ///
  /// [urls] urls
  static Future<void> remove(List<String> urls) async {
    final aNonDuplicatedUrls = _getNonDuplicatedUrlsFromUrls(urls);

    for (final url in aNonDuplicatedUrls) await ALDownloader.remove(url);
  }

  /// ------------------------------------ Private API ------------------------------------

  static void _tryToCallBackForCompletion(_ALDownloaderBatcherBinder binder,
      ALDownloaderHandlerInterface? downloaderHandlerInterface) {
    if (binder._isSuccess) {
      final succeededHandler = downloaderHandlerInterface?.succeededHandler;
      if (succeededHandler != null) succeededHandler();
    } else {
      final failedHandler = downloaderHandlerInterface?.failedHandler;
      if (failedHandler != null) failedHandler();
    }
  }

  // remove duplication of urls
  static List<String> _getNonDuplicatedUrlsFromUrls(List<String> urls) {
    final aNonDuplicatedUrls = <String>[];
    for (final element in urls) {
      if (!aNonDuplicatedUrls.contains(element))
        aNonDuplicatedUrls.add(element);
    }
    return aNonDuplicatedUrls;
  }

  ALDownloaderBatcher._();
}

/// a binder for binding element of url and download ininterface for ALDownloaderBatcher
class _ALDownloaderBatcherBinder {
  bool get _isSuccess => _succeededUrls.length == _targetUrls.length;

  List<String> get _succeededUrls {
    List<String> aList;

    try {
      aList = _completedKVsForALDownloader.entries
          .where(
              (element) => element.value && _targetUrls.contains(element.key))
          .map((e) => e.key)
          .toList();

      debugPrint("get _succeededUrls result = $aList");
    } catch (error) {
      aList = <String>[];
      debugPrint("get _succeededUrls error = $error");
    }

    return aList;
  }

  // ignore: unused_element
  List<String> get _failedUrls {
    List<String> aList;

    try {
      aList = _completedKVsForALDownloader.entries
          .where(
              (element) => !element.value && _targetUrls.contains(element.key))
          .map((e) => e.key)
          .toList();

      debugPrint("get _failedUrls result = $aList");
    } catch (error) {
      aList = <String>[];
      debugPrint("get _failedUrls error = $error");
    }

    return aList;
  }

  /// process
  ///
  /// progress = number of successful tasks / number of all tasks
  double get progress {
    double aDouble = 0;

    try {
      if (_targetUrls.length == 0) {
        aDouble = 0;
      } else {
        dynamic result = _succeededUrls.length / _targetUrls.length;
        result = result.toStringAsFixed(2);
        aDouble = double.tryParse(result) ?? 0;
      }
    } catch (error) {
      aDouble = 0;
      debugPrint("$error");
    }

    return aDouble;
  }

  /// all download tasks are completed
  /// just completed, it may be successful or failed
  bool get _isOver => _completedKVsForALDownloader.keys
      .toSet()
      .containsAll(_targetUrls.toSet());

  /// completed KVs for ALDownloader
  static Map<String, bool> get _completedKVsForALDownloader =>
      ALDownloader.completedKVs;

  /// urls that need to be downloaded
  final List<String> _targetUrls;

  /// privatize constructor
  _ALDownloaderBatcherBinder._(this._targetUrls);
}
