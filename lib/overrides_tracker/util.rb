require 'digest/sha1'

module OverridesTracker
  class Util
    class << self

      def method_hash method
          begin
              {
                  :sha => method_sha(method),
                  :location => method.source_location,
                  :body => outdented_method_body(method),
              }
          rescue
              {
                  :sha => method.hash,
                  :location => nil,
                  :body => nil,
              }
          end
      end

      def outdented_method_body method
        body = method.source
        indent = body.match(/^\W+/).to_s
        body.lines.map{|l| l.sub(indent, '')}.join
      end

      def method_sha method
        Digest::SHA1.hexdigest(method.source.gsub(/\s+/, ' '))
      end
    end
  end
end
