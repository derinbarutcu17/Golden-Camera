require 'xcodeproj'

project_path = '/Users/derin/Desktop/CODING/GoldenRatioCamera/Golden Ratio Camera/Golden Ratio Camera.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Helper to find or add files to a target
def add_files_to_target(project, target, group, dir_path)
  Dir.entries(dir_path).each do |entry|
    next if entry.start_with?('.')
    
    full_path = File.join(dir_path, entry)
    if File.directory?(full_path)
      # In synchronized groups, the group might already exist
      subgroup = group.children.find { |c| c.name == entry || c.path == entry } || group.new_group(entry, entry)
      add_files_to_target(project, target, subgroup, full_path)
    else
      file_ref = group.children.find { |c| c.name == entry || c.path == entry } || group.new_file(full_path)
      
      if entry.end_with?('.swift')
        unless target.source_build_phase.files_references.include?(file_ref)
          target.add_file_references([file_ref])
          puts "Added to Compile Sources: #{entry}"
        end
      elsif entry.end_with?('.plist') || entry.end_with?('.xcassets') || entry.end_with?('.json')
        unless target.resources_build_phase.files_references.include?(file_ref)
          target.resources_build_phase.add_file_reference(file_ref)
          puts "Added to Resources: #{entry}"
        end
      end
    end
  end
end

# The root group of the project (usually the first child under main_group that isn't a Framework/Test group)
main_group_name = 'Golden Ratio Camera'
app_group = project.main_group.children.find do |c| 
  (c.respond_to?(:name) && c.name == main_group_name) || 
  (c.respond_to?(:path) && c.path == main_group_name) ||
  (c.respond_to?(:path) && c.path.end_with?(main_group_name))
end

if app_group
  # Our files are now inside this group's physical path
  # We need to make sure they are included in the target
  group_path = app_group.respond_to?(:real_path) ? app_group.real_path : File.join(File.dirname(project_path), main_group_name)
  add_files_to_target(project, target, app_group, group_path)
else
  puts "Warning: Could not find app group '#{main_group_name}'"
end

project.save
puts "Project build phases updated!"
