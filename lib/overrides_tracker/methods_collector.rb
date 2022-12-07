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

  def build_overrides_hash_for_method_type(clazz, class_methods, methods_type, working_directory)
    methods = []
    if methods_type == :instance_methods
      methods = clazz.instance_methods(false)
    else
      methods = clazz.singleton_methods(false)
    end

    methods.each do |method_name|
      if method_name != nil
        method_hash = class_methods[methods_type][method_name]

        if methods_type == :instance_methods
          method_to_check = clazz.instance_method(method_name)
        else
          method_to_check = clazz.singleton_method(method_name)
        end

        method_to_check_hash = OverridesTracker::Util.method_hash(method_to_check)
      
        if method_to_check_hash[:location] != nil 
          if method_hash != nil
            if method_to_check_hash[:location] != method_hash[:location]
              mark_method_as_override(methods_type, clazz.name, method_name, method_to_check, method_to_check_hash)
              puts "#{method_name} of class #{clazz.name} was overridden".green
            end
          else
            #if (method_to_check_hash[:location][0].include? working_directory)
              mark_method_as_added("added_#{methods_type}".to_sym, clazz.name, method_name, method_to_check, method_to_check_hash)
              puts "#{method_name} of class #{clazz.name} was added".green
            #end
          end
        end
      end
    end
  end

  def build_overrides_hash
    total_classes = @methods_collection.size
    count = 0
    working_directory = Dir.pwd
    @methods_collection.each do |class_name, class_methods|
      if class_name != nil
        clazz = class_name.constantize
        build_overrides_hash_for_method_type(clazz, class_methods, :instance_methods, working_directory)
        build_overrides_hash_for_method_type(clazz, class_methods, :singleton_methods, working_directory)
      end
      count = count+1
      puts "Processed #{class_name} #{count} / #{total_classes}"
    end
  end

  def overridden_methods
    @overridden_methods_collection
  end

  def load_from_file(file_name)
    file_path = File.join(Dir.pwd, "/overrides_tracker/#{file_name}")
    data = nil
    begin
      File.open(file_path) do |f|
        file_data = JSON.parse(f.read)
        data = file_data['overridden_methods'] != nil ?  file_data['overridden_methods'] : file_data
      end
    rescue
      puts "Error processing #{file_path}"
    end
    data
  end

  def save_to_file
    
    file_data = {}
    file_data[:version] = OverridesTracker::VERSION
    file_data[:branch_name] = branch_name
    file_data[:branch_name_to_report] = branch_name_to_report
    file_data[:last_commit_id] = last_commit_id
    file_data[:last_commit_name] = last_commit_name
    file_data[:last_commit_name_to_report] = last_commit_name_to_report
    file_data[:overridden_methods] = @overridden_methods_collection

    File.open(path_to_report_file, "w") do |f|
      f << file_data.to_json
    end
    puts '  '
    puts '==========='
    puts "Report saved to #{path_to_report_file}."
  end

  def report(api_token)
    OverridesTracker::Api.report_build(api_token, branch_name_to_report, last_commit_id, last_commit_name_to_report, path_to_report_file)
  end

  private

  def methods_collection(class_name)
    @methods_collection ||= {}
    @methods_collection[class_name] ||= {}
    @methods_collection[class_name][:instance_methods] ||= {}
    @methods_collection[class_name][:singleton_methods] ||= {}
    @methods_collection[class_name][:closed] ||= 'no'
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

  def branch_name_to_report
    branch = `git rev-parse --abbrev-ref HEAD`
    branch.gsub(/\s+/, "")
  end

  def last_commit_id
    commit_id = `git log --format="%H" -n 1`
    commit_id.gsub(/\s+/, "")
  end

  def last_commit_name
    commit_name = `git log --format="%s" -n 1`
    commit_name.gsub(/\s+/, "")
  end

  def last_commit_name_to_report
    commit_name = `git log --format="%s" -n 1`
  end

  def path_to_report_file
    file_name = "#{branch_name}##{last_commit_id}.otf"

    directory_name = File.join(Dir.pwd, "/overrides_tracker")
    Dir.mkdir(directory_name) unless File.exists?(directory_name)

    directory_name+"/#{file_name}"
  end
end