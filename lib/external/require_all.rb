#--
# Copyright (C)2009 Tony Arcieri
# You can redistribute this under the terms of the MIT license
# See file LICENSE for details
#++

module RequireAll
  LoadError = Class.new(::LoadError)

  # A wonderfully simple way to load your code.
  #
  # The easiest way to use require_all is to just point it at a directory
  # containing a bunch of .rb files.  These files can be nested under 
  # subdirectories as well:
  #
  #  require_all 'lib'
  #
  # This will find all the .rb files under the lib directory and load them.
  #
  # If a file required by require_all references a constant that is not yet
  # loaded, a RequireAll::LoadError will be thrown.
  #
  # You can also give it a glob, which will enumerate all the matching files: 
  #
  #  require_all 'lib/**/*.rb'
  #
  # It will also accept an array of files:
  #
  #  require_all Dir.glob("blah/**/*.rb").reject { |f| stupid_file(f) }
  # 
  # Or if you want, just list the files directly as arguments:
  #
  #  require_all 'lib/a.rb', 'lib/b.rb', 'lib/c.rb', 'lib/d.rb'
  #
  def require_all(*args)
    # Handle passing an array as an argument
    args.flatten!

    options = {method: :require}
    options.merge!(args.pop) if args.last.is_a?(Hash)

    if args.empty?
      puts "no files were loaded due to an empty Array" if $DEBUG
      return false
    end

    if args.size > 1
      # Expand files below directories
      files = args.map do |path|
        if File.directory? path
          Dir[File.join(path, '**', '*.rb')]
        else
          path
        end
      end.flatten
    else
      arg = args.first
      begin
        # Try assuming we're doing plain ol' require compat
        stat = File.stat(arg)

        if stat.file?
          files = [arg]
        elsif stat.directory?
          files = Dir.glob File.join(arg, '**', '*.rb')
        else
          raise ArgumentError, "#{arg} isn't a file or directory"
        end
      rescue SystemCallError
        # If the stat failed, maybe we have a glob!
        files = Dir.glob arg

        # Maybe it's an .rb file and the .rb was omitted
        if File.file?(arg + '.rb')
          file = arg + '.rb'
          options[:method] != :autoload ? __require(options[:method], file) : __autoload(file, file, options)
          return true
        end

        # If we ain't got no files, the glob failed
        #raise LoadError, "no such file to load -- #{arg}" if files.empty?
      end
    end

    return if files.empty?

    if options[:method] == :autoload
      files.map! { |file_| [file_, File.expand_path(file_)] }
      files.each do |file_, full_path|
        __autoload(file_, full_path, options)
      end

      return true
    end

    files.map { |file_| File.expand_path file_ }.sort.each do |file_|
      begin
        __require(options[:method], file_)
      rescue NameError => e
        # Only wrap NameError exceptions for uninitialized constants
        #raise e unless e.instance_of?(NameError) && e.message.include?('uninitialized constant')
        #raise LoadError, "Could not require #{file_} (#{e}). Please require the necessary files"
      end
    end

    true
  end

  # Works like require_all, but paths are relative to the caller rather than 
  # the current working directory
  def require_rel(*paths)
    # Handle passing an array as an argument
    paths.flatten!
    return false if paths.empty?

    source_directory = File.dirname caller.first.sub(/:\d+$/, '')
    paths.each do |path|
      require_all File.join(source_directory, path)
    end
  end

  # Loads all files like require_all instead of requiring
  def load_all(*paths)
    require_all paths, method: :load
  end

  # Loads all files by using relative paths of the caller rather than
  # the current working directory
  def load_rel(*paths)
    paths.flatten!
    return false if paths.empty?

    source_directory = File.dirname caller.first.sub(/:\d+$/, '')
    paths.each do |path|
      require_all File.join(source_directory, path), method: :load
    end
  end

  # Performs Kernel#autoload on all of the files rather than requiring immediately.
  #
  # Note that all Ruby files inside of the specified directories should have same module name as
  # the directory itself and file names should reflect the class/module names.
  # For example if there is a my_file.rb in directories dir1/dir2/ then
  # there should be a declaration like this in my_file.rb:
  #   module Dir1
  #     module Dir2
  #       class MyFile
  #         ...
  #       end
  #     end
  #  end
  #
  # If the filename and namespaces won't match then my_file.rb will be loaded into wrong module!
  # Better to fix these files.
  #
  # Set $DEBUG=true to see how files will be autoloaded if experiencing any problems.
  #
  # If trying to perform autoload on some individual file or some inner module, then you'd have
  # to always specify *:base_dir* option to specify where top-level namespace resides.
  # Otherwise it's impossible to know the namespace of the loaded files.
  #
  # For example loading only my_file.rb from dir1/dir2 with autoload_all:
  #
  #   autoload_all File.dirname(__FILE__) + '/dir1/dir2/my_file',
  #                base_dir: File.dirname(__FILE__) + '/dir1'
  #
  # WARNING: All modules will be created even if files themselves aren't loaded yet, meaning
  # that all the code which depends of the modules being loaded or not will not work, like usages
  # of define? and it's friends.
  #
  # Also, normal caveats of using Kernel#autoload apply - you have to remember that before
  # applying any monkey-patches to code using autoload, you'll have to reference the full constant
  # to load the code before applying your patch!

  def autoload_all(*paths)
    paths.flatten!
    return false if paths.empty?
    require "pathname"

    options = {method: :autoload}
    options.merge!(paths.pop) if paths.last.is_a?(Hash)

    paths.each do |path|
      require_all path, {base_dir: path}.merge(options)
    end
  end

  # Performs autoloading relatively from the caller instead of using current working directory
  def autoload_rel(*paths)
    paths.flatten!
    return false if paths.empty?
    require "pathname"

    options = {method: :autoload}
    options.merge!(paths.pop) if paths.last.is_a?(Hash)

    source_directory = File.dirname caller.first.sub(/:\d+$/, '')
    paths.each do |path|
      file_path = Pathname.new(source_directory).join(path).to_s
      require_all file_path, {method: :autoload,
                              base_dir: source_directory}.merge(options)
    end
  end

  private

  def __require(method, file)
    Kernel.send(method, file)
  end

  def __autoload(file, full_path, options)
    last_module = "Object" # default constant where namespaces are created into
    begin
      base_dir = Pathname.new(options[:base_dir]).realpath
    rescue Errno::ENOENT
      raise LoadError, ":base_dir doesn't exist at #{options[:base_dir]}"
    end
    Pathname.new(file).realpath.descend do |entry|
      # skip until *entry* is same as desired directory
      # or anything inside of it avoiding to create modules
      # from the top-level directories
      next if (entry <=> base_dir) < 0

      # get the module into which a new module is created or
      # autoload performed
      mod = Object.class_eval(last_module)

      without_ext = entry.basename(entry.extname).to_s

      const =
        if defined? ActiveSupport::Inflector
          ActiveSupport::Inflector.camelize(without_ext)
        else
          without_ext.split("_").map {|word| word.capitalize}.join
        end

      if entry.file? || (entry.directory? && entry.sub_ext('.rb').file?)
        mod.class_eval do
          puts "autoloading #{mod}::#{const} from #{full_path}" if $DEBUG
          autoload const, full_path
        end
      else
        mod.class_eval "module #{const} end" if entry.directory?
      end

      last_module += "::#{const}" if entry.directory?
    end
  end

end

include RequireAll