class CustomClass
  def self.call
    'custom class'
  end

  def self.singleton_test_method
    'singleton_test_method'
  end

  def instance_test_method
    'instance_test_method'
  end

  def instance_override_test_method
    'instance_override_test_method'
  end

  def instance_added_test_method
    'instance_added_test_method'
  end

  def self.singleton_added_test_method
    'singleton_added_test_method'
  end

  def self.overrides_tracker_finished_file
    @overrides_tracker_finished_file_called = true
  end
end
