-- Executes cmd and returns the output
local function capture(cmd, raw)
  -- always redirect stderr to stdout
  local handle = assert(io.popen(cmd.." 2>&1", 'r'))
  local output = assert(handle:read('*a'))
  local success, exit, signal = handle:close()
  if raw then 
    return output
  end

  output = string.gsub(output, '^%s+', '')
  output = string.gsub(output, '%s+$', '')
  output = string.gsub(output, '[\n\r]+', ' ')

  return "Command exited with code: " .. tostring(signal) .. " - (" .. tostring(exit) .. ")\n" .. output
end

-- prints only when UI is available, similar to app.alert
function print_ui(...)
  if app.isUIAvailable then
    print(...)
  end
end

function run_export_command(dlg, command_to_run, close_dialog_after_export, aseprite_file, output_directory)
  local output = capture(command_to_run, false)
  print_ui("Command:")
  print_ui(command_to_run)
  print_ui("-------------------START OF OUTPUT-------------------")
  print_ui(output)
  print_ui("--------------------END OF OUTPUT--------------------")
  print_ui("\n\n")

  if close_dialog_after_export then
    dlg:close()
  end
  
  print_ui("Project file: '" .. aseprite_file .. "'")
  print_ui("Output Directory: '" .. output_directory .. "'")
  print_ui("\n\nFinished exporting slices as individual files to the output directory.")
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

  if plugin.preferences.custom_scaling_factor == nil then
    plugin.preferences.custom_scaling_factor = 1
  end

  if plugin.preferences.close_dialog_after_export == nil then
    plugin.preferences.close_dialog_after_export = true
  end

  if plugin.preferences.show_command_before_running == nil then
    plugin.preferences.show_command_before_running = true
  end

  print_ui("- Adding Menu Group 'Linus045 Plugins' to 'File'")
  plugin:newMenuGroup{
    id="linus045_plugins",
    title="Linus045 Plugins",
    group="file_app"  
  }

  print_ui("- Adding new command 'Export slices as individual images' (see Keyboard Shortcuts)")
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
      :separator{}
      :radio{ 
        label="Scaling factor type",
        id="scaling_factor_radio_predefined_value",
        text="Predefined",
        onclick=function()
            dlg:modify{ id="scaling_factor_combo", visible=dlg.data.scaling_factor_radio_predefined_value }
            dlg:modify{ id="scaling_factor_custom", visible=not dlg.data.scaling_factor_radio_predefined_value }
            dlg:repaint()
        end 
      }
      :radio{ 
        id="scaling_factor_radio_custom_value",
        text="Custom",
        selected=true,
        onclick=function()
            dlg:modify{ id="scaling_factor_custom", visible=not dlg.data.scaling_factor_radio_predefined_value }
            dlg:modify{ id="scaling_factor_combo", visible=dlg.data.scaling_factor_radio_predefined_value }
            dlg:repaint()
        end 
      }
      :combobox{ 
        id="scaling_factor_combo",
        label="Scaling factor:",
        visible=false,
        option=plugin.preferences.last_scaling_factor,
        options={ "0.1", "0.5", "1", "2", "3", "4", "5", "10", "20", "50", "100", "200" }
      }
      :entry{ 
        id="scaling_factor_custom", 
        label="Custom scaling factor:", 
        text=plugin.preferences.last_scaling_factor,
        visible=true
      }
      :separator{}
      :entry{ id="additional_arguments", label="Additional CLI Arguments:", text=plugin.preferences.last_additional_arguments }
      :separator{}
      :check{ 
        id="checkbox_close_dialog_after_export",
        label="Close dialog after export",
        text="",
        selected=plugin.preferences.close_dialog_after_export,
      }
      :check{ 
        id="show_command_before_running",
        label="Show command before running",
        text="(to verify or modify before running)",
        selected=plugin.preferences.show_command_before_running,
      }
      :separator{}
      :button{
        text="Export",
        onclick=function()
          local aseprite_file = dlg.data.project_file
          local output_directory = dlg.data.output_directory
          local file_format = dlg.data.file_format
          local additional_arguments = dlg.data.additional_arguments
          local close_dialog_after_export = dlg.data.checkbox_close_dialog_after_export
          local show_command_before_running = dlg.data.show_command_before_running

          local custom_scaling_factor = ""
          if dlg.data.scaling_factor_radio_predefined_value then
            custom_scaling_factor = dlg.data.scaling_factor_combo and dlg.data.scaling_factor_combo
          else
            custom_scaling_factor = dlg.data.scaling_factor_custom and dlg.data.scaling_factor_custom
          end

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
            plugin.preferences.close_dialog_after_export = close_dialog_after_export
            plugin.preferences.show_command_before_running = show_command_before_running
            
            local scaling_arguments = ""
            if (custom_scaling_factor ~= nil) and (custom_scaling_factor ~= "") then
              plugin.preferences.last_scaling_factor = custom_scaling_factor
              
              if custom_scaling_factor ~= "1" then
                scaling_arguments = "--scale " .. custom_scaling_factor                
              end
            end

            local command = app.fs.appPath .. " -b \"" .. aseprite_file .. "\" " .. scaling_arguments .. " " .. additional_arguments .. " --split-slices --save-as \"" .. app.fs.joinPath(output_directory, file_format) .. "\""

            if show_command_before_running then
              local command_dlg_data = Dialog("Command to run")
                :entry{ id="command_to_run", label="Command to run:", text=command , focus=false}
                :button{ id="cancel", text="Cancel" }
                :button{ id="confirm", text="Confirm" }
                :show{
                  autoscrollbars=true,
                  bounds = Rectangle()
                }.data

              if command_dlg_data.confirm then
                run_export_command(dlg, command_dlg_data.command_to_run, close_dialog_after_export, aseprite_file, output_directory)
              end
            else
                run_export_command(dlg, command, close_dialog_after_export, aseprite_file, output_directory)
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
