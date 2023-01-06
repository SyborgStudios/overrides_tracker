# frozen_string_literal: true

require 'spec_helper'
require_relative '../test_classes/custom_class'

WORKING_DIR = Dir.pwd

describe OverridesTracker::Util do
  let(:method) { CustomClass.instance_method(:instance_test_method) }

  describe '.method_hash' do
    context 'when the method is part of the app' do
      it "returns a hash with the method's name, body and sha" do
        expect(OverridesTracker::Util.method_hash(method)).to eq({ body: "def instance_test_method\n  'instance_test_method'\nend\n",
                                                                   is_part_of_app: true,
                                                                   location: [
                                                                     "#{WORKING_DIR}/spec/test_classes/custom_class.rb", 10
                                                                   ],
                                                                   sha: '3408e1f1736c6b83bc13f014e5338eec0c67393f' })
      end
    end

    context 'when the method is not part of the app' do
      before do
        allow(Dir).to receive(:pwd).and_return('another_directory')
      end

      it "returns a hash with the method's name, body and sha" do
        expect(OverridesTracker::Util.method_hash(method)[:body]).to eq("def instance_test_method\n  'instance_test_method'\nend\n")
        expect(OverridesTracker::Util.method_hash(method)[:is_part_of_app]).to eq(false)
        expect(OverridesTracker::Util.method_hash(method)[:sha]).to eq('3408e1f1736c6b83bc13f014e5338eec0c67393f')
      end
    end

    context 'when we we run into an error' do
      before do
        allow(method).to receive(:source_location).and_return('/')
      end

      it "returns a hash with the method's hash" do
        expect(OverridesTracker::Util.method_hash(method)).to eq({ body: nil, is_part_of_app: false, location: nil,
                                                                   sha: nil })
      end
    end
  end

  describe '.outdented_method_body' do
    it 'returns the body of the method without the indentation' do
      expect(OverridesTracker::Util.outdented_method_body(method)).to eq("def instance_test_method\n  'instance_test_method'\nend\n")
    end
  end

  describe '.method_sha' do
    it 'returns the sha of the method' do
      expect(OverridesTracker::Util.method_sha(method)).to eq('3408e1f1736c6b83bc13f014e5338eec0c67393f')
    end
  end
end
