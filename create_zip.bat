if exist export_slices.aseprite-extension del export_slices.aseprite-extension
if exist export_slices.zip del export_slices.zip

tar -acf export_slices.zip README.md export_slices.lua package.json LICENSE

rename export_slices.zip export_slices.aseprite-extension