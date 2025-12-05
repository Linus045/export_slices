# export_slices plugin for [Aseprite](https://aseprite.org)

## Description
This plugin adds a new command that allows you to export [slices](https://www.aseprite.org/docs/slices/) as individual image files.

This script utilizes Aseprite's CLI argument [`--split-slices`](https://www.aseprite.org/docs/cli//#split-slices) and passes along the project path and output directory as well as any additional parameters.

Also see my [Aseprite Forum Post](<https://community.aseprite.org/t/script-extension-export-slices-by-linus045-basically-a-gui-wrapper-for-the-cli-option-split-slices/21375>)

## Installation
Download the extension from the [`Releases` tab](https://github.com/Linus045/export_slices/releases).

Open Aseprite's extensions menu `Edit->Preferences->Extensions` and click `Add Extension`.

Select the `export_slices.aseprite-extension` file and that's it.

## Usage
Create your sprites and [slice](https://www.aseprite.org/docs/slices/) them appropriately.
The name of the slice will later determine the exported filename.

Here I created a few simple 16x16 sprites, each slice gets exported as an individual file:

<img alt='Slicing Example' src='https://i.imgur.com/TfFqPBZ.png' width='400'>
<img alt='Exported slices' src='https://i.imgur.com/eHC3C8i.png' width='400'>


Click the new option in `File->Linus045 Plugins->Export slices as individual images`.

A Dialog with text entries will appear.

![Export Dialog with text entries](https://i.imgur.com/oKD2m9o.png)

### Project File
Project file specifies the `.aseprite` project file that contains the [slices](https://www.aseprite.org/docs/slices/).
Simply enter the path to the project file or click the button next to the entry field to use the system's file selector.

### Output Directory
This sets the path to the output directory.
As of now the aseprite plugin API does not have a dialog element to select a directory directly via the system's file selector.
You can either enter the path manually/paste it in or use the file selector and select any file inside the output directory, for example the .aseprite project file, the plugin will
then automatically use the file's directory as output directory.

### File Format
The file format text entry specifies the exported file names for each slice.
It is directly passed on to the [`--save-as`](https://www.aseprite.org/docs/cli//#save-as) CLI parameter.
The `{slice}` placeholder is required and will be replaced with the slice's name.

### Scaling factor
These options allow scaling the output images.
You can choose between selecting a value from the predefined dropdown or enter a custom value.
It is directly passed on to the [`--scale`](https://www.aseprite.org/docs/cli//#scale) CLI parameter.

### Additional Arguments
The last text entry is used for custom CLI arguments see [Aseprite CLI](https://www.aseprite.org/docs/cli//#options) documentation for more info.
The arguments are inserted in a predetermined position inside the command, if the position is incorrect use the confirmation dialog to edit the command before running (see `Show command before running` checkbox below).
If there is an argument you frequently use, feel free to create a GitHub issue or a message on 
the [Aseprite Forum Post](<https://community.aseprite.org/t/script-extension-export-slices-by-linus045-basically-a-gui-wrapper-for-the-cli-option-split-slices/21375>) 
and I might be able to add addition UI elements to make the process easier.

### Close dialog after export
This checkbox simply determines if the dialog closes after the export is done.

### Show command before running
This checkbox opens a dialog before running the actual command.
This is simply to verify everything or, if necessary, fix mistakes.
Normally you can just press `Confirm` and the plugin will continue to execute the command and export the slices.


![Command confirm dialog](https://i.imgur.com/87f5LPX.png)


### Export Button
After pressing the `Export` button the plugin will start exporting the slices.

Afterwards an output dialog will open up showing the command output.
![Command output dialog](https://i.imgur.com/eBnrPrP.png)

## Keyboard Shortcut
It is possible to open the dialog via keyboard shortcut.
Simply bind a new key by navigating to `Edit->Keyboard Shortcuts` and search for `Linus045`.

![Keyboard Shortcuts](https://i.imgur.com/pCT2uSZ.png)
