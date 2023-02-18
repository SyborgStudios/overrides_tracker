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
                  begin
                    line_differerence_array << method_result_hash[:builds][build_id][:original_body].split(/\n/)
                  rescue 

                  end
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
                  begin
                    all_methods_collections.each do |build_id, all_methods_hash|
                      line_differerence_array << method_result_hash[:builds][build_id][:overriding_body].split(/\n/)
                    end
                  rescue

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

  def self.compare
    all_methods_collections = {}
    unified_methods_collections = {}
    working_directories = {}
    bundle_directories = {}
    
    all_methods_collections = {}
    unified_methods_collections = {}
    report_files = Dir.entries(DO_BASE_DIR) - [".", ".."]
    number_of_builds = 0
    
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
        number_of_builds += 1
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

    write_html_report(comparison, number_of_builds, all_methods_collections)

    comparison
  end

  def self.write_html_report(comparison, number_of_builds, all_methods_collections)
    require 'fileutils'
    source = File.join(Gem::Specification.find_by_name("overrides_tracker").gem_dir(), '/lib/html')
    target = File.join(Dir.pwd, '/overrides_tracker')
    FileUtils.copy_entry source, target

    methods_count = 0

    file_path = File.join(Dir.pwd, "/overrides_tracker/compare.html")
    html_text = nil
    begin
      File.open(file_path) do |f|
        html_text = f.read
      end
    rescue StandardError
      puts "Error processing #{file_path}"
    end

    column_size = 12/number_of_builds
    
    head = ''
    all_methods_collections.each do |file_name, methods_collection|
      head += '<div class="col-12 col-md-'+column_size.to_s+' pe-3">'
      head += '<h6 class="text-dark">' + file_name + '</h6>'
      head += '</div>'
    end

    html_text.gsub!('<!--FILENAMES-->', head)

    overrides_in_app_path_methods_hash = comparison[:results][:override_results].select{ |mh| mh[:is_part_of_app] == true  }
    overrides_outside_app_path_methods_hash = comparison[:results][:override_results].select{ |mh| mh[:is_part_of_app] == false }
    added_methods_hash = comparison[:results][:added_method_results].select{ |mh| mh[:builds].any?}

    html_text.gsub!('<!--OVERRIDES_INSIDE_CODEBASE-->', write_comparison_html(overrides_in_app_path_methods_hash, column_size))
    html_text.gsub!('<!--ADDED_METHODS_INSIDE_CODEBASE-->', write_comparison_html(added_methods_hash, column_size))
    html_text.gsub!('<!--OVERRIDES_OUTSIDE_CODEBASE-->', write_comparison_html(overrides_outside_app_path_methods_hash, column_size))

    html_text.gsub!('<!--NUMBER_OF_OVERRIDES_INSIDE-->', overrides_in_app_path_methods_hash.count.to_s)
    html_text.gsub!('<!--NUMBER_OF_ADDED_METHODS-->', added_methods_hash.count.to_s)
    html_text.gsub!('<!--NUMBER_OF_OVERRIDES_OUTSIDE-->', overrides_outside_app_path_methods_hash.count.to_s)

    File.open(file_path, 'w') do |f|
      f << html_text
    end

    puts '==========='
    puts "Find your comparison here:"
    puts "#{file_path}"
  end

  def self.write_comparison_html(methods_hash, column_size)
    puts methods_hash.first.to_s
    output=''
    if methods_hash.any?
      methods_hash.each do |method_hash|
        if method_hash[:builds].present?
          output+='<h4 class="break-all-words">'
          if method_hash[:method_type].include?('instance')
            output+= "#{method_hash[:class_name]}##{method_hash[:method_name]}"
          else
            output+= "#{method_hash[:class_name]}.#{method_hash[:method_name]}"
          end
          output+='</h4>'
          
          output+='<div class="row">'
          method_hash[:builds].each do |build_id, build_result|
            output+='<div class="col-12 col-md-'+column_size.to_s+'">'
            if build_result[:result] != 'source_has_changed'
              output+= "#{build_result[:result]}"
            end
            output+='</div>'
          end
          output+='</div>'

          output+='<div class="row">'
          method_hash[:builds].each do |build_id, build_result|
            output+='<div class="col-12 col-md-'+column_size.to_s+'">'
            unless build_result[:original_body].nil?
              output+='<h6>'
              output+= 'Original source'
              output+='</h6>'
              output+= html_code_block(build_result[:original_body], build_result[:original_location][1], build_result[:original_location][0], method_hash[:mark_lines])
            end
            output+='</div>'
          end
          output+='</div>'

          output+='<div class="row">'
          method_hash[:builds].each do |build_id, build_result|
            output+='<div class="col-12 col-md-'+column_size.to_s+'">'
            unless build_result[:overriding_body].nil?
              output+='<h6>'
              output+= 'Override'
              output+='</h6>'
              output+= html_code_block(build_result[:overriding_body], build_result[:overriding_location][1], build_result[:overriding_location][0], method_hash[:overriding_mark_lines])
            end
            output+='</div>'
          end
          output+='</div>'
          output+='<hr>'
        end
      end
    else 
      output+='<p>'
      output+= 'No differences'
      output+='</p>'
    end
    output 
  end

  def self.html_code_block(code, starting_line, location, mark_lines = nil)
    output = ''
    output += "<p class='text-break text-muted'>#{location}:#{starting_line}"
    output += '<button class="btn btn-primary btn-sm clipboard-btn ms-2" type="button" data-clipboard-action="copy" data-clipboard-text="' + location + ':' + starting_line.to_s + '">'
    output += '<i class="mdi mdi-content-copy"></i>'
    output += '</button>'
    output += '</p>'
    output += '<div id="block">'
    output += '<pre>'
    if mark_lines == nil 
      output += '<code class="codeblock javascript" style="counter-reset: line-numbering ' + (starting_line-1).to_s + ';" data-mark-lines="">'
    else
      output += '<code class="marked_block javascript" style="counter-reset: line-numbering ' + (starting_line-1).to_s + ';" data-mark-lines="' + mark_lines.to_s + '">'
    end
    output += code
    output += '</code>'
    output += '</pre>'
    output += '</div>'
    output
  end
end

