require 'xcodeproj'

project_path = '/Users/derin/Desktop/CODING/GoldenRatioCamera/Golden Ratio Camera/Golden Ratio Camera.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# 1. Remove bad folder references from the main group level or root
dirs_to_handle = ['App', 'Domain', 'Features', 'Resources', 'Services', 'Utilities', 'Tests']

project.main_group.children.each do |child|
  if child.class == Xcodeproj::Project::Object::PBXFileReference && dirs_to_handle.include?(child.name)
    child.remove_from_project
  end
end

# Find the main app group (where ContentView normally lives)
main_app_group = project.main_group.children.find { |c| c.name == 'Golden Ratio Camera' || c.path == 'Golden Ratio Camera' }

if main_app_group
  # 2. Delete default template files
  files_to_delete = ['Golden_Ratio_CameraApp.swift', 'ContentView.swift', 'Item.swift']
  files_to_delete.each do |filename|
    file_ref = main_app_group.children.find { |c| c.name == filename || c.path == filename }
    if file_ref
      # remove from build phases
      target.source_build_phase.files_references.delete(file_ref)
      # remove from group
      file_ref.remove_from_project
    end
  end
end

# 3. Add our folders as real groups with compiled sources
def add_files_recursively(group, dir_path, target)
  Dir.entries(dir_path).each do |entry|
    next if entry == '.' || entry == '..'
    
    full_path = File.join(dir_path, entry)
    if File.directory?(full_path)
      subgroup = group.children.find { |c| c.name == entry || c.path == entry } || group.new_group(entry, entry)
      add_files_recursively(subgroup, full_path, target)
    else
      # Only add specific files
      if entry.end_with?('.swift')
        file_ref = group.children.find { |c| c.name == entry || c.path == entry } || group.new_file(entry)
        # Add to compile sources if not already there
        unless target.source_build_phase.files_references.include?(file_ref)
          target.add_file_references([file_ref])
        end
      elsif entry.end_with?('.plist')
        file_ref = group.children.find { |c| c.name == entry || c.path == entry } || group.new_file(entry)
      elsif entry.end_with?('.xcassets')
        # Assets want a file reference
        file_ref = group.children.find { |c| c.name == entry || c.path == entry } || group.new_file(entry)
        unless target.resources_build_phase.files_references.include?(file_ref)
          target.resources_build_phase.add_file_reference(file_ref)
        end
      end
    end
  end
end

# Our actual custom files are physically placed in /Users/derin/Desktop/CODING/GoldenRatioCamera/
# Not inside the inner folder. So we add groups referencing those outer folders.

base_dir = '/Users/derin/Desktop/CODING/GoldenRatioCamera'
dirs_to_handle.each do |dir_name|
  dir_path = File.join(base_dir, dir_name)
  next unless Dir.exist?(dir_path)
  
  # Create a top-level group linking to that folder
  group = project.main_group.children.find { |c| c.name == dir_name || c.path == dir_path } 
  unless group
    group = project.main_group.new_group(dir_name, dir_path)
  end
  
  add_files_recursively(group, dir_path, target)
end

project.save
puts "Project successfully updated!"
