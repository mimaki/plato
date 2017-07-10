#! /usr/bin/env ruby
#
# mksetup.rb - Make plato installer
#
# Usage: ruby mksetup.rb <version>
#   version:  Version number of 'Plato'
#
require 'fileutils'

EXTNAME = 'mruby-plato'
TARGET  = 'plato-setup'

if ARGV.size < 1
  puts <<EOS
Usage: ruby mksetup.rb <version>
  version: Version number of 'Plato'
EOS
  exit(0)
end
version = ARGV[0].gsub('.', '_')

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

basedir = File.dirname(File.expand_path($0))
srcdir  = File.join(basedir, TARGET)
bindir  = File.join(basedir, 'bin')

# clean up
FileUtils.rm_rf(bindir); FileUtils.mkdir_p(bindir)

MKENV_RB    = File.join(basedir, '..', 'mkenv.rb')
SHORTCUT    = File.join(basedir, '..', 'shortcut.vbs')
INSTALL_RB  = File.join(basedir, 'install.rb')

['en', 'ja'].each {|lang|
  # set paths
  src_path = File.join(File.dirname($0), TARGET)
  zip_name = "plato-#{version}-#{$platform.to_s}-#{lang}.zip"
  zip_path = File.join(bindir, zip_name)
  puts "make #{zip_name}..."

  # clean up
  FileUtils.rm_rf(srcdir); FileUtils.mkdir_p(srcdir)

  # copy setup files
  FileUtils.cp_r(SHORTCUT, srcdir) if $platform == :windows
  FileUtils.cp_r(INSTALL_RB, srcdir)

  # Make install image
  `ruby #{MKENV_RB} #{lang} #{srcdir}`

  # Copy VSCE
  vsce_dir = File.join(src_path, 'extensions')
  FileUtils.mkdir_p(vsce_dir)
  vsce_src = File.join(basedir, '..', 'tools', 'vscode-extension', EXTNAME)
  FileUtils.cp_r(vsce_src, vsce_dir)

  # Compress install image
  case $platform
  when :windows
    `wscript zip.vbs #{zip_path} #{src_path}`
  when :mac, :linux
    `zip -r #{zip_path} #{src_path}`
  end
}

puts $0 + ' completed.'
