# al_downloader

[![pub package](https://img.shields.io/pub/v/al_downloader.svg)](https://pub.dartlang.org/packages/al_downloader)

一个基于url的Flutter下载器，支持下载任意类型的文件，并自动管理下载相关的各种事务。

## 特性

* 通过url管理下载任务
* 简化下载状态
* 减少I/O
* 提供便利的下载句柄
* 支持批量下载
* 自动管理文件，不需要指定下载路径
* 基于[flutter_downloader](https://pub.dev/packages/flutter_downloader)

## 集成

> 原生配置：和[flutter_downloader](https://pub.dev/packages/flutter_downloader)相同

添加下面这行代码到pubspec.yaml中

```
dependencies:
  al_downloader: ^1.1.1
```

使用命令行运行下面这行代码
```
flutter packages get
```

引入下面这行代码来使用al_downloader
```
import 'package:al_downloader/al_downloader.dart';
```

## 使用

### ALDownloader

```
/// 下载
ALDownloader.download(url,
    downloaderHandlerInterface:
        ALDownloaderHandlerInterface(progressHandler: (progress) {
      debugPrint(
          "ALDownloader | 正在下载, the url = $url, progress = $progress");
    }, successHandler: () {
      debugPrint("ALDownloader | 下载成功, the url = $url");
    }, failureHandler: () {
      debugPrint("ALDownloader | 下载失败, the url = $url");
    }, pausedHandler: () {
      debugPrint("ALDownloader | 下载暂停, the url = $url");
    }));
```

```
/// 添加一个下载句柄池
ALDownloader.addALDownloaderHandlerInterface(
    ALDownloaderHandlerInterface(progressHandler: (progress) {
      debugPrint(
              "ALDownloader | 正在下载, the url = $url, progress = $progress");
    }, successHandler: () {
      debugPrint("ALDownloader | 下载成功, the url = $url");
    }, failureHandler: () {
      debugPrint("ALDownloader | 下载失败, the url = $url");
    }, pausedHandler: () {
      debugPrint("ALDownloader | 下载暂停, the url = $url");
    }),
    url);
```

```
/// 删除一个下载句柄池
ALDownloader.removeALDownloaderHandlerInterfaceForUrl(url);
ALDownloader.removeALDownloaderHandlerInterfaceForAll;
```

```
/// 获取[url]的下载状态
ALDownloaderStatus status = ALDownloader.getDownloadStatusForUrl(url);
```

```
/// 取消
///
/// 详情查看接口描述
ALDownloader.cancel(url);
ALDownloader.cancelAll;
```

```
/// 暂停
///
/// 详情查看接口描述
ALDownloader.pause(url);
ALDownloader.pauseAll;
```

```
/// 移除
///
/// 详情查看接口描述
ALDownloader.remove(url);
ALDownloader.removeAll;
```

### ALDownloaderBatcher

```
/// 批量下载
ALDownloaderBatcher.downloadUrls(kTestVideos,
    downloaderHandlerInterface:
        ALDownloaderHandlerInterface(progressHandler: (progress) {
      debugPrint("ALDownloader | 批量 | 正在下载, progress = $progress");
    }, successHandler: () {
      debugPrint("ALDownloader | 批量 | 下载成功");
    }, failureHandler: () {
      debugPrint("ALDownloader | 批量 | 下载失败");
    }, pausedHandler: () {
      debugPrint("ALDownloader | 批量 | 下载暂停");
    }));
```

```
/// 总结一组url的下载状态
final status = ALDownloader.getDownloadStatusForUrls(urls);
```

### ALDownloaderPersistentFileManager - 基于url管理磁盘路径

```
final model = await ALDownloaderPersistentFileManager
    .lazyGetALDownloaderPathModelFromUrl(url);
debugPrint(
    "ALDownloader | 通过[url]获取文件的“物理目录路径”和“虚拟/物理文件名”, url = $url, path model = $model\n");

final path2 = await ALDownloaderPersistentFileManager
    .getAbsolutePathOfDirectoryWithUrl(url);
debugPrint(
    "ALDownloader | 通过[url]获取“目录路径”, url = $url, path = $path2\n");

final path3 = await ALDownloaderPersistentFileManager
    .getAbsoluteVirtualPathOfFileWithUrl(url);
debugPrint(
    "ALDownloader | 通过[url]获取“虚拟文件路径”, url = $url, path = $path3\n");

final path4 = await ALDownloaderPersistentFileManager
    .getAbsolutePhysicalPathOfFileWithUrl(url);
debugPrint(
    "ALDownloader | 通过[url]获取“物理文件路径”, url = $url, path = $path4\n");

final isExist = await ALDownloaderPersistentFileManager
    .isExistAbsolutePhysicalPathOfFileForUrl(url);
debugPrint(
    "ALDownloader | 检查[url]是否对应物理路径, url = $url, is Exist = $isExist\n");

final fileName = ALDownloaderPersistentFileManager.getFileNameFromUrl(url);
debugPrint(
    "ALDownloader | 通过[url]获取虚拟/物理的“文件名”, url = $url, file name = $fileName\n");
```

## Demo For iOS
- [main.dart](https://github.com/jackleemeta/al_downloader_flutter/blob/master/example/lib/main.dart)
- [AppDelegate.swift](https://github.com/jackleemeta/al_downloader_flutter/blob/master/example/ios/Runner/AppDelegate.swift)
- [Info.plist](https://github.com/jackleemeta/al_downloader_flutter/blob/master/example/ios/Runner/Info.plist)

> Maintainer: jackleemeta (jackleemeta@outlook.com)