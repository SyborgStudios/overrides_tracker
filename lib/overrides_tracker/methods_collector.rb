class OverridesTracker::MethodsCollector
  require 'active_support/core_ext/string/inflections'

  require 'json'
  @instance = new

  @methods_collection = {}
  @overridden_methods_collection = {}

  private_class_method :new

  class << self
    attr_reader :instance
  end

  def add_method_for_class(method_type, class_name, method_name, method_hash)
    methods_collection(class_name)
    @methods_collection[class_name][method_type][method_name] = method_hash
    if !@methods_collection[class_name][:is_part_of_app] && @methods_collection[class_name][method_type][method_name][:is_part_of_app]
      @methods_collection[class_name][:is_part_of_app] = true
    end
  end

  def mark_method_as_override(method_type, class_name, method_name, overriding_method, method_hash)
    overridden_methods_collection(class_name)
    @overridden_methods_collection[class_name][method_type][method_name] =
@methods_collection[class_name][method_type][method_name]
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_location] =
overriding_method.source_location
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_body] = method_hash[:body]
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_sha] = method_hash[:sha]
    if @overridden_methods_collection[class_name][method_type][method_name][:overriding_location][0].include? Dir.pwd
      @overridden_methods_collection[class_name][method_type][method_name][:overriding_is_part_of_app] = true
    else
      @overridden_methods_collection[class_name][method_type][method_name][:overriding_is_part_of_app] = false
    end
  end

  def mark_method_as_added(method_type, class_name, method_name, overriding_method, method_hash)
    overridden_methods_collection(class_name)
    @overridden_methods_collection[class_name][method_type][method_name] = method_hash
    @overridden_methods_collection[class_name][method_type][method_name][:overriding_location] =
