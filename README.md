# export_slices plugin for [Aseprite](https://aseprite.org)

## Description
This plugin adds a new command that allows you to export [slices](https://www.aseprite.org/docs/slices/) as individual image files.

This plugin uses aseprites CLI [`--split-slices`](https://www.aseprite.org/docs/cli//#split-slices) option to export the files.

## Installation
Simply open Aseprite's extensions menu `Edit->Preferences->Extensions` and click `Add Extension`.
Select the `export_slices.aseprite-extension` file and that's it.

## Usage
Click the new option in `File->Linus045 Plugins->Export slices as individual images`.

A Dialog with text entries will appear.

The first one specifies the `.aseprite` project file that contains the [slices](https://www.aseprite.org/docs/slices/).
Simply enter the path to the project file or click the button next to the entry field to use your system's file selector.


The second text entry is the path to the output directory.
As of now the aseprite plugin API does not have a dialog element to select a directory directly via the system's file selector.
You can either enter the path manually/paste it in or use the file selector and select any file inside the output directory, the plugin will
automatically use the file's parent directory as output directory.


The third text entry specifies the output file format.
It is directly passed on to the [`--save-as`](https://www.aseprite.org/docs/cli//#save-as) CLI parameter.


The fourth text entry is used for custom CLI arguments see [Aseprite CLI](https://www.aseprite.org/docs/cli//#options) documentation for more info.

After pressing the `Export` button a new dialog appears with the command to execute.
This is simply to verify everything or if necessary fix mistakes.
Normally you can just press `Confirm` and the plugin will now execute the command to export the slices.

Afterwards an output dialog will open up showing the command output.


## Note
This script actively executes the Aseprite with CLI argument [`--split-slices`](https://www.aseprite.org/docs/cli//#split-slices) and passes in the project path and output directory.