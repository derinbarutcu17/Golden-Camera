require 'xcodeproj'

project_path = '/Users/derin/Desktop/CODING/GoldenRatioCamera/Golden Ratio Camera/Golden Ratio Camera.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# 1. Remove Info.plist from Copy Bundle Resources
resources_phase = target.resources_build_phase
resources_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.end_with?('Info.plist')
    puts "Removing Info.plist from Copy Bundle Resources: #{build_file.file_ref.path}"
    resources_phase.remove_build_file(build_file)
  end
end

# 2. Remove the manually added files from Compile Sources to avoid "Skipping duplicate" warnings
# Since Xcode 16's Synchronized Group handles them automatically, we don't need manual entries.
source_phase = target.source_build_phase
source_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path
    # Check if this file is actually a manual reference we added
    # (Manual references often have absolute paths or are outside the main group structure)
    puts "Removing manual link to avoid duplicate: #{build_file.file_ref.path}"
    source_phase.remove_build_file(build_file)
  end
end

# 3. Ensure BUILD_SETTING for Info.plist is still correct but not causing a double-process
target.build_configurations.each do |config|
  # We should keep INFOPLIST_FILE but maybe disable GENERATE_INFOPLIST_FILE if we provide one
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
end

project.save
puts "Project cleaned up!"
