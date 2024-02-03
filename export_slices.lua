-- Executes cmd and returns the output
local function capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- prints only when UI is available, similar to app.alert
function print_ui(...)
  if app.isUIAvailable then
    print(...)
  end
end


function init(plugin)
  print_ui("Aseprite is initializing export_slices plugin by Linus045")

  -- we can use "plugin.preferences" as a table with fields for
  -- our plugin (these fields are saved between sessions)
  if plugin.preferences.last_project_path == nil then
    plugin.preferences.last_project_path = ""
  end

  if plugin.preferences.last_output_path == nil then
    plugin.preferences.last_output_path = ""
  end

  if plugin.preferences.preferred_file_format == nil then
    plugin.preferences.preferred_file_format = "{slice}.png"
  end

  if plugin.preferences.last_additional_arguments == nil then
    plugin.preferences.last_additional_arguments = ""
  end

  print_ui("- Adding Menu Group 'Linus045 Plugins' to 'File'")
  plugin:newMenuGroup{
    id="linus045_plugins",
    title="Linus045 Plugins",
    group="file_app"  
  }

  print_ui("- Adding new command 'Export slices as individual images'")
  plugin:newCommand{
    id="export_slices_to_images",
    title="Export slices as individual images",
    group="linus045_plugins",
    onclick=function()
      local dlg = Dialog("Export Slices")
      dlg
        :file{ 
          id="project_file",
          label="Aseprite Project File",
          title="Select project file",
          filename=plugin.preferences.last_project_path,
          entry=true,
          open=true,
          save=false,
          filetypes={ "aseprite", "ase" }
          }
      :file{ 
        id="output_directory",
        label="Output Directory",
        title="Select Output Directory",
        filename=plugin.preferences.last_output_path,
        entry=true,
        open=true,
        save=false,
        onchange=function()
          if app.fs.isFile(dlg.data.output_directory) then
            dlg.data.output_directory = app.fs.filePath(dlg.data.output_directory)
          end
          dlg:repaint()
        end
      }
      :entry{ id="file_format", label="Custom File Format:", text=plugin.preferences.preferred_file_format }
      :entry{ id="additional_arguments", label="Additional CLI Arguments:", text=plugin.preferences.last_additional_arguments }
      :button{
        text="Export",
        onclick=function()
          local aseprite_file = dlg.data.project_file
          local output_directory = dlg.data.output_directory
          local file_format = dlg.data.file_format
          local additional_arguments = dlg.data.additional_arguments

          if app.fs.isFile(output_directory) then
            output_directory = app.fs.filePath(dlg.data.output_directory)
          end

          if not string.find(file_format, "{slice}") then
            print_ui("Error: File format must contain the '{slice}' placeholder. E.g. 'item-{slice}.png'")
            return
          end

          local ext = file_format:match("^.+%.(.+)$")
          if not ext then
            print_ui("Error: File format must contain an extension. E.g. 'item-{slice}.png'")
            return
          end
      
          if app.fs.isFile(aseprite_file) and app.fs.isDirectory(output_directory) then
            plugin.preferences.last_project_path = aseprite_file
            plugin.preferences.last_output_path = output_directory
            plugin.preferences.preferred_file_format = file_format
            plugin.preferences.last_additional_arguments = additional_arguments
        
            local command = app.fs.appPath .. " " .. additional_arguments .." -b --split-slices \"".. aseprite_file .."\" --save-as \"" .. app.fs.joinPath(output_directory, file_format) .. "\""
            
            local command_dlg_data = Dialog("Command to run")
              :entry{ id="command_to_run", label="Command to run:", text=command , focus=false}
              :button{ id="cancel", text="Cancel" }
              :button{ id="confirm", text="Confirm" }
              :show{
                autoscrollbars=true,
                bounds = Rectangle()
              }.data

            if command_dlg_data.confirm then
              local output = capture(command, true) 
              print_ui("Command:")
              print_ui(command)
              print_ui("-------------------START OF OUTPUT-------------------")
              print_ui(output)
              print_ui("--------------------END OF OUTPUT--------------------")
              print_ui("\n\n")
              dlg:close()
              
              print_ui("Project file: '" .. aseprite_file .. "'")
              print_ui("Output Directory: '" .. output_directory .. "'")
              print_ui("\n\nFinished exporting slices as individual files to the output directory.")            
            end
          else
            print_ui("Project file: '" .. aseprite_file .. "'")
            print_ui("Output Directory: '" .. output_directory .. "'")
            print_ui("Error: project file or output directory did not exist!")
          end    
        end 
    }
    :show{
      wait=true
    }
  end
  }

  print_ui("Finished initialization\n\n")
  print_ui("To run either use the Keyboard Command (Keyboard Shortcuts->Commands->Export slices as individual images) or\nuse the menu option in File->Linus045 Plugins->Export slices as individual images")
end


function exit(plugin)
  print_ui("Removed export_slice plugin by Linus045 successfully")
end