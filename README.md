# Riru

Riru only does one thing, inject into zygote in order to allow modules to run their codes in apps or the system server.

> The name, Riru, comes from a character. (https://www.pixiv.net/member_illust.php?mode=medium&illust_id=74128856)

## Riru-Shell

由于 `Riru` 平台的实现原理并不完全依赖 `Magisk`
所以可以自行编写脚本实现 **免 `Magisk` 手动刷入**
不过真机对于系统文件有保护等乱七八糟的东西, 并且一旦出问题必定炸鸡
所以 **!!!! 请不要在真机上运行 `!install.sh` 手动刷入脚本 !!!!**
`手动刷入脚本`食用教程: [Riru-Shell 刷入教程](https://www.bilibili.com/video/BV1zr4y1c7X4/)

## Shell-Install 刷入流程

1. 使用 `安卓7` 以上带 `ROOT` 的全新 `ROM`
2. 安装 `MT管理器` 或其他带终端的文件管理器, 并且导入 `刷入包` 进行解压
3. 进入解压出来的文件夹, 以 `ROOT` 权限执行 `!install.sh` 脚本

## 下载链接

- 刷入包(zip)
  [GitHub release](https://github.com/HimekoEx/Riru-Shell/releases)

- "Riru" 应用程序(状态显示器)
  [Download](https://github.com/HimekoEx/Riru-Shell/releases/download/Riru-Shell-v23.3/Riru-Shell-v23.0.r266.apk)

## Requirements

Android 6.0+ devices rooted with [Magisk](https://github.com/topjohnwu/Magisk)

## Guide

### Install

- From Magisk Manager

  1. Search "Riru" in Magisk Manager
  2. Install the module named "Riru"

  > The Magisk version requirement is enforced by Magisk Manager. At the time of the release of Magisk v21.1, the requirement is v20.4.

- Manually

  1. Download the zip from the [GitHub release](https://github.com/RikkaApps/Riru/releases)
  2. Install in Magisk Manager (Modules - Install from storage - Select downloaded zip)

- "Riru" app (show Riru status)

  [Download](https://github.com/RikkaApps/Riru/releases/download/v23.0/riru-v23.0.r235.d313e94.apk)

**If you are using other modules that change `ro.dalvik.vm.native.bridge`, Riru will not work.** (Riru will automatically set it back)

A typical example is, some "optimize" modules change this property. Since changing this property is meaningless for "optimization", their quality is very questionable. In fact, changing properties for optimization is a joke.

### Config

- When the file `/data/adb/riru/disable` exists, Riru will do nothing
- When the file `/data/adb/riru/enable_hide` exists, the hidden mechanism will be enabled (also requires the support of the modules)

## How Riru works?

- How to inject into the zygote process?

  Before v22.0, we use the method of replacing a system library (libmemtrack) that will be loaded by zygote. However, it seems to cause some weird problems. Maybe because libmemtrack is used by something else.

  Then we found a super easy way, the "native bridge" (`ro.dalvik.vm.native.bridge`). The specific "so" file will be automatically "dlopen-ed" and "dlclose-ed" by the system. This way is from [here](https://github.com/canyie/NbInjection).

- How to know if we are in an app process or a system server process?

  Some JNI functions (`com.android.internal.os.Zygote#nativeForkAndSpecialize` & `com.android.internal.os.Zygote#nativeForkSystemServer`) is to fork the app process or the system server process.
  So we need to replace these functions with ours. This part is simple, hook `jniRegisterNativeMethods` since all Java native methods in `libandroid_runtime.so` is registered through this function.
  Then we can call the original `jniRegisterNativeMethods` again to replace them.

## How does Hide works?

From v22.0, Riru provides a hidden mechanism (idea from [Haruue Icymoon](https://github.com/haruue)), make the memory of Riru and module to anonymous memory to hide from "`/proc/maps` string scanning".

## Build

Run gradle task `:riru:assembleRelease` task from Android Studio or the terminal, zip will be saved to `out`.

## Module template

https://github.com/RikkaApps/Riru-ModuleTemplate

## Module API changes

https://github.com/RikkaApps/Riru-ModuleTemplate/blob/master/README.md#api-changes
