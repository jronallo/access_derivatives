#! /usr/bin/env ruby

# process_video.rb /path/to/directory/of/video/files/

require 'tempfile'

directory = File.expand_path(ARGV[0])

output_directory = File.join(directory, 'output')
unless File.exist?(output_directory)
  Dir.mkdir(output_directory)
end

source_video_files = Dir.glob(File.join(directory, '*.mp4'))
['*.flv', '*.mov', '*.avi', '*.mkv'].each do |source_extension|
  source_video_files << Dir.glob(File.join(directory, source_extension))
end
source_video_files.flatten!.compact!

source_video_files.each do |filepath|
  extension = File.extname(filepath)
  basename = File.basename(filepath, extension)
  video_output_directory     = File.join(output_directory, basename)
  Dir.mkdir(video_output_directory) unless File.exist?(video_output_directory)
  video_output_filename_root = File.join(video_output_directory, basename)
  video_output_filename_mp4  = video_output_filename_root + '.mp4'
  video_output_filename_webm = video_output_filename_root + '.webm'

  # create a tempfile just to get a good temporary file path
  tempfile = Tempfile.new([basename, '.mp4'])
  temporary_mp4_file = tempfile.path
  tempfile.close
  tempfile.unlink

  # -filter:v "scale=640:480"
  `avconv -i #{filepath} -vcodec libx264 -vprofile baseline -preset slow -b:v 500k -maxrate 500k -bufsize 1000k \
    -threads 0 -acodec libvo_aacenc -b:a 128k #{temporary_mp4_file}`
  `qt-faststart #{temporary_mp4_file} #{video_output_filename_mp4}`

  `avconv -i "#{filepath}" -c:v libvpx -cpu-used 0 -b:v 600k -maxrate 600k -bufsize 1200k -qmin 10 -qmax 42 -threads 0 -codec:a libvorbis -b:a 128k "#{video_output_filename_webm}"`
end


