require 'json'
require 'net/https'

class OverridesTracker::Api

  API_HOST = false ? "localhost:3000" : "overrides.io"
  API_PROTOCOL = false ? "http" : "https"
  API_DOMAIN = "#{API_PROTOCOL}://#{API_HOST}"

  API_BASE = "#{API_DOMAIN}/api/v1"

  def self.report_build(api_token, branch_name, last_commit_id, last_commit_name, file_path)

    disable_net_blockers!

    uri = URI(API_DOMAIN)
    client  = build_client(uri)

    request  = Net::HTTP::Post.new('/api/v1/builds')
    form_data = [['api_token',api_token], ['branch_name', branch_name],['build_provider_id', last_commit_id], ['build_name', last_commit_name], ['result_file', File.open(file_path)]]
    request.set_form form_data, 'multipart/form-data'
    
    puts '  '
    puts '==========='
    puts 'Sending report to Overrides.io...'

    begin
      response = client.request(request)
      response_hash = JSON.load(response.body.to_str)
      puts 'Success.'.green
    rescue SocketError => each
      puts 'Failed to report to the Overrides API.'.red
    end
  end


  def self.build_client(uri)
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true if uri.port == 443
    client.verify_mode = OpenSSL::SSL::VERIFY_NONE


    client
  end

  private

  def self.disable_net_blockers!
    begin
      require 'webmock'

      allow = WebMock::Config.instance.allow || []
      WebMock::Config.instance.allow = [*allow].push API_HOST
    rescue LoadError
    end

    begin
      require 'vcr'

      VCR.send(VCR.version.major < 2 ? :config : :configure) do |c|
        c.ignore_hosts API_HOST
      end
    rescue LoadError
    end
  end
end
