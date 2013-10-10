#!/usr/bin/env ruby

# process_audio_from_video.rb path/to/directory/of/directories

directory = File.expand_path ARGV[0]

Dir.glob(File.join(directory,'*')).each do |video_directory|
  Dir.chdir(video_directory)
  mp4 = Dir.glob(File.join(video_directory, '*.mp4')).first
  base_filename = File.basename(mp4, '.mp4')
  puts base_filename

  # output mp3
  `avconv -i #{mp4} #{base_filename}.mp3`
  # output oga
  `avconv -i #{mp4} -acodec libvorbis -f ogg -vn #{base_filename}.oga`
end