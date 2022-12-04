require "overrides_tracker/version"

# dependency for extracting method bodies and comments
require 'method_source'

require "overrides_tracker/version"
require "overrides_tracker/methods_collector"
require "overrides_tracker/file_observer"
require "overrides_tracker/util"
require "overrides_tracker/comparer"
require "overrides_tracker/api"


module OverridesTracker

end

# We only want to do this core ruby monkey patching when using cli
if defined? OVERRIDES_TRACKER_TRACKING_ENABLED
  Object.class_eval do
    class << self

      def method_added(name)  
        begin
          if caller_locations(1)&.first&.absolute_path()&.include? Dir.pwd
            clazz = ancestors.first
            if OverridesTracker::MethodsCollector.instance.method_is_instance_override?(clazz.name, name)
              puts "Method is instance override: #{clazz.name}##{name}".green
              overriding_method = clazz.instance_method(name)
              method_hash = OverridesTracker::Util.method_hash(overriding_method)
              OverridesTracker::MethodsCollector.instance.mark_method_as_instance_override(clazz.name, name, overriding_method, method_hash)
            elsif OverridesTracker::MethodsCollector.instance.method_is_singleton_override?(clazz.name, name)
              puts "Method is singleton override: #{clazz.name}##{name}".green
              overriding_method = clazz.singleton_method(name)
              method_hash = OverridesTracker::Util.method_hash(overriding_method)
              OverridesTracker::MethodsCollector.instance.mark_method_as_singleton_override(clazz.name, name, overriding_method, method_hash)
            else   
              if clazz.singleton_methods(false).include?(name) 
                overriding_method = clazz.singleton_method(name)
                if overriding_method.present?
                  method_hash = OverridesTracker::Util.method_hash(overriding_method)
                  puts "Method is a new singleton method: #{clazz.name}##{name}".green
                  OverridesTracker::MethodsCollector.instance.mark_method_as_added_singleton(clazz.name, name, overriding_method, method_hash)
                end
              elsif clazz.instance_methods(false).include?(name) 
                overriding_method = clazz.instance_method(name)
                if overriding_method.present?
                  method_hash = OverridesTracker::Util.method_hash(overriding_method)
                  puts "Method is a new instance method: #{clazz.name}##{name}".green
                  OverridesTracker::MethodsCollector.instance.mark_method_as_added_instance(clazz.name, name, overriding_method, method_hash)
                end
              end
            end
          end
        rescue
          puts "Error: Can not process ##{name}".red
        end
    
        super
      end

      def inherited(subclass)
        subclass.class_eval do
          def self.overrides_tracker_finished_file
            clazz = ancestors.first
            save_methods_of_class(clazz)
          end
        end
        subclass.extend OverridesTracker::FileObserver
      end

      def save_methods_of_class(clazz)
        puts "Checking...#{clazz.name}"
        inst_methods = clazz.instance_methods(false)
        inst_methods.each do |inst_method|
          method = clazz.instance_method(inst_method)
          method_hash = OverridesTracker::Util.method_hash(method)
          OverridesTracker::MethodsCollector.instance.add_instance_method_for_class(clazz.name, inst_method, method_hash)
        end

        single_methods = clazz.singleton_methods(false)
        single_methods.each do |single_method|
          method = clazz.singleton_method(single_method)
          method_hash = OverridesTracker::Util.method_hash(method)
          OverridesTracker::MethodsCollector.instance.add_singleton_method_for_class(clazz.name, single_method, method_hash)
        end
      end
    end
  end
end


String.class_eval do
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
  
  def italic
    "\e[3m#{self}\e[23m" 
  end
end

#Adding deep merge functionality
Hash.class_eval do
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  def deep_merge!(other_hash, &block)
    merge!(other_hash) do |key, this_val, other_val|
      if this_val.is_a?(Hash) && other_val.is_a?(Hash)
        this_val.deep_merge(other_val, &block)
      elsif block_given?
        block.call(key, this_val, other_val)
      else
        other_val
      end
    end
  end
end
