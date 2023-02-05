# frozen_string_literal: true
require 'spec_helper'
require_relative '../test_classes/custom_class'


WORKING_DIR = Dir.pwd


describe OverridesTracker::MethodsCollector do
  let(:obj) { OverridesTracker::MethodsCollector.instance }

  describe '#add_method_for_class' do
    let(:method) { CustomClass.instance_method(:instance_test_method) }

    it 'adds the method to the methods collection' do
      expect(obj.instance_variable_get(:@methods_collection)).to eq(nil)

      obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(method))

      expect(obj.instance_variable_get(:@methods_collection)).to eq({"CustomClass" => {:instance_methods=>{:instance_test_method=>{:body=>"def instance_test_method\n  'instance_test_method'\nend\n", :is_part_of_app=>true, :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 10], :sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f"}}, :is_part_of_app=>true, :singleton_methods=>{}}})
    end
  end

  describe '#mark_method_as_override' do
    let(:method) { CustomClass.instance_method(:instance_test_method) }
    let(:overriding_method) { CustomClass.instance_method(:instance_override_test_method) }
    
    before do
      obj.instance_variable_set(:@methods_collection, nil)
    end

    context 'when overriding location is in working directory' do
      it 'adds the method to the overridden methods collection' do
        expect(obj.instance_variable_get(:@methods_collection)).to eq(nil)

        obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(method))
        obj.mark_method_as_override(:instance_methods, 'CustomClass', :instance_test_method, overriding_method, OverridesTracker::Util.method_hash(overriding_method))

        expect(obj.instance_variable_get(:@methods_collection)).to eq({"CustomClass" => {:instance_methods=>{:instance_test_method=>{:body=>"def instance_test_method\n  'instance_test_method'\nend\n", :is_part_of_app=>true, :location=>["#{Dir.pwd}/spec/test_classes/custom_class.rb", 10], :overriding_body=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", :overriding_is_part_of_app=>true, :overriding_location=>["#{Dir.pwd}/spec/test_classes/custom_class.rb", 14], :overriding_sha=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290", :sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f"}}, :is_part_of_app=>true, :singleton_methods=>{}}})
        expect(obj.instance_variable_get(:@overridden_methods_collection)).to eq({"CustomClass" => {:added_instance_methods=>{}, :added_singleton_methods=>{}, :instance_methods=>{:instance_test_method=>{:body=>"def instance_test_method\n  'instance_test_method'\nend\n", :is_part_of_app=>true, :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 10], :overriding_body=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", :overriding_is_part_of_app=>true, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 14], :overriding_sha=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290", :sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f"}}, :singleton_methods=>{}}})
      end
    end

    context 'when overriding location is not in working directory' do
      let(:overriding_method) { CustomClass.instance_method(:instance_override_test_method) }
      
      before do
        @original_dir = Dir.pwd
        allow(Dir).to receive(:pwd).and_return("another_directory")
      end
      
      it 'adds the method to the overridden methods collection' do
        expect(obj.instance_variable_get(:@methods_collection)).to eq(nil)

        obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(method))
        obj.mark_method_as_override(:instance_methods, 'CustomClass', :instance_test_method, overriding_method, OverridesTracker::Util.method_hash(overriding_method))

        expect(obj.instance_variable_get(:@methods_collection)).to eq({"CustomClass" => {:instance_methods=>{:instance_test_method=>{:body=>"def instance_test_method\n  'instance_test_method'\nend\n", :is_part_of_app=>false, :location=>["#{@original_dir}/spec/test_classes/custom_class.rb", 10], :overriding_body=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", :overriding_is_part_of_app=>false, :overriding_location=>["#{@original_dir}/spec/test_classes/custom_class.rb", 14], :overriding_sha=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290", :sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f"}}, :is_part_of_app=>false, :singleton_methods=>{}}})
        expect(obj.instance_variable_get(:@overridden_methods_collection)).to eq({"CustomClass" => {:added_instance_methods=>{}, :added_singleton_methods=>{}, :instance_methods=>{:instance_test_method=>{:body=>"def instance_test_method\n  'instance_test_method'\nend\n", :is_part_of_app=>false, :location=>["#{@original_dir}/spec/test_classes/custom_class.rb", 10], :overriding_body=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", :overriding_is_part_of_app=>false, :overriding_location=>["#{@original_dir}/spec/test_classes/custom_class.rb", 14], :overriding_sha=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290", :sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f"}}, :singleton_methods=>{}}})
      end
    end
  end

  describe '#mark_method_as_added' do
    let(:method) { CustomClass.instance_method(:instance_test_method) }
    let(:overriding_method) { CustomClass.instance_method(:instance_override_test_method) }
    
    before do
      obj.instance_variable_set(:@methods_collection, nil)
      obj.instance_variable_set(:@overridden_methods_collection, nil)
    end

    context 'when overriding location is in working directory' do
      it 'adds the method to the overridden methods collection' do
        expect(obj.instance_variable_get(:@methods_collection)).to eq(nil)
        expect(obj.instance_variable_get(:@overridden_methods_collection)).to eq(nil)

        obj.mark_method_as_added(:added_instance_methods, 'CustomClass', :instance_test_method, overriding_method, OverridesTracker::Util.method_hash(overriding_method))

        expect(obj.instance_variable_get(:@overridden_methods_collection)).to eq({"CustomClass" => {:added_instance_methods=>{:instance_test_method=>{:body=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", :is_part_of_app=>true, :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 14], :overriding_is_part_of_app=>true, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 14], :sha=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290"}}, :added_singleton_methods=>{}, :instance_methods=>{}, :singleton_methods=>{}}})
      end
    end

    context 'when overriding location is not in working directory' do
      let(:overriding_method) { CustomClass.instance_method(:instance_override_test_method) }
      
      before do
        allow(Dir).to receive(:pwd).and_return("another_directory")
      end
      
      it 'adds the method to the overridden methods collection' do
        expect(obj.instance_variable_get(:@methods_collection)).to eq(nil)
        expect(obj.instance_variable_get(:@overridden_methods_collection)).to eq(nil)

        obj.mark_method_as_added(:added_instance_methods, 'CustomClass', :instance_test_method, overriding_method, OverridesTracker::Util.method_hash(overriding_method))

        expect(obj.instance_variable_get(:@overridden_methods_collection)).to eq({"CustomClass" => {:added_instance_methods=>{:instance_test_method=>{:body=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", :is_part_of_app=>false, :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 14], :overriding_is_part_of_app=>false, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 14], :sha=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290"}}, :added_singleton_methods=>{}, :instance_methods=>{}, :singleton_methods=>{}}})
      end
    end
  end

  describe '#summarize_overrides' do
    let(:instance_method) { CustomClass.instance_method(:instance_test_method) }
    let(:singleton_method) { CustomClass.singleton_method(:singleton_test_method) }
    let(:added_instance_method) { CustomClass.instance_method(:instance_added_test_method) }
    let(:added_singleton_method) { CustomClass.singleton_method(:singleton_added_test_method) }

    before do
      obj.instance_variable_set(:@methods_collection, nil)
      obj.instance_variable_set(:@overridden_methods_collection, nil)
      obj.add_method_for_class(:singleton_methods, 'CustomClass', :singleton_test_method, OverridesTracker::Util.method_hash(singleton_method))
      obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(instance_method))
      obj.mark_method_as_override(:singleton_methods, 'CustomClass', :singleton_test_method, singleton_method, OverridesTracker::Util.method_hash(singleton_method))
      obj.mark_method_as_override(:instance_methods, 'CustomClass', :instance_test_method, instance_method,  OverridesTracker::Util.method_hash(instance_method))
      obj.mark_method_as_added(:added_singleton_methods, 'CustomClass', :singleton_added_test_method, added_singleton_method, OverridesTracker::Util.method_hash(added_singleton_method))
      obj.mark_method_as_added(:added_instance_methods, 'CustomClass', :instance_added_test_method, added_instance_method, OverridesTracker::Util.method_hash(added_instance_method))
    end

    it 'calls show_override for each overridden method' do
      expect(obj).to receive(:show_override).with('CustomClass', :instance_test_method, {:sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f", :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 10], :body=>"def instance_test_method\n  'instance_test_method'\nend\n", :is_part_of_app=>true, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 10], :overriding_body=>"def instance_test_method\n  'instance_test_method'\nend\n", :overriding_sha=>"3408e1f1736c6b83bc13f014e5338eec0c67393f", :overriding_is_part_of_app=>true},'#', 'overridden').once.and_call_original
      expect(obj).to receive(:show_override).with('CustomClass', :singleton_test_method, {:sha=>"1e331d1bb802e5d0a21a6c18f574f6ceecb4bc91", :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 6], :body=>"def self.singleton_test_method\n  'singleton_test_method'\nend\n", :is_part_of_app=>true, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 6], :overriding_body=>"def self.singleton_test_method\n  'singleton_test_method'\nend\n", :overriding_sha=>"1e331d1bb802e5d0a21a6c18f574f6ceecb4bc91", :overriding_is_part_of_app=>true},'.', 'overridden').once.and_call_original
      expect(obj).to receive(:show_override).with('CustomClass', :instance_added_test_method, {:sha=>"5d7709e9d44e9f718cca1876a4fdec82bbe3cf4e", :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 18], :body=>"def instance_added_test_method\n  'instance_added_test_method'\nend\n", :is_part_of_app=>true, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 18], :overriding_is_part_of_app=>true},'#', 'added').once.and_call_original
      expect(obj).to receive(:show_override).with('CustomClass', :singleton_added_test_method, {:sha=>"ba6efb2d378551e55ee53660d25b266b3c515da3", :location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 22], :body=>"def self.singleton_added_test_method\n  'singleton_added_test_method'\nend\n", :is_part_of_app=>true, :overriding_location=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 22], :overriding_is_part_of_app=>true},'.', 'added').once.and_call_original
      
      obj.summarize_overrides
    end 
  end

  describe 'save and load_from_file' do
    let(:method) { CustomClass.instance_method(:instance_test_method) }
    let(:overriding_method) { CustomClass.instance_method(:instance_override_test_method) }
    
    let(:file_name) { "branch_name#last_commit_id.otf"}

    
    before do
      allow(obj).to receive(:branch_name).and_return('branch_name')
      allow(obj).to receive(:last_commit_id).and_return('last_commit_id')
      allow(obj).to receive(:last_commit_name).and_return('last_commit_name')
      allow(obj).to receive(:last_commit_name_to_report).and_return('last_commit_name_to_report')
      allow(obj).to receive(:author_name).and_return('author_name')
      allow(obj).to receive(:committer_name).and_return('committer_name')
      
      obj.instance_variable_set(:@methods_collection, nil)
      obj.instance_variable_set(:@overridden_methods_collection, nil)
      obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(method))
      obj.mark_method_as_override(:instance_methods, 'CustomClass', :instance_test_method, overriding_method, OverridesTracker::Util.method_hash(overriding_method))
      obj.save_to_file
    end

    it 'loads the methods collection from the file' do
      obj.instance_variable_set(:@methods_collection, nil)
      obj.instance_variable_set(:@overridden_methods_collection, nil)

      data = obj.load_from_file(file_name)

      expect(data).to eq(
        {"branch_name" => "branch_name","branch_name_to_report" => "master","bundle_path" => Bundler.bundle_path.to_s, "author_name" => "author_name", "committer_name" => "committer_name","last_commit_id" => "last_commit_id","last_commit_name" => "last_commit_name","last_commit_name_to_report" => "last_commit_name_to_report","methods_collection" => {"CustomClass"=>{"added_instance_methods"=>{}, "added_singleton_methods"=>{}, "instance_methods"=>{"instance_test_method"=>{"body"=>"def instance_test_method\n  'instance_test_method'\nend\n", "is_part_of_app"=>true, "location"=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 10], "overriding_body"=>"def instance_override_test_method\n  'instance_override_test_method'\nend\n", "overriding_is_part_of_app"=>true, "overriding_location"=>["#{WORKING_DIR}/spec/test_classes/custom_class.rb", 14], "overriding_sha"=>"75cf2b21c3033f33c155a329d8e9110ae3fb0290", "sha"=>"3408e1f1736c6b83bc13f014e5338eec0c67393f"}}, "singleton_methods"=>{}}}, "version" => "#{OverridesTracker::VERSION}", "working_directory" => Dir.pwd,"number_of_classes" => 1, "number_of_classes_in_app_path" => 1, "number_of_methods" => 1, "number_of_methods_in_app_path" => 1})        
    end

  end

  describe '#build_overrides_hash' do
    let(:method) { CustomClass.instance_method(:instance_test_method) }

    before do
      obj.instance_variable_set(:@methods_collection, nil)
      obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(method))
      @methods_collection = obj.instance_variable_get(:@methods_collection)

      allow(obj).to receive(:build_overrides_hash_for_method_type).with(CustomClass, @methods_collection["CustomClass"], :instance_methods, WORKING_DIR)
      allow(obj).to receive(:build_overrides_hash_for_method_type).with(CustomClass, @methods_collection["CustomClass"], :singleton_methods, WORKING_DIR)
    end

    it 'calls build_overrides_hash_for_method_type' do
      obj.build_overrides_hash

      expect(obj).to have_received(:build_overrides_hash_for_method_type).with(CustomClass, @methods_collection["CustomClass"], :instance_methods, WORKING_DIR)
      expect(obj).to have_received(:build_overrides_hash_for_method_type).with(CustomClass, @methods_collection["CustomClass"], :singleton_methods, WORKING_DIR)
    end
  end

  describe '#overridden_methods' do
    let(:overridden_methods_collection) { {test: 'test '} }

    before do
      obj.instance_variable_set(:@overridden_methods_collection, overridden_methods_collection)
    end
    
    it 'returns the overridden_methods_collection' do
      expect(obj.overridden_methods).to eq(overridden_methods_collection)
    end
  end

  describe '#report' do
    let(:api_token) { 'api_token' }
    let(:branch_name_to_report) { 'branch_name_to_report' }
    let(:last_commit_id) { 'last_commit_id' }
    let(:last_commit_name_to_report) { 'last_commit_name_to_report' }
    let(:path_to_report_file) { 'path_to_report_file' }

    before do
      allow(obj).to receive(:branch_name_to_report).and_return(branch_name_to_report)
      allow(obj).to receive(:last_commit_id).and_return(last_commit_id)
      allow(obj).to receive(:last_commit_name_to_report).and_return(last_commit_name_to_report)
      allow(obj).to receive(:path_to_report_file).and_return(path_to_report_file)
      allow(OverridesTracker::Api).to receive(:report_build).with(api_token, branch_name_to_report, last_commit_id, last_commit_name_to_report, path_to_report_file)
    end

    it 'call the API' do
      obj.report(api_token)

      expect(OverridesTracker::Api).to have_received(:report_build).with(api_token, branch_name_to_report, last_commit_id, last_commit_name_to_report, path_to_report_file)
    end
  end

  describe '#branch_name' do
    let(:branch_name) { `git rev-parse --abbrev-ref HEAD` } 

    it 'returns the branch name' do
      expect(obj.send(:branch_name)).to eq(branch_name.downcase.gsub('/', '_').gsub(/\s+/, ''))
    end
  end

  describe '#last_commit_id' do
    let(:last_commit_id) { `git log --format="%H" -n 1` } 

    it 'returns the last_commit_id' do
      expect(obj.send(:last_commit_id)).to eq(last_commit_id.gsub(/\s+/, ''))
    end
  end

  describe '#last_commit_name_to_report' do
    let(:last_commit_name_to_report) { `git log --format="%s" -n 1` } 

    it 'returns the last_commit_name_to_report' do
      expect(obj.send(:last_commit_name_to_report)).to eq(last_commit_name_to_report.chomp)
    end
  end

  describe '#author_name' do
    let(:author_name) { `git show -s --format='%an'`.chomp }

    it 'returns the author_name' do
      expect(obj.send(:author_name)).to eq(author_name)
    end
  end

  describe '#committer_name' do
    let(:committer_name) { `git show -s --format='%cn'`.chomp }

    it 'returns the committer_name' do
      expect(obj.send(:committer_name)).to eq(committer_name)
    end
  end

  describe '#build_overrides_hash_for_method_type' do

    context 'instance_methods' do
      let(:method) { CustomClass.instance_method(:instance_test_method) }

      before do
        obj.instance_variable_set(:@methods_collection, nil)
        obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_test_method, OverridesTracker::Util.method_hash(method))
        obj.add_method_for_class(:instance_methods, 'CustomClass', :instance_override_test_method, OverridesTracker::Util.method_hash(method))
        @methods_collection = obj.instance_variable_get(:@methods_collection)
      end

      context 'when the method is not overridden' do
        let(:method_to_check) { CustomClass.instance_method(:instance_added_test_method) }

        before do
          allow(obj).to receive(:mark_method_as_added).with(:added_instance_methods, 'CustomClass', :instance_added_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
        end

        context 'when the method is part of the app' do
          it 'calls mark_method_as_added_instance_methods' do
            obj.build_overrides_hash_for_method_type(CustomClass, @methods_collection["CustomClass"], :instance_methods, WORKING_DIR)
            expect(obj).to have_received(:mark_method_as_added).with(:added_instance_methods, 'CustomClass', :instance_added_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
          end
        end

        context 'when the method is not part of the app' do
          it 'does not call mark_method_as_added_instance_methods' do
            obj.build_overrides_hash_for_method_type(CustomClass, @methods_collection["CustomClass"], :instance_methods, '/not_working_dir')
            expect(obj).to_not have_received(:mark_method_as_added).with(:added_instance_methods, 'CustomClass', :instance_added_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
          end
        end
      end

      context 'when the method is override' do
        let(:method_to_check) { CustomClass.instance_method(:instance_override_test_method) }
        
        before do
          CustomClass.class_eval do
            def instance_override_test_method
              "instance_override_test_method_override"
            end
          end
          allow(obj).to receive(:mark_method_as_override).with(:instance_methods, 'CustomClass', :instance_override_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
        end

        it 'calls mark_method_as_added_instance_methods' do
          obj.build_overrides_hash_for_method_type(CustomClass, @methods_collection["CustomClass"], :instance_methods, WORKING_DIR)
          expect(obj).to have_received(:mark_method_as_override).with(:instance_methods, 'CustomClass', :instance_override_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
        end
      end
    end

    context 'singleton_methods' do
      let(:method) { CustomClass.singleton_method(:singleton_test_method) }

      before do
        obj.instance_variable_set(:@methods_collection, nil)
        obj.add_method_for_class(:singleton_methods, 'CustomClass', :singleton_test_method, OverridesTracker::Util.method_hash(method))
        obj.add_method_for_class(:singleton_methods, 'CustomClass', :singleton_override_test_method, OverridesTracker::Util.method_hash(method))
        @methods_collection = obj.instance_variable_get(:@methods_collection)
      end

      context 'when the method is not overridden' do
        let(:method_to_check) { CustomClass.singleton_class.instance_method(:singleton_added_test_method) }

        before do
          allow(obj).to receive(:mark_method_as_added).with(:added_singleton_methods, 'CustomClass', :singleton_added_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
        end

        context 'when the method is part of the app' do
          it 'calls mark_method_as_added_singleton_methods' do
            obj.build_overrides_hash_for_method_type(CustomClass, @methods_collection["CustomClass"], :singleton_methods, WORKING_DIR)
            
            expect(obj).to have_received(:mark_method_as_added).with(:added_singleton_methods, 'CustomClass', :singleton_added_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
          end
        end

        context 'when the method is not part of the app' do
          it 'does not call mark_method_as_added_singleton_methods' do
            obj.build_overrides_hash_for_method_type(CustomClass, @methods_collection["CustomClass"], :singleton_methods, '/not_working_dir')
            
            expect(obj).to_not have_received(:mark_method_as_added).with(:added_singleton_methods, 'CustomClass', :singleton_added_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
          end
        end
      end

      context 'when the method is override' do
        let(:method_to_check) { CustomClass.singleton_class.instance_method(:singleton_override_test_method) }
        
        before do
          CustomClass.class_eval do
            def self.singleton_override_test_method
              "singleton_override_test_method_override"
            end
          end
          allow(obj).to receive(:mark_method_as_override).with(:singleton_methods, 'CustomClass', :singleton_override_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
        end

        it 'calls mark_method_as_added_singleton_methods' do
          obj.build_overrides_hash_for_method_type(CustomClass, @methods_collection["CustomClass"], :singleton_methods, WORKING_DIR)
          
          expect(obj).to have_received(:mark_method_as_override).with(:singleton_methods, 'CustomClass', :singleton_override_test_method, method_to_check,  OverridesTracker::Util.method_hash(method_to_check) )
        end
      end
    end
  end

end