#! /usr/bin/env ruby

# wav_to_ogg_mp3.rb /path/to/directory/of/WAV_files
# script to convert batch of WAV files to mp3 and ogg

def create_filename_from_orig_filepath_and_extension(filepath, ext)
  orig_filename = File.basename(filepath, File.extname(filepath))
  File.join(tmp_audio_directory, orig_filename, orig_filename + '.' + ext)
end

def tmp_audio_directory
  File.join(File.expand_path(ARGV[0]), '..', 'converted_wav_audio')
end

if !ARGV[0]
  puts "must specify a path to a directory of wav files"
  exit
end
wav_directory = File.expand_path(ARGV[0])

Dir.mkdir(tmp_audio_directory) unless File.exists?(tmp_audio_directory)
Dir.glob(File.join(wav_directory, '*')) do |wav|
  orig_filename = File.basename(wav, File.extname(wav))

  # oggenc automatically creates the orig_filename directory we need
  ogg_filepath = create_filename_from_orig_filepath_and_extension(wav, 'ogg')
  `oggenc #{wav} -q 0 -o #{ogg_filepath}`

  mp3_filepath = create_filename_from_orig_filepath_and_extension(wav, 'mp3')
  `lame -V 9 --vbr-new -mm -h -q 0 #{wav} #{mp3_filepath}`
end
