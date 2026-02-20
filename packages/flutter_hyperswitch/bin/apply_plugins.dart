// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

class ApplyPlugins {
  static const String pathBuildGradle = 'android/build.gradle';
  static const String pathAppBuildGradle = 'android/app/build.gradle';

  static Future<void> start() async {
    print("Running for android");

    if (!await File(pathBuildGradle).exists() ||
        !await File(pathAppBuildGradle).exists()) {
      print(
        'ERROR:: build.gradle file not found. Check if you have a correct android directory present in your project.'
        '\n\nRun "flutter create ." to regenerate missing files.',
      );
      return;
    }

    await _updateProjectBuildGradle();
    await _updateAppBuildGradle();

    print('Finished updating android build.gradle files.');
  }

  static Future<void> _updateProjectBuildGradle() async {
    final buildGradleFile = File(pathBuildGradle);
    String content = await buildGradleFile.readAsString();

    // Remove old classpath if present
    final oldClasspathPattern = RegExp(
      r'classpath "io.hyperswitch:hyperswitch-gradle-plugin:.*?"',
    );
    content = oldClasspathPattern.hasMatch(content)
        ? content.replaceAll(oldClasspathPattern, '')
        : content;

    // Add the buildscript block with mavenCentral and new classpath
    if (!content.contains('buildscript {')) {
      content = '''
buildscript {
    repositories {
        mavenCentral()
        google()
    }
    dependencies {
        classpath "io.hyperswitch:hyperswitch-gradle-plugin:0.2.6"
    }
}

$content''';
      print(
        'Added buildscript block with mavenCentral and Hyperswitch classpath to project-level build.gradle.',
      );
    }
    // If buildscript exists, ensure mavenCentral and new classpath are added
    else {
      if (!content.contains('mavenCentral()')) {
        content = content.replaceFirst(
          'repositories {',
          'repositories {\n        mavenCentral()',
        );
        print('Added mavenCentral() to project-level build.gradle.');
      }
      if (!content.contains(
        'classpath "io.hyperswitch:hyperswitch-gradle-plugin:0.2.6"',
      )) {
        content = content.replaceFirst(
          'dependencies {',
          'dependencies {\n        classpath "io.hyperswitch:hyperswitch-gradle-plugin:0.2.6"',
        );
        print('Updated project-level build.gradle with Hyperswitch classpath.');
      } else {
        print('Classpath already present in project-level build.gradle.');
      }
    }

    await buildGradleFile.writeAsString(content);
  }

  static Future<void> _updateAppBuildGradle() async {
    final appBuildGradleFile = File(pathAppBuildGradle);
    String content = await appBuildGradleFile.readAsString();

    // Add plugin if not already present
    if (!content.contains("id 'io.hyperswitch.plugin'")) {
      content = content.replaceFirst(
        'plugins {',
        'plugins {\n    // Add the Hyperswitch plugin to optimize build size\n    id \'io.hyperswitch.plugin\'',
      );
      print('Updated app-level build.gradle with Hyperswitch plugin.');
    } else {
      print('Hyperswitch plugin already present in app-level build.gradle.');
    }

    // Replace minSdk = flutter.minSdkVersion with minSdk = 24
    if (content.contains('minSdk = 24') || content.contains('minSdk 24')) {
      print('minSdk is already set to 24 in app-level build.gradle.');
    } else if (content.contains('minSdk = flutter.minSdkVersion')) {
      content = content.replaceFirst(
        'minSdk = flutter.minSdkVersion',
        'minSdk = 24 //flutter.minSdkVersion',
      );
      print('Updated minSdk to 24 in app-level build.gradle.');
    } else if (content.contains('minSdk = ')) {
      content = content.replaceFirst('minSdk = ', 'minSdk = 24 //');
      print('Updated minSdk to 24 in app-level build.gradle.');
    } else {
      print('minSdk not found in app-level build.gradle.');
    }

    await appBuildGradleFile.writeAsString(content);
  }
}

void main() {
  ApplyPlugins.start();
}
