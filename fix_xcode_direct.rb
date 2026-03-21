require 'xcodeproj'

project_path = '/Users/derin/Desktop/CODING/GoldenRatioCamera/Golden Ratio Camera/Golden Ratio Camera.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Get all swift files in the project directory
base_dir = '/Users/derin/Desktop/CODING/GoldenRatioCamera/Golden Ratio Camera/Golden Ratio Camera'
swift_files = Dir.glob("#{base_dir}/**/*.swift")

swift_files.each do |file_path|
  # Create a file reference if it doesn't exist
  # We'll put them in the main group for simplicity
  file_name = File.basename(file_path)
  
  # Check if already in build phase
  exists = target.source_build_phase.files.any? { |f| f.file_ref && f.file_ref.path && file_path.end_with?(f.file_ref.path) }
  
  unless exists
    file_ref = project.main_group.new_file(file_path)
    target.add_file_references([file_ref])
    puts "Linked: #{file_name}"
  end
end

project.save
puts "Done!"
