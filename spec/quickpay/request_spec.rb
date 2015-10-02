require 'spec_helper'

describe QuickPay::API::Request do
  let(:req_params){{ secret: secret }}
  let(:handler) { QuickPay::API::Request.new(req_params) }

  describe '.new' do
    it 'should set base uri' do
      expect(handler.class.default_options[:base_uri]).to eq(QuickPay::BASE_URI)
    end

    context 'override base_uri' do
      let!(:req_params){ { secret: secret, base_uri: "http://test.me" }}
      it {
        expect(handler.class.default_options[:base_uri]).to eq('http://test.me')

        stub_request(:get, "http://foo:bar@test.me/dummy").
          with(:headers => headers).
          to_return(:status => 200, :body => "", :headers => {})

        handler.request(:get, '/dummy')
      }

      it {
        QuickPay.base_uri = 'http://test.me'
        expect(handler.send(:base_uri)).to eq('http://test.me')
      }
    end
  end

  describe '.request' do
    context 'when method is get' do
      it {
        stub_json_request(:get, '/dummy', 200, { :id => 100 })
        response = handler.request(:get, '/dummy')
        expect(response['id']).to eq(100)
        expect_qp_request(:get, "/dummy", "")
      }
    end

    context 'headers' do
      it 'should include extra headers in request' do
        extra_headers = { 'callback-url' => 'http://test.me/thanks' }

        stub_qp_request(:post, '/dummy', 200, "", extra_headers)
        handler.request(:post, '/dummy', :headers => extra_headers)
      end
    end

    it "should send extra options to httparty" do
      request = QuickPay::API::Request.new(secret: ":secret", verify: false)

      allow(QuickPay::API::Request).to receive(:get).and_call_original
      stub_request(:any, //)

      request.request(:get, "/ping")

      expect(QuickPay::API::Request).to have_received(:get) do |_path, options|
        expect(options[:verify]).to be false
      end
    end

    context 'when method is post/patch/put' do
      it {
        stub_json_request(:post, '/dummy', 200, { :id => 100 })
        response = handler.request(:post, '/dummy', { currency: 'DKK' })
        expect(response['id']).to eq(100)
        expect_qp_request(:post, "/dummy", { currency: 'DKK' })
      }

      it {
        stub_json_request(:put, '/dummy', 200, { :id => 100 })
        response = handler.request(:put, '/dummy', { currency: 'DKK' })
        expect(response['id']).to eq(100)
        expect_qp_request(:put, "/dummy", { currency: 'DKK' })
      }

      it {
        stub_json_request(:patch, '/dummy', 200, { :id => 100 })
        response = handler.request(:patch, '/dummy', { currency: 'DKK' })
        expect(response['id']).to eq(100)
        expect_qp_request(:patch, "/dummy", { currency: 'DKK' })
      }

      it "should send body as json" do
        stub_json_request(:patch, '/dummy', 200, { :id => 100 })
        handler.request(:patch, '/dummy', { currency: 'DKK' })

        expect(WebMock).to have_requested(:patch, /dummy/).with { |request|
          expect(JSON.parse(request.body)).to eq("currency" => "DKK")
        }
      end
    end

    context 'when method is delete' do
      it {
        stub_json_request(:delete, '/dummy?currency=DKK', 200, { :id => 100 })
        response = handler.request(:delete, '/dummy', { currency: 'DKK' })
        expect(response['id']).to eq(100)
        expect_qp_request(:delete, "/dummy?currency=DKK", "")
      }
    end

    context "when data contains a file" do
      it "should send a multipart request" do
        request = QuickPay::API::Request.new(secret: "secret")

        stub_request(:any, //)

        request.request(:put, "/brandings/1/images/cancel.png", file: File.new(__FILE__))

        expect(WebMock).to have_requested(:put, %r{/brandings/1/images/cancel\.png}).with { |request|
          expect(request.headers["Content-Type"]).to match(/^multipart\/form-data/)
        }
      end
    end
  end

  describe '.create_response' do

    context 'when raw is true' do
      it 'should return raw response', wip: true do
        body = { "id" => 100 }
        stub_request(:get, "https://api.quickpay.net/dummy").to_return(
          :status => 200,
          :body => body.to_json,
          :headers => { "Content-Type" => 'application/json'}
        )

        response = handler.create_response(true, handler.class.get('/dummy'))

        expect(response.size).to eq(3)
        expect(response[0]).to eq(200)
        expect(response[1]).to eq(body.to_json)
      end
    end

    context 'when raw is not present' do
      it 'should return http body' do
        body = { "id" => 100 }
        stub_request(:get, "https://api.quickpay.net/dummy").to_return(
          :status => 200,
          :body => body.to_json,
          :headers => {"Content-Type" => 'application/json' }
        )

        response = handler.create_response(false, handler.class.get('/dummy'))

        expect(response).to include("id" => 100)
      end
    end

    context 'when content-type is not json' do
      it 'should return raw response' do
        body = 'foobar'
        stub_request(:get, "https://api.quickpay.net/dummy").
          to_return(:status => 200, :body => 'foobar')

        response = handler.create_response(false, handler.class.get('/dummy'))

        expect(response).to eq("foobar")
      end
    end

  end

  describe '.raise_error' do
    it 'should raise error' do
      expect {
        handler.send(:raise_error, "error", 400)
      }.to raise_error(QuickPay::API::BadRequest)

      expect{
        handler.send(:raise_error, "error", 401)
      }.to raise_error(QuickPay::API::Unauthorized)

    end

    it 'should raise general error if not recognized' do
      expect {
        handler.send(:raise_error, "error", 800)
      }.to raise_error(QuickPay::API::Error)
    end

  end

  describe 'error_description' do
    it { expect(handler.send(:error_description, 'test')).to eq('test') }
  end

  describe '.authorization' do
    it { expect(handler.send(:authorization)).to eq(Base64.strict_encode64(secret)) }
  end

  describe '.headers' do
    it 'should include accept version' do
      expect(handler.send(:headers)['Accept-Version']).to eq('v10')
    end

    it 'should include user-agent and authorization' do
      expect(handler.send(:headers)['Authorization']).not_to be_nil
      expect(handler.send(:headers)['User-Agent']).not_to be_nil
    end

    it 'should have no authorization with empty secret' do
      expect(QuickPay::API::Request.new.send(:headers)['Authorization']).to be_nil
    end
  end
end
