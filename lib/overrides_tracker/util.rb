require 'digest/sha1'

module OverridesTracker
  class Util
    def self.method_hash(method)
      {
        sha: method_sha(method),
        location: method.source_location,
        body: outdented_method_body(method),
        is_part_of_app: method.source_location[0].include?(Dir.pwd)
      }
    rescue StandardError
      {
        sha: nil,
        location: nil,
        body: nil,
        is_part_of_app: false
      }
    end

    def self.outdented_method_body(method)
      body = method.source
      indent = body.match(/^\W+/).to_s
      body.lines.map { |l| l.sub(indent, '') }.join
    end

    def self.method_sha(method)
      Digest::SHA1.hexdigest(method.source.gsub(/\s+/, ' '))
    end
  end
end
