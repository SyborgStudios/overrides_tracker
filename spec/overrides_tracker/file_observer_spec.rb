# frozen_string_literal: true

require 'spec_helper'
require_relative '../test_classes/custom_class'

describe OverridesTracker::FileObserver do
  it 'calls the method overrides_tracker_finished_file when the file is finished' do
    expect(CustomClass.instance_variable_get(:@overrides_tracker_finished_file_called)).to eq(true)
  end
end
