require "overrides_tracker/version"

# dependency for extracting method bodies and comments
require 'method_source'

require "overrides_tracker/version"
require "overrides_tracker/methods_collector"
require "overrides_tracker/file_observer"
require "overrides_tracker/string_colorizer"
require "overrides_tracker/util"
require "overrides_tracker/comparer"
require "overrides_tracker/api"


module OverridesTracker

end

# We only want to do this core ruby monkey patching when using cli
if defined? OVERRIDES_TRACKER_TRACKING_ENABLED
  Object.class_eval do
    class << self
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
        puts "Reading...#{clazz.name}"

        inst_methods = clazz.instance_methods(false)
        inst_methods.each do |inst_method|
          method = clazz.instance_method(inst_method)
          method_hash = OverridesTracker::Util.method_hash(method)
          OverridesTracker::MethodsCollector.instance.add_instance_method_for_class(clazz.name, inst_method, method_hash)
        end

        single_methods = clazz.singleton_methods(false)
        single_methods.each do |single_method|
          if single_method != :overrides_tracker_finished_file
            method = clazz.singleton_method(single_method)
            method_hash = OverridesTracker::Util.method_hash(method)
            OverridesTracker::MethodsCollector.instance.add_singleton_method_for_class(clazz.name, single_method, method_hash)
          end
        end
      end
    end
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
