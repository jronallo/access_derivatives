#!/usr/bin/env ruby

# unbag_tifs.rb

require 'pp'
require 'fileutils'
require 'rubygems'
require 'slop'

opts = Slop.parse do
  banner "ruby unbag_tifs.rb [options]"
 
  on :b, :bags=,'path to exHD where bags are'
  on :s, :size, 'determine the size of all of the tifs without transferring'
  on :o, :output=, 'which directory to output the files to'
  on :v, :verbose, 'verbose output'
  on :h, :help, "print out this help"
end

if opts.help?
  puts opts
  exit
end
if !opts[:bags]
  puts "you must give a path to the exHD\n-b /media/exHD/"
  exit  
end
if !File.exist? opts[:bags]
  puts "The path to the exHD does not exist"
  exit
end
if opts[:output]
  output = opts[:output]
else
  output = '/media/Elements/car'
end

source_tif_count = 0
total_size = 0
Dir.glob(File.join(opts[:bags], '*_{bag,BAG}/')).sort.each do |bag_path|
  basename = File.basename(bag_path)
  if opts.verbose?
    puts '==============='
    puts basename
  end
  mkdir = File.join(output, basename)
  Dir.mkdir(mkdir) unless File.exist?(mkdir) or opts.size?
  Dir.glob(File.join(bag_path, 'data/*/*/{tiff,tif}/*.tif')).sort.each do |tif|
    source_tif_count += 1
    puts tif if opts.verbose?
    if opts.size?      
      total_size += File.size(tif)
    end
    FileUtils.copy( tif, File.join(mkdir) ) unless opts.size?
  end  
end

puts "#{source_tif_count} incoming files from bags"
destination_count = Dir.glob(File.join(output, '*/*.tif')).length
puts "#{destination_count} copied files ready to be processed"

if opts.size?
  gb = total_size / (1024.0 * 1024.0 * 1024.0)
  puts "#{gb} GB"
end
