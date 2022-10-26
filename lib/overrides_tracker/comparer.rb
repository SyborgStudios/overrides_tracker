class OverridesTracker::Comparer
  DO_BASE_DIR = File.join(Dir.pwd, "/overrides_tracker")

  def self.compare
    all_methods_collections = {}
    unified_methods_collections = {}
    report_files = Dir.entries(DO_BASE_DIR) - [".", ".."]
    report_files.each do |file_name|
      if file_name[-4..-1] == '.otf'
        all_methods_collections[file_name] = {}
        method_collection = OverridesTracker::MethodsCollector.instance.load_from_file(file_name)
        all_methods_collections[file_name] = method_collection
        unified_methods_collections = unified_methods_collections.deep_merge(method_collection)
      end
    end
    
    same_source_count = 0
    errored_source_count = 0
    method_not_available_count = 0
    method_not_override_count = 0
    source_changed_count = 0

    methods_count = 0
    classes_count = 0

    unified_methods_collections.each do |unified_class_name, unified_class_hash|

      if unified_class_hash['instance_methods'].any? || unified_class_hash['singleton_methods'].any?
        classes_count +=1
        ['instance_methods', 'singleton_methods'].each do |method_type|
          unified_class_hash[method_type].each do |unified_method_name, unified_method_hash|

            methods_count += 1
            puts ""
            puts "==========================================================================================="
            puts ""
            same_source_every_where = true
            
    
            all_methods_collections.each do |file_name, all_methods_hash|
              if all_methods_hash[unified_class_name].nil? || all_methods_hash[unified_class_name][method_type][unified_method_name].nil? || all_methods_hash[unified_class_name][method_type][unified_method_name]['sha'] != unified_method_hash['sha']
                same_source_every_where = false
              end
            end
    
            if same_source_every_where 
              puts "#{methods_count}) #{unified_class_name}##{unified_method_name}: No Changes".green.bold
              same_source_count += 1
            else
              errored_output = nil
    
              puts "#{methods_count}) #{unified_class_name}##{unified_method_name}: Changes between files".red.bold
    
              all_methods_collections.each do |file_name, all_methods_hash|
                puts ""
                puts ("in: "+file_name).bold
    
                if all_methods_hash[unified_class_name].nil? 
                  puts "#{unified_class_name}##{unified_method_name}: method is not in codebase"
                  method_not_available_count +=1
                elsif !all_methods_hash[unified_class_name][method_type][unified_method_name].nil?
                  puts "#{unified_class_name}##{unified_method_name}:"
                  puts ""
                  puts "Source:".bold
                  puts "#{all_methods_hash[unified_class_name][method_type][unified_method_name]['body']}" 
                  puts ""
                  puts "#{all_methods_hash[unified_class_name][method_type][unified_method_name]['location'][0]}:#{all_methods_hash[unified_class_name][method_type][unified_method_name]['location'][1]}".italic   

                  puts ""
                  puts "Override:".bold
                  puts "#{all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_body']}" 
                  puts ""
                  puts "#{all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_location'][0]}:#{all_methods_hash[unified_class_name][method_type][unified_method_name]['overriding_location'][1]}".italic 

                  source_changed_count  +=1  
                elsif !all_methods_hash[unified_class_name]["added_#{method_type}"][unified_method_name].nil?
                  puts "#{unified_class_name}##{unified_method_name}: method is not an override"
                  method_not_override_count  +=1

                  puts ""
                  puts "Code:".bold
                  puts "#{all_methods_hash[unified_class_name]["added_#{method_type}"][unified_method_name]['body']}" 
                  puts ""
                # puts "#{all_methods_hash[unified_class_name]["added_#{method_type}"][unified_method_name]['location'][0]}:#{all_methods_hash[unified_class_name][method_type][unified_method_name]['location'][1]}".italic 

                elsif all_methods_hash[unified_class_name]["added_#{method_type}"][unified_method_name].nil?
                  puts "#{unified_class_name}##{unified_method_name}: method is not in codebase"
                  method_not_available_count +=1                
                else
                  puts "#{unified_class_name}##{unified_method_name}: #{all_methods_hash[unified_class_name][method_type][unified_method_name]}"
                end
                puts ""
                
              end
              errored_source_count += 1
            end
          end
        end     
      end
    end

    puts ""
    puts "==========================================================================================="
    puts ""
    puts "Summary:".bold
    puts "Found #{methods_count} distinct overridden methods in #{classes_count} Files"
    puts "#{same_source_count} overridden methods have not changed"
    puts "#{errored_source_count} overridden methods have changed"
    puts "#{method_not_override_count} where method is not an override"
    puts "#{method_not_available_count} where method is not in codebase"
    source_changed_count = errored_source_count - method_not_available_count
    puts "#{source_changed_count} source method bodies have changed"
  end
end

