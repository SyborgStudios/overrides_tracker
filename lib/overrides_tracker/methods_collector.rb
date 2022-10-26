class OverridesTracker::MethodsCollector
  require 'json'
  @instance = new

  @methods_collection = {}
  @overridden_methods_collection = {}

  private_class_method :new

  def self.instance
    @instance
  end

  def add_instance_method_for_class(class_name, method_name, method_hash)
    add_method_for_class(:instance_methods, class_name, method_name, method_hash)
  end

  def add_singleton_method_for_class(class_name, method_name, method_hash)
    add_method_for_class(:singleton_methods, class_name, method_name, method_hash)
  end 
  
  def add_method_for_class(method_type, class_name, method_name, method_hash)
    methods_collection(class_name)
    @methods_collection[class_name][method_type][method_name] = method_hash
  end


  def method_is_instance_override?(class_name, method_name)
    method_is_override?(:instance_methods, class_name, method_name)
  end

  def method_is_singleton_override?(class_name, method_name)
    method_is_override?(:singleton_methods, class_name, method_name)
  end

  def method_is_override?(method_type, class_name, method_name)
    methods_collection(class_name)
    @methods_collection[class_name][method_type][method_name].present?
  end

  def mark_method_as_instance_override(class_name, method_name, overriding_method, method_hash)
    mark_method_as_override(:instance_methods, class_name, method_name, overriding_method, method_hash)
  end

  def mark_method_as_singleton_override(class_name, method_name, overriding_method, method_hash)
    mark_method_as_override(:singleton_methods, class_name, method_name, overriding_method, method_hash)
  end

  def mark_method_as_override(method_type, class_name, method_name, overriding_method, method_hash)
    overridden_methods_collection(class_name)
    @overridden_methods_collection[class_name][method_type][method_name] = @methods_collection[class_name][method_type][method_name]
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_location] = overriding_method.source_location
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_body] = method_hash[:body]
  end

  def mark_method_as_added_instance(class_name, method_name, overriding_method, method_hash)
    mark_method_as_added(:added_instance_methods, class_name, method_name, overriding_method, method_hash)
  end

  def mark_method_as_added_singleton(class_name, method_name, overriding_method, method_hash)
    mark_method_as_added(:added_singleton_methods, class_name, method_name, overriding_method, method_hash)
  end

  def mark_method_as_added(method_type, class_name, method_name, overriding_method, method_hash)
    overridden_methods_collection(class_name)
    @overridden_methods_collection[class_name][method_type][method_name] =  method_hash
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_location] = overriding_method.source_location
  end


  def overridden_methods
    @overridden_methods_collection
  end

  def load_from_file(file_name)
    file_path = File.join(Dir.pwd, "/overrides_tracker/#{file_name}")
    data = nil
    begin
      File.open(file_path) do |f|
        data = JSON.parse(f.read)
      end
    rescue
      puts "Error processing #{file_path}"
    end
    data
  end

  def save_to_file
    File.open(path_to_report_file, "w") do |f|
      f << @overridden_methods_collection.to_json
    end
    puts '  '
    puts '==========='
    puts "Report saved to #{path_to_report_file}."
  end
  
  private

  def methods_collection(class_name)
    @methods_collection ||= {}
    @methods_collection[class_name] ||= {}
    @methods_collection[class_name][:instance_methods] ||= {}
    @methods_collection[class_name][:singleton_methods] ||= {}
  end

  def overridden_methods_collection(class_name)
    @overridden_methods_collection ||= {}
    @overridden_methods_collection[class_name] ||= {}
    @overridden_methods_collection[class_name][:instance_methods] ||= {}
    @overridden_methods_collection[class_name][:singleton_methods] ||= {}
    @overridden_methods_collection[class_name][:added_instance_methods] ||= {}
    @overridden_methods_collection[class_name][:added_singleton_methods] ||= {}
  end

  def branch_name
    branch = `git rev-parse --abbrev-ref HEAD`
    branch.downcase.gsub('/','_').gsub(/\s+/, "")
  end

  def last_commit_id
    commit_id = `git log --format="%H" -n 1`
    commit_id.gsub(/\s+/, "")
  end

  def last_commit_name
    commit_id = `git log --format="%s" -n 1`
    commit_id.gsub(/\s+/, "")
  end

  def path_to_report_file
    file_name = "#{branch_name}##{last_commit_id}.otf"

    directory_name = File.join(Dir.pwd, "/overrides_tracker")
    Dir.mkdir(directory_name) unless File.exists?(directory_name)

    directory_name+"/#{file_name}"
  end
end