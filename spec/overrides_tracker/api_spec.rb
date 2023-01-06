require 'spec_helper'
require 'webmock'
require 'vcr'

describe OverridesTracker::Api do
  describe '.report_build' do
    let(:api_token) { 'abc123' }
    let(:branch_name) { 'master' }
    let(:last_commit_id) { '123456' }
    let(:last_commit_name) { 'Commit message' }
    let(:file_path) { "#{Dir.pwd}/spec/result_files/master.otf" }

    let(:uri) { URI(OverridesTracker::Api::API_DOMAIN) }
    let(:client) { double('client') }
    let(:request) { double('request') }
    let(:file) { double('file') }
    let(:response) { double('response') }
    let(:file_hash) { double('file_hash') }

    let(:form_data) do
      [['api_token', api_token],
       ['branch_name', branch_name],
       ['build_provider_id', last_commit_id],
       ['build_name', last_commit_name],
       ['result_file', file],
       ['file_hash', file_hash]
      ]
    end

    before do
      allow(OverridesTracker::Api).to receive(:build_client).and_return(client)
      allow(Net::HTTP::Post).to receive(:new).and_return(request)
      allow(request).to receive(:set_form).with(form_data, 'multipart/form-data')
      allow(client).to receive(:request).and_return(response)
      allow(response).to receive(:body).and_return('{"success": true}')
      allow(File).to receive(:open).and_return(file)
      allow(Digest::SHA256).to receive(:hexdigest).and_return(file_hash)
      allow(described_class).to receive(:disable_net_blockers!)
    end

    context 'when reference build is not found' do
      before do
        allow(OverridesTracker::Api).to receive(:find_or_report_build).with(api_token, branch_name, last_commit_id, last_commit_name, file_hash).and_return(false)
      end

      it 'sends a POST request to the API with the correct form data' do
        expect(request).to receive(:set_form).with(form_data, 'multipart/form-data')
        expect(client).to receive(:request).with(request)

        expect(OverridesTracker::Api.report_build(api_token, branch_name, last_commit_id, last_commit_name,
          file_path)).to be true
      end

      context 'when the API request fails' do
        before do
          allow(client).to receive(:request).and_raise(SocketError)
        end
  
        it 'raises an error' do
          expect(OverridesTracker::Api.report_build(api_token, branch_name, last_commit_id, last_commit_name,
                                                    file_path)).to be false
        end
      end
    end

    context 'when reference build is found' do
      before do
        allow(OverridesTracker::Api).to receive(:find_or_report_build).with(api_token, branch_name, last_commit_id, last_commit_name, file_hash).and_return(true)
      end

      it 'does not send a POST request to the API with the correct form data' do
        expect(request).to_not receive(:set_form).with(form_data, 'multipart/form-data')
        expect(client).to_not receive(:request).with(request)

        expect(OverridesTracker::Api.report_build(api_token, branch_name, last_commit_id, last_commit_name,
          file_path)).to be true
      end
    end
  end

  describe '.find_or_report_build' do
    let(:api_token) { 'abc123' }
    let(:branch_name) { 'master' }
    let(:last_commit_id) { '123456' }
    let(:last_commit_name) { 'Commit message' }
    let(:file_path) { "#{Dir.pwd}/spec/result_files/master.otf" }

    let(:uri) { URI(OverridesTracker::Api::API_DOMAIN) }
    let(:client) { double('client') }
    let(:request) { double('request') }
    let(:file) { double('file') }
    let(:response) { double('response') }
    let(:file_hash) { double('file_hash') }

    let(:form_data) do
      [['api_token', api_token],
       ['branch_name', branch_name],
       ['build_provider_id', last_commit_id],
       ['build_name', last_commit_name],
       ['file_hash', file_hash]
      ]
    end

    before do
      allow(OverridesTracker::Api).to receive(:build_client).and_return(client)
      allow(Net::HTTP::Post).to receive(:new).and_return(request)
      allow(request).to receive(:set_form).with(form_data)
      allow(client).to receive(:request).and_return(response)
      allow(response).to receive(:body).and_return('{"success": true}')
      allow(File).to receive(:open).and_return(file)
      allow(Digest::SHA256).to receive(:hexdigest).and_return(file_hash)
      allow(described_class).to receive(:disable_net_blockers!)
    end

    context 'when reference build is not found' do
      before do
        allow(response).to receive(:code).and_return('404')
      end

      it 'sends a POST request to the API with the correct form data and returns false' do
        expect(request).to receive(:set_form).with(form_data)
        expect(client).to receive(:request).with(request)

        expect(OverridesTracker::Api.find_or_report_build(api_token, branch_name, last_commit_id, last_commit_name,
          file_hash)).to be false
      end
    end

    context 'when reference build is found' do
      before do
        allow(response).to receive(:code).and_return('200')
      end

      it 'sends a POST request to the API with the correct form data and returns true' do
        expect(request).to receive(:set_form).with(form_data)
        expect(client).to receive(:request).with(request)

        expect(OverridesTracker::Api.find_or_report_build(api_token, branch_name, last_commit_id, last_commit_name,
          file_hash)).to be true
      end
    end

    context 'when the API request fails' do
      before do
        allow(client).to receive(:request).and_raise(SocketError)
      end

      it 'raises an error' do
        expect(OverridesTracker::Api.find_or_report_build(api_token, branch_name, last_commit_id, last_commit_name,
          file_hash)).to be false
      end
    end
  end

  describe '.build_client' do
    context 'when the port is 443' do
      it 'creates a new Net::HTTP object with SSL enabled' do
        uri = URI('https://example.com')
        client = OverridesTracker::Api.build_client(uri)

        expect(client).to be_a(Net::HTTP)
        expect(client.use_ssl?).to be(true)
      end
    end

    context 'when the port is not 443' do
      it 'creates a new Net::HTTP object with SSL disabled' do
        uri = URI('http://example.com')
        client = OverridesTracker::Api.build_client(uri)

        expect(client).to be_a(Net::HTTP)
        expect(client.use_ssl?).to be(false)
      end
    end
  end

  describe '#disable_net_blockers!' do
    context 'when the WebMock library is loaded' do
      it 'allows the API host' do
        # Set up a stub for the WebMock Config instance to return an array of allowed hosts
        allow(WebMock::Config.instance).to receive(:allow).and_return(OverridesTracker::Api::API_HOST)

        # Call the disable_net_blockers! method
        OverridesTracker::Api.send(:disable_net_blockers!)

        # Verify that the API host was added to the array of allowed hosts
        expect(WebMock::Config.instance.allow).to include(OverridesTracker::Api::API_HOST)
      end
    end

    context 'when the VCR library is loaded' do
      context 'when VCR version is 2 or greater' do
        let(:version) { double('version') }

        it 'ignores the API host' do
          allow(VCR).to receive(:version).and_return(version)
          allow(version).to receive(:major).and_return(2)
          # Set up a stub for the VCR configure method
          allow(VCR).to receive(:configure).and_call_original
          # Call the disable_net_blockers! method
          OverridesTracker::Api.send(:disable_net_blockers!)

          # Verify that the VCR configure method was called with the API host added to the list of ignored hosts
          expect(VCR).to have_received(:configure)
          expect(VCR.configuration.ignore_hosts.first).to eq(OverridesTracker::Api::API_HOST)
        end
      end

      context 'when VCR version is under 2' do
        let(:version) { double('version') }

        it 'ignores the API host' do
          allow(VCR).to receive(:version).and_return(version)
          allow(version).to receive(:major).and_return(1)
          # Set up a stub for the VCR configure method
          allow(VCR).to receive(:config).and_call_original
          # Call the disable_net_blockers! method
          OverridesTracker::Api.send(:disable_net_blockers!)

          # Verify that the VCR config method was called with the API host added to the list of ignored hosts
          expect(VCR).to have_received(:config)
          expect(VCR.configuration.ignore_hosts.first).to eq(OverridesTracker::Api::API_HOST)
        end
      end
    end
  end
end
