#!/usr/bin/env ruby
#
# install.rb - Setup Plato
#
# Usage: ruby install.rb [instdir]
#   instdir:  'Plato' install directory
#             default:
#               Windows     C:\plato
#               Mac/Linux   ~/plato
#
require 'fileutils'
require 'json'

puts "Setup 'Plato'"

# Get platform
$platform = case RUBY_PLATFORM.downcase
when /mswin(?!ce)|mingw|cygwin|bccwin/
  :windows
when /darwin/
  :mac
when /linux/
  :linux
else
  :other
end

srcdir = File.dirname(File.expand_path($0))

instdir = ARGV[0]
unless instdir
  instdir = ($platform == :windows) ? 'C:/plato' : File.join(Dir.home, 'plato')
  # print "Installation directory (#{instdir}) : "
  # dir = gets.chomp
  # instdir = dir if dir.size > 0
end

# Write plato.cfg
appdir = $platform == :windows ? ENV["APPDATA"] : Dir.home
cfgfile = File.join(appdir, '.plato', 'plato.cfg')
FileUtils.mkdir_p(File.dirname(cfgfile))
cfg = {}
# begin
#   cfg = JSON::parse(File.read(cfgfile))
# rescue
# end
cfg["instdir"] = instdir
File.write(cfgfile, JSON::generate(cfg))

# Enumerate install files
dirs = Dir.glob(
  [File.join(srcdir, "*"),
  File.join(srcdir, "\.[^\.]*")],
) - [ # exclude files
  File.expand_path($0),
  File.join(srcdir, 'shortcut.vbs')
]

# Create install directory
FileUtils.mkdir_p(instdir)

# Copy items
puts "Copy modules..."
dirs.each {|src|
  dst = File.join(instdir, File.basename(src))
  FileUtils.rm_rf(dst)
  FileUtils.cp_r(src, dst)
}

# Setup VSCE
puts "Setup Visual Studio Code extensions..."
home_dir = ($platform == :windows) ? ENV['USERPROFILE'] : Dir.home
vsc = File.join(home_dir, '.vscode')
FileUtils.mkdir_p(vsc)
FileUtils.cp_r(File.join(srcdir, 'extensions'), vsc)

# Create shortcut
puts "Create 'Plato IDE' shortcut..."
case $platform
when :windows
  `wscript #{File.join(srcdir, 'shortcut.vbs')} #{instdir}`
when :mac
  src = File.join(instdir, '.plato', 'plato-darwin-x64', 'plato.app')
  lnk = File.join(Dir.home, 'Applications', 'Plato\ IDE.app')
  FileUtils.mkdir_p(File.dirname(lnk))
  `ln -s #{src} #{lnk}`
end

puts $0 + ' completed.'
