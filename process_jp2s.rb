#!/usr/bin/env ruby

require 'pp'
require 'rubygems'
require 'slop'
require 'kakadoer'

opts = Slop.parse do
  banner <<EOF
    ruby process_jp2s.rb [options]

    Example validating output:
    process_jp2s.rb -i /media/Elements/tifs -o /media/Elements/jp2s

EOF

  on :i, :input=,'path to directory of tif folders'
  on :o, :out=,'path to output JP2s'
  on :h, :help, 'Print help and exit'
  on :v, :verbose, 'Print verbose output'
  on :a, :validate, 'validate that the number of tifs matches the number of jp2s and that there are not duplicate filenames in the batch'
  on :r, :reprocess, 'Re-process tifs to JP2s overwriting existing jp2s'
end

def select_files(directory, glob='*')
  Dir.glob(File.join(directory, glob)).select { |file| File.file?(file) }.sort
end

def folders(directory)
  Dir.glob(File.join(directory, '*')).sort
end

class Array
  def find_dups
    uniq.map {|v| (self - [v]).size < (self.size - 1) ? v : nil}.compact
  end
end

if opts.help?
  puts opts
  exit
elsif opts.validate?
  tifs = folders(opts[:input]).map do |folder|
    select_files(folder, '*.tif').map{|file| File.basename(file, '.tif')}
  end.flatten
  jp2s = select_files(opts[:out], '*.jp2').map{|file| File.basename(file, '.jp2')}
  tifs_left = tifs - jp2s
  jp2s_left = jp2s - tifs
  puts "tifs left: #{tifs_left}"
  puts "jp2s left: #{jp2s_left}"
  puts "tifs: #{tifs.length}"
  puts "jp2s: #{jp2s.length}"
  puts "unique tifs: #{tifs.uniq.count}"
  puts "duplicate tifs: #{tifs.find_dups}"
  exit
else
  opt = opts.to_hash
end

pp opt

total_files = 0

folders = folders(opt[:input])
puts folders if opts.verbose?
errors = []


folders.each do |folder|
  puts "=============\n#{folder}"
  files = select_files(folder, '*.tif')
  puts files.length
  total_files += files.length

  files.each_with_index do |file, index|
    basename = File.basename(file, '.tif')
    matching_jp2 = File.join(opt[:out], "#{basename}.jp2")
    if File.exist?(matching_jp2) and !opts[:reprocess]
      puts "JP2 already exists: #{file}"
      next
    end
    puts "#{index}  #{file}" if opts.verbose?
    kakado_cmd = Kakadoer::Command.new(file, opt[:out])
    puts kakado_cmd.kakado_cmd if opts.verbose?
    begin
      output = kakado_cmd.kakado
    rescue => e
      puts "ERROR! ===================="
      puts file
      puts e
      puts e.backtrace
      puts "--------------------"
    end
    puts output if opts.verbose?
    if !File.exist?(matching_jp2)
      errors << file
    end
  end

end

puts "Total Files to process: #{total_files}"
jp2_files = select_files(opt[:out], '*.jp2')
puts "Total Files processed:  #{jp2_files.count}"

puts '===='
puts "Errors:"
pp errors




