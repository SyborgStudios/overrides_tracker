class OverridesTracker::Comparer
  DO_BASE_DIR = File.join(Dir.pwd, "/overrides_tracker")

  def self.compare_builds(unified_methods_collections, all_methods_collections, working_directories, bundle_directories)
    same_source_count = 0
    errored_source_count = 0
    method_not_available_count = 0
    method_not_override_count = 0
    source_changed_count = 0
    methods_count = 0
    classes_count = 0

    results = []
    added_method_results = []

    numbers = {}
    numbers[:overrides] = {}
    numbers[:overrides][:source_changed_count] = 0
    numbers[:overrides][:override_changed_count] = 0
    numbers[:overrides][:method_not_available_count] = 0
    numbers[:overrides][:method_not_override_count] = 0
    numbers[:overrides][:total] = 0

    numbers[:added_methods] = {}
    numbers[:added_methods][:source_changed_count] = 0
    numbers[:added_methods][:override_changed_count] = 0
    numbers[:added_methods][:method_not_available_count] = 0
    numbers[:added_methods][:method_not_override_count] = 0
    numbers[:added_methods][:total] = 0
    numbers[:total] = {}

  
    unified_methods_collections.each do |unified_class_name, unified_class_hash| 
      if unified_class_hash['instance_methods']&.any? || unified_class_hash['singleton_methods']&.any?
        ['instance_methods', 'singleton_methods'].each do |method_type|
          unified_class_hash[method_type]&.each do |unified_method_name, unified_method_hash|
            same_source_every_where = true
            
            all_methods_collections.each do |build_id, all_methods_hash|
              if all_methods_hash[unified_class_name].nil? || 
                all_methods_hash[unified_class_name][method_type].nil? || 
                all_methods_hash[unified_class_name][method_type][unified_method_name].nil? || 
                all_methods_hash[unified_class_name][method_type][unified_method_name]['sha'] != unified_method_hash['sha'] || 
                all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_sha'] != unified_method_hash['overriding_sha']
                same_source_every_where = false
              end
            end
    
            method_result_hash = {class_name: unified_class_name, method_name: unified_method_name, builds: {}, method_type: method_type, changes_detected: false}
    
            if same_source_every_where 
              results << method_result_hash
            else
              method_result_hash[:changes_detected] = true
              method_result_hash[:builds] ||= {}
    
              is_source_changed_flag = false
              is_override_changed_flag = false
              all_methods_collections.each do |build_id, all_methods_hash|
                
                method_result_hash[:builds][build_id] ||= {}
                
                if all_methods_hash[unified_class_name].nil?
    
                  method_result_hash[:builds][build_id] = {result: 'method_not_available'}
                  numbers[:overrides][:method_not_available_count] +=1

                elsif all_methods_hash[unified_class_name][method_type].nil?
                  if all_methods_hash[unified_class_name]["added_#{method_type}"]
                    if all_methods_hash[unified_class_name]["added_#{method_type}"][unified_method_name]
                      method_result_hash[:builds][build_id] = {result: 'method_not_override', data: all_methods_hash[unified_class_name]["added_#{method_type}"][unified_method_name]}
                      numbers[:overrides][:method_not_override_count] +=1
                    end
                  end
                elsif !all_methods_hash[unified_class_name][method_type][unified_method_name].nil?
                  if all_methods_hash[unified_class_name][method_type][unified_method_name]['sha'] != unified_method_hash['sha']
                    method_result_hash[:builds][build_id] = {result: 'source_has_changed'}
                    method_result_hash[:builds][build_id][:original_body] = all_methods_hash[unified_class_name][method_type][unified_method_name]['body']
                    method_result_hash[:builds][build_id][:original_sha] = all_methods_hash[unified_class_name][method_type][unified_method_name]['sha']
                    method_result_hash[:builds][build_id][:original_location] = all_methods_hash[unified_class_name][method_type][unified_method_name]['location']
                    method_result_hash[:builds][build_id][:overriding_body] = all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_body']
                    method_result_hash[:builds][build_id][:overriding_location] = all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_location']
                    method_result_hash[:builds][build_id][:overriding_sha] = all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_sha']
                    method_result_hash[:builds][build_id][:is_part_of_app] = all_methods_hash[unified_class_name][method_type][unified_method_name]['is_part_of_app'] ||  all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_is_part_of_app'] 
                    mask_path(method_result_hash[:builds][build_id], working_directories[build_id], bundle_directories[build_id])

                    numbers[:overrides][:source_changed_count] += 1
                    is_source_changed_flag = true
                    is_override_changed_flag = false
                  else
                    method_result_hash[:builds][build_id] = {result: 'override_has_changed'}
                    method_result_hash[:builds][build_id][:original_body] = all_methods_hash[unified_class_name][method_type][unified_method_name]['body']
                    method_result_hash[:builds][build_id][:original_sha] = all_methods_hash[unified_class_name][method_type][unified_method_name]['sha']
                    method_result_hash[:builds][build_id][:original_location] = all_methods_hash[unified_class_name][method_type][unified_method_name]['location']
                    method_result_hash[:builds][build_id][:overriding_body] = all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_body']
                    method_result_hash[:builds][build_id][:overriding_location] = all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_location']
                    method_result_hash[:builds][build_id][:overriding_sha] = all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_sha']
                    method_result_hash[:builds][build_id][:is_part_of_app] = all_methods_hash[unified_class_name][method_type][unified_method_name]['is_part_of_app'] || all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_is_part_of_app'] 

                    mask_path(method_result_hash[:builds][build_id], working_directories[build_id], bundle_directories[build_id])

                    numbers[:overrides][:override_changed_count] += 1
                    is_override_changed_flag = true
                  end
                else   
                  method_result_hash[:builds][build_id] = {result: 'method_not_available'}
                  numbers[:overrides][:method_not_available_count] +=1                                  
                end
              end

              if is_source_changed_flag
                line_differerence_array = []
                all_methods_collections.each do |build_id, all_methods_hash|

                  line_differerence_array << method_result_hash[:builds][build_id][:original_body].split(/\n/)
                  
                  if method_result_hash[:builds][build_id][:result] == 'override_has_changed'
                    numbers[:overrides][:override_changed_count] -= 1
                    numbers[:overrides][:source_changed_count] += 1
                  end
                  method_result_hash[:builds][build_id][:result] = 'source_has_changed'
                end

                max_length = line_differerence_array.map(&:length).max
                transposed_array = line_differerence_array.map{|e| e.values_at(0...max_length)}.transpose
                method_result_hash[:mark_lines] = transposed_array.map.with_index{|val, index| val.uniq.size > 1 ? index : nil}.compact
                is_override_changed_flag = false
              end

              if is_override_changed_flag
                line_differerence_array = []
                begin

                  all_methods_collections.each do |build_id, all_methods_hash|
                    line_differerence_array << method_result_hash[:builds][build_id][:overriding_body].split(/\n/)
                  end
               
                  max_length = line_differerence_array.map(&:length).max
                  transposed_array = line_differerence_array.map{|e| e.values_at(0...max_length)}.transpose
                  method_result_hash[:overriding_mark_lines] = transposed_array.map.with_index{|val, index| val.uniq.size > 1 ? index : nil}.compact
                rescue => exception
                  
                end
              
              end

              method_result_hash[:is_part_of_app] = method_result_hash[:builds].select{|bu, bu_val| bu_val[:is_part_of_app] }.any?
              
              results << method_result_hash
            end
          end
        end
      end 
      
      
      if unified_class_hash['added_instance_methods']&.any? || unified_class_hash['added_singleton_methods']&.any?

        ['added_instance_methods', 'added_singleton_methods'].each do |method_type|
          unified_class_hash[method_type]&.each do |unified_method_name, unified_method_hash|

            same_source_every_where = true
            
            is_added_source_has_changed_flag = false

            all_methods_collections.each do |build_id, all_methods_hash|
              unless (all_methods_hash[unified_class_name] != nil) && (all_methods_hash[unified_class_name][method_type] != nil) && (all_methods_hash[unified_class_name][method_type][unified_method_name] != nil ) && (all_methods_hash[unified_class_name][method_type][unified_method_name]['sha'] == unified_method_hash['sha'])
                same_source_every_where = false
              end
            end
    
            method_result_hash = {class_name: unified_class_name, method_name: unified_method_name, builds: {}, method_type: method_type, changes_detected: false}
    
            if same_source_every_where 
              added_method_results << method_result_hash
            else
              method_result_hash[:changes_detected] = true
              method_result_hash[:builds] ||= {}
    
              all_methods_collections.each do |build_id, all_methods_hash|
                
                method_result_hash[:builds][build_id] ||= {}
    
                if all_methods_hash[unified_class_name].nil?
                  method_result_hash[:builds][build_id] = {result: 'added_method_not_available'}
                  numbers[:added_methods][:method_not_available_count] +=1
                elsif all_methods_hash[unified_class_name][method_type].nil?
                  method_result_hash[:builds][build_id] = {result: 'added_method_not_available'}
                  numbers[:added_methods][:method_not_available_count] +=1
                elsif !all_methods_hash[unified_class_name][method_type][unified_method_name].nil?
                  method_result_hash[:builds][build_id] = {result: 'added_source_has_changed'}
                  method_result_hash[:builds][build_id][:original_body] = all_methods_hash[unified_class_name][method_type][unified_method_name]['body']
                  method_result_hash[:builds][build_id][:original_location] = all_methods_hash[unified_class_name][method_type][unified_method_name]['location']
                  method_result_hash[:builds][build_id][:is_part_of_app] = all_methods_hash[unified_class_name][method_type][unified_method_name]['is_part_of_app'] ||  all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_is_part_of_app'] 

                  mask_path(method_result_hash[:builds][build_id], working_directories[build_id], bundle_directories[build_id])

                  numbers[:added_methods][:source_changed_count] += 1
                  is_added_source_has_changed_flag = true
                elsif all_methods_hash[unified_class_name][method_type][unified_method_name].nil?
                  method_result_hash[:builds][build_id] = {result: 'added_method_not_available'}
                   numbers[:added_methods][:method_not_available_count] +=1
                else
                  method_result_hash[:builds][build_id] = {result: 'error'}
                end
              end

              if is_added_source_has_changed_flag
                begin

                  line_differerence_array = []
                  all_methods_collections.each do |build_id, all_methods_hash|
                    line_differerence_array << method_result_hash[:builds][build_id][:original_body].split(/\n/)
                  end

                  max_length = line_differerence_array.map(&:length).max
                  transposed_array = line_differerence_array.map{|e| e.values_at(0...max_length)}.transpose
                  method_result_hash[:mark_added_method_lines] = transposed_array.map.with_index{|val, index| val.uniq.size > 1 ? index : nil}.compact
                rescue

                end
              end
   
              method_result_hash[:is_part_of_app] = method_result_hash[:builds].select{|bu, bu_val| bu_val[:is_part_of_app] }.any?
              added_method_results << method_result_hash

            end
          end
        end
      end   
    end
    
    numbers[:overrides][:total] = numbers[:overrides][:method_not_override_count] + numbers[:overrides][:method_not_available_count] + numbers[:overrides][:source_changed_count] + numbers[:overrides][:override_changed_count]
    numbers[:added_methods][:total] = numbers[:added_methods][:method_not_available_count] + numbers[:added_methods][:source_changed_count]
    numbers[:total] = numbers[:overrides][:total] + numbers[:added_methods][:total]

    {results: {override_results: results, added_method_results: added_method_results}, numbers: numbers}
  end

  def self.mask_path(build_hash, working_directory, bundle_directory)
    if build_hash[:original_location]
      build_hash[:original_location][0].gsub!(working_directory, 'APP_PATH')
      build_hash[:original_location][0].gsub!(bundle_directory, 'BUNDLE_PATH')
    end

    if build_hash[:overriding_location]
      build_hash[:overriding_location][0].gsub!(working_directory, 'APP_PATH')
      build_hash[:overriding_location][0].gsub!(bundle_directory, 'BUNDLE_PATH')
    end
  end

  def self.compare
    all_methods_collections = {}
    unified_methods_collections = {}
    working_directories = {}
    bundle_directories = {}
    
    all_methods_collections = {}
    unified_methods_collections = {}
    report_files = Dir.entries(DO_BASE_DIR) - [".", ".."]
    report_files.each do |file_name|
      if file_name[-4..-1] == '.otf'
        all_methods_collections[file_name] = {}
        result_file_data = OverridesTracker::MethodsCollector.instance.load_from_file(file_name)
        result_file_data.deep_stringify_keys!
        methods_collection = result_file_data['methods_collection']
        all_methods_collections[file_name] = methods_collection
        working_directories[file_name] = result_file_data['working_directory']
        bundle_directories[file_name] = result_file_data['bundle_path']
        unified_methods_collections = unified_methods_collections.deep_merge(methods_collection)
      end
    end

    comparison = compare_builds(unified_methods_collections, all_methods_collections, working_directories, bundle_directories)
    methods_count = 0

    comparison[:results].each do |result_type, result_array|
      result_array.each do |method_hash|
        if method_hash[:builds] != {}
          methods_count += 1
          puts ""
          puts "==========================================================================================="
          puts ""
          if result_type == :override_results
            puts "#{methods_count}) Override: #{method_hash[:class_name]}##{method_hash[:method_name]}".bold
          else 
            puts "#{methods_count}) Added Method: #{method_hash[:class_name]}##{method_hash[:method_name]}".bold
          end
          
          method_hash[:builds].each do |build_id, build_result|
            puts ''
            puts "..........................................................................................."
            puts ''
            puts build_id
            if build_result[:result] == 'source_has_changed'
              puts ""
            elsif build_result[:result] == 'method_not_override'
              puts "Method not override".italic.yellow
            elsif build_result[:result] == 'method_not_available'
              puts "Method not available".italic.yellow
            elsif build_result[:result] == 'added_method_not_available'
              puts "Added method not available".italic.yellow
            elsif build_result[:result] == 'added_source_has_changed'
              puts ''
            end

            
            unless build_result[:original_body].nil?
              puts "-------------------------------------------------------------------------------------------".pink
              puts ''
              puts 'Original:'.italic
              puts ''
              puts "#{build_result[:original_body]}".pink
              puts ''
              puts "in #{build_result[:original_location][0]}:#{build_result[:original_location][1]}".italic
            end
            puts ''
            puts ''
            unless build_result[:overriding_body].nil?
              puts "-------------------------------------------------------------------------------------------".blue
              puts ''
              puts 'Override:'.italic
              puts ''
              puts "#{build_result[:overriding_body]}".blue
              puts ''
              puts "in: #{build_result[:overriding_location][0]}:#{build_result[:overriding_location][1]}".italic
            end
            
            puts ''
            puts ''
          end
        end          
      end
    end


    puts ""
    puts "==========================================================================================="
    puts ""
    puts "Summary:".bold
    puts ""
    puts "Investigated methods: #{comparison[:numbers][:total]/2}"
    puts "Diffences on overrides: #{comparison[:numbers][:overrides][:total]/2}"
    puts "Diffences on added methods: #{comparison[:numbers][:added_methods][:total]/2}"

    comparison
  end

end

