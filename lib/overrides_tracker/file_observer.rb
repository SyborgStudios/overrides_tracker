module OverridesTracker::FileObserver
  def self.extended(obj)
    TracePoint.trace(:end) do |t|
      if obj == t.self
        obj.overrides_tracker_finished_file
        t.disable
      end
    end
  end
end