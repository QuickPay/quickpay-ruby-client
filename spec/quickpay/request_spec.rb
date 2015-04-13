require 'spec_helper'

describe Quickpay::Request do
  let(:handler) { Quickpay::Request.new(secret) } 
  
  describe '.new' do
    it 'should set base uri' do
      expect(handler.class.default_options[:base_uri]).to eq(Quickpay::BASE_URI)
    end
  end
  
  describe '.request' do
    context 'when method is get' do
      it {
        stub_qp_request(:get, '/dummy', 200, { :id => 100 })
        response = handler.request(:get, '/dummy')
        expect(response['id']).to eq(100)
        expect_qp_request(:get, "/dummy", "")
      }
    end
    
    context 'when method is post/patch' do
      it {
        stub_qp_request(:post, '/dummy', 200, { :id => 100 })
        response = handler.request(:post, '/dummy', { currency: 'DKK' })
        expect(response['id']).to eq(100)
        expect_qp_request(:post, "/dummy", { currency: 'DKK' })        
      }
    end
    
    context 'when method is delete' do
      it {
        stub_qp_request(:delete, '/dummy', 200, { :id => 100 })
        response = handler.request(:delete, '/dummy', { currency: 'DKK' })
        expect(response['id']).to eq(100)
        expect_qp_request(:delete, "/dummy", "")        
      }      
    end
    
  end
  
  describe '.create_response' do
    context 'with raw' do
      it 'should return raw response' do 
        body = { "id" => 100 }
        stub_request(:get, "https://api.quickpay.net/dummy").
         to_return(:status => 200, :body => body.to_json, :headers => {})
         
        response = handler.create_response(true, handler.class.get('/dummy'))
        
        expect(response.size).to eq(3)
        expect(response[0]).to eq(200)
        expect(response[1]).to eq(body.to_json)
      end
    end
    
    context 'without raw' do
      it 'should return response' do
        body = { "id" => 100 }
        stub_request(:get, "https://api.quickpay.net/dummy").
         to_return(:status => 200, :body => body.to_json, :headers => {})
         
        response = handler.create_response(false, handler.class.get('/dummy'))
        
        expect(response).to include("id" => 100)      
      end  
    end
    
  end
  
  describe '.raise_error' do
    it 'should raise error' do
      expect{
        handler.send(:raise_error, "error", 400)
      }.to raise_error(Quickpay::BadRequest)

      expect{
        handler.send(:raise_error, "error", 401)
      }.to raise_error(Quickpay::Unauthorized)
      
    end
    
    it 'should raise general error if not recognized' do
      expect {
        handler.send(:raise_error, "error", 800)
      }.to raise_error(Quickpay::Error)      
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
  end
  
end