overriding_method.source_location
    if @overridden_methods_collection[class_name][method_type][method_name][:overriding_location][0].include? Dir.pwd
      @overridden_methods_collection[class_name][method_type][method_name][:overriding_is_part_of_app] = true
    else
      @overridden_methods_collection[class_name][method_type][method_name][:overriding_is_part_of_app] = false
    end
  end

  def build_overrides_hash_for_method_type(clazz, class_methods, methods_type, working_directory)
    methods = []
    if methods_type == :instance_methods
      methods = clazz.instance_methods(false)
      clazz.ancestors.each do |ancestor|
        break if ancestor.instance_of?(Class)

        methods += ancestor.instance_methods(false)
      end
    else
      methods = clazz.singleton_methods(false)
      clazz.ancestors.each do |ancestor|
        break if ancestor.instance_of?(Class)

        methods += ancestor.singleton_methods(false)
      end
      clazz.singleton_class.ancestors.each do |ancestor|
        break if ancestor.instance_of?(Class)
        methods += ancestor.instance_methods(false)
      end
    end

    methods.each do |method_name|
      next unless !method_name.nil? && method_name != :overrides_tracker_finished_file

      method_hash = class_methods[methods_type][method_name]

      begin
        method_to_check = if methods_type == :instance_methods
                            clazz.instance_method(method_name)
                          else
                            clazz.singleton_class.instance_method(method_name) || clazz.singleton_method(method_name)
                          end

        method_to_check_hash = OverridesTracker::Util.method_hash(method_to_check)

        unless method_to_check_hash[:location].nil?
          if !method_hash.nil?
            if method_to_check_hash[:location] != method_hash[:location]
              mark_method_as_override(methods_type, clazz.name, method_name, method_to_check, method_to_check_hash)
              puts "#{method_name} of class #{clazz.name} was overridden".green
            end
          elsif method_to_check_hash[:location][0].include? working_directory
            mark_method_as_added("added_#{methods_type}".to_sym, clazz.name, method_name, method_to_check,
                                 method_to_check_hash)
            puts "#{method_name} of class #{clazz.name} was added".green
          end
        end
      rescue Exception => e
        # puts "Error processing #{method_name} of class #{clazz.name}".red
      end
    end
  end

  def build_overrides_hash
    total_classes = @methods_collection.size
    count = 0
    working_directory = Dir.pwd

    @methods_collection.each do |class_name, class_methods|
      unless class_name.nil?
        begin
          clazz = class_name.constantize
          build_overrides_hash_for_method_type(clazz, class_methods, :instance_methods, working_directory)
          build_overrides_hash_for_method_type(clazz, class_methods, :singleton_methods, working_directory)
        rescue Exception => e
          puts "Error processing #{class_name}".red
        end
      end
      count += 1
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
        data = file_data
      end
    rescue StandardError
      puts "Error processing #{file_path}"
    end
    data
  end

  def summarize_overrides
    puts ""
    puts "==========================================================================================="
    puts ""
    puts ""
    puts "SUMMARY"
    puts ""
    @overridden_methods_collection.each do |class_name, class_methods|
      class_methods[:instance_methods].each do |method_name, method_hash|
        show_override(class_name, method_name, method_hash, '#', 'overridden')
      end
      class_methods[:singleton_methods].each do |method_name, method_hash|
        show_override(class_name, method_name, method_hash, '.', 'overridden')
      end
      class_methods[:added_instance_methods].each do |method_name, method_hash|
        show_override(class_name, method_name, method_hash, '#', 'added')
      end
      class_methods[:added_singleton_methods].each do |method_name, method_hash|      
        show_override(class_name, method_name, method_hash, '.', 'added')
      end
    end
  end

  def show_override(class_name, method_name, method_hash, separator = '#', word_choice = 'overridden')
    
    puts ""
    puts "==========================================================================================="
    puts ""

    puts "#{class_name}#{separator}#{method_name} was #{word_choice}."
    unless method_hash[:body].nil?
      puts "-------------------------------------------------------------------------------------------".pink
      puts ''
      puts 'Original:'.italic
      puts ''
      puts "#{method_hash[:body]}".pink
      puts ''
      puts "in #{method_hash[:location][0]}:#{method_hash[:location][1]}".italic
    end
    puts ''
    puts ''
    unless method_hash[:overriding_body].nil?
      puts "-------------------------------------------------------------------------------------------".blue
      puts ''
      puts 'Override:'.italic
      puts ''
      puts "#{method_hash[:overriding_body]}".blue
      puts ''
      puts "in: #{method_hash[:overriding_location][0]}:#{method_hash[:overriding_location][1]}".italic
    end
  end

  def save_to_file
    file_data = {}
    file_data[:version] = OverridesTracker::VERSION
    file_data[:branch_name] = branch_name
    file_data[:author_name] = author_name
    file_data[:committer_name] = committer_name
    file_data[:branch_name_to_report] = branch_name_to_report
    file_data[:last_commit_id] = last_commit_id
    file_data[:last_commit_name] = last_commit_name
    file_data[:last_commit_name_to_report] = last_commit_name_to_report
    file_data[:working_directory] = Dir.pwd
    file_data[:bundle_path] = Bundler.bundle_path.to_s
    file_data[:methods_collection] = @overridden_methods_collection

    classes_with_overrides = @methods_collection.select do |_key, val|
      !val[:instance_methods].nil? || !val[:singleton_methods].nil?
    end
    classes_with_overrides_transformed = classes_with_overrides.map do |k, v|
      [k, v[:instance_methods], v[:singleton_methods]]
    end

    file_data[:number_of_methods] = classes_with_overrides_transformed.sum { |a| a[1].size + a[2].size }
    file_data[:number_of_methods_in_app_path] = classes_with_overrides_transformed.sum do |a|
      a[1].sum do |b|
        (b[1][:is_part_of_app] || b[1][:overriding_is_part_of_app]) ? 1 : 0 
      end + a[2].sum do |b|
        (b[1][:is_part_of_app] || b[1][:overriding_is_part_of_app]) ? 1 : 0
      end
    end

    file_data[:number_of_classes] = @methods_collection.size
    file_data[:number_of_classes_in_app_path] = @methods_collection.select { |_k, v| v[:is_part_of_app] }.size

    File.open(path_to_report_file, 'w') do |f|
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
    @methods_collection[class_name][:is_part_of_app] ||= false
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
    branch.downcase.gsub('/', '_').gsub(/\s+/, '').chomp
  end

  def branch_name_to_report
    branch = `git rev-parse --abbrev-ref HEAD`.chomp
    branch.gsub(/\s+/, '')
  end

  def last_commit_id
    commit_id = `git log --format="%H" -n 1`.chomp
    commit_id.gsub(/\s+/, '')
  end

  def last_commit_name
    commit_name = `git log --format="%s" -n 1`.chomp
    commit_name.gsub(/\s+/, '')
  end

  def last_commit_name_to_report
    commit_name = `git log --format="%s" -n 1`.chomp
    commit_name
  end

  def author_name
    author_name = `git show -s --format='%an'`.chomp
  end

  def committer_name
    committer_name = `git show -s --format='%cn'`.chomp
  end

  def path_to_report_file
    file_name = "#{branch_name}##{last_commit_id}.otf"

    directory_name = File.join(Dir.pwd, '/overrides_tracker')
    Dir.mkdir(directory_name) unless File.exist?(directory_name)

    directory_name + "/#{file_name}"
  end
end
