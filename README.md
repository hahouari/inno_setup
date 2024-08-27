# Inno Bundle

[![pub package](https://img.shields.io/pub/v/inno_bundle.svg)](https://pub.dev/packages/inno_bundle)
![chocolatey version](https://img.shields.io/chocolatey/v/InnoSetup)
[![inno setup](https://img.shields.io/badge/Inno_Setup-v6.3.3-blue)](https://jrsoftware.org/isinfo.php)
![hahouari-inno-setup](https://img.shields.io/badge/@hahouari-Inno_Setup-blue)

A command-line tool that simplifies bundling your app into an EXE installer for
Microsoft Windows. Customizable with options to configure the installer
capabilities.

# Guide

## 1. Install Inno Setup

The easiest way to install latest version of Inno Setup is using WinGet:

```sh
winget install -e --id JRSoftware.InnoSetup
```

If you do not have WinGet, here is how to [install it](https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget), or find out [other methods](https://github.com/hahouari/inno_bundle/wiki/Install-Inno-Setup) to install Inno Setup.

_Note: This package is tested on Inno Setup version `6.3.3`._

## 2. Install `inno_bundle` package into your project

```sh
dart pub add dev:inno_bundle
```

## 3. Generate App ID

Every application has its own unique GUID, here is how to generate one:

```sh
# generate id based upon a namespace (Recommended)
dart run inno_bundle:id --ns "www.example.com"

# or use this to generate a random GUID
dart run inno_bundle:id
```

The output id is going to be something similar to this:

> f887d5f0-4690-1e07-8efc-d16ea7711bfb

Copy & Paste the output to your `pubspec.yaml` as shown in the next step.

## 4. Set up the Configuration

Add your configuration to your `pubspec.yaml`. example:

```yaml
inno_bundle:
  id: f887d5f0-4690-1e07-8efc-d16ea7711bfb # <-- Put your app id here
  publisher: Your Name # Optional, but recommended.
  name: Demo App # Also optional, but recommended.
```

For more advanced configuration with examples, see [Configuration Options](https://github.com/hahouari/inno_bundle/wiki/Configuration-Options).

## 5. Build the Installer

After setting up the configuration, all that is left to do is run the build command

```sh
dart run inno_bundle:build --release
```

If you need other use cases with our CLI tool, look up [CLI Options](https://github.com/hahouari/inno_bundle/wiki/CLI-Tool-Options).

# More Options and Examples

You can find more detailed documentation on customizing `inno_bundle`, including examples, on the [GitHub wiki pages](https://github.com/hahouari/inno_bundle/wiki).

# Using GitHub Workflow?

To automate the process of building the installer with GitHub Actions, refer to [this demo](https://github.com/hahouari/flutter_inno_workflows_demo).

You can copy the [build.yaml](https://github.com/hahouari/flutter_inno_workflows_demo/blob/dev/.github/workflows/build.yaml) file into your project and make sure to update [the push branch](https://github.com/hahouari/flutter_inno_workflows_demo/blob/fb49da23996161acc80f0e9f4c169a01908a29a7/.github/workflows/build.yaml#L5). This setup will build the installer and publish it to [GitHub Releases](https://github.com/hahouari/flutter_inno_workflows_demo/releases) with the appropriate versioning.

# DLL Files Handling

`inno_bundle` handles including all necessary DLL files within the installer. For more info, refer to [this page](https://github.com/hahouari/inno_bundle/wiki/Handling-Missing-DLL-Files).

# Reporting Issues

If you encounter any issues <a href="https://github.com/hahouari/inno_bundle/issues" target="_blank">please report them here</a>.
