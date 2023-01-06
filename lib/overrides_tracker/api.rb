require 'json'
require 'net/https'
require 'digest'

class OverridesTracker::Api
  API_HOST = ENV['OVERRIDES_TRACKER_DEVELOPMENT'] ? 'localhost:3000' : 'www.overrides.io'
  API_PROTOCOL = ENV['OVERRIDES_TRACKER_DEVELOPMENT'] ? 'http' : 'https'
  API_DOMAIN = "#{API_PROTOCOL}://#{API_HOST}"

  API_BASE = "#{API_DOMAIN}/api/v1"

  def self.report_build(api_token, branch_name, last_commit_id, last_commit_name, file_path)
    disable_net_blockers!

    puts '  '
    puts '==========='
    puts 'Sending report to Overrides.io...'

    file_hash = Digest::SHA256.hexdigest(File.read(file_path))
    
    if find_or_report_build(api_token, branch_name, last_commit_id, last_commit_name, file_hash)
      puts 'Success.'.green
      true
    else  
      file = File.open(file_path)
      form_data = [['api_token', api_token], ['branch_name', branch_name], ['build_provider_id', last_commit_id],
      ['build_name', last_commit_name], ['result_file', file], ['file_hash', file_hash]]
      
      uri = URI(API_DOMAIN)
      client = build_client(uri)
      request = Net::HTTP::Post.new('/api/v1/builds')
      request.set_form form_data, 'multipart/form-data'
      
      begin
        response = client.request(request)
        puts 'Success.'.green
        true
      rescue SocketError => e
        puts 'Failed to report to the Overrides API.'.red
        false
      end
    end   
  end

  def self.find_or_report_build(api_token, branch_name, last_commit_id, last_commit_name, file_hash)
    uri = URI(API_DOMAIN)
    client = build_client(uri)    

    form_data = [['api_token', api_token], ['branch_name', branch_name], ['build_provider_id', last_commit_id],
    ['build_name', last_commit_name], ['file_hash', file_hash]]
    
    request = Net::HTTP::Post.new('/api/v1/builds/find_or_create')
    request.set_form form_data

    begin
      response = client.request(request)
      if response.code == '404'
        false
      else
        true
      end
    rescue SocketError => e
      puts 'Failed to report to the Overrides API.'.red
      false
    end
  end
  
  def self.build_client(uri)
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true if uri.port == 443
    client.verify_mode = OpenSSL::SSL::VERIFY_NONE

    client
  end

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
