require 'spec_helper'

describe Quickpay::Client do
  let(:secret){ 'test:test' }
  let(:client) { Quickpay::Client.new(secret) }
  
  it 'has credentials' do
    expect(client.credential).to eq(secret)  
  end

  it 'has not credentials' do
    expect(Quickpay::Client.new.credential).to be_nil
  end
  
  it 'should proxy get' do
    allow_any_instance_of(Quickpay::Request).to receive(:request).with(:get, '/dummy')
    client.get("/dummy")
  end

  it 'should proxy post' do
    allow_any_instance_of(Quickpay::Request).to receive(:request).with(:post, '/dummy', { :foo => 'bar' })
    client.post("/dummy", { foo: 'bar'})
  end

  it 'should proxy patch' do
    allow_any_instance_of(Quickpay::Request).to receive(:request).with(:patch, '/dummy', { :foo => 'bar' })
    client.patch("/dummy", { foo: 'bar'})
  end

  it 'should proxy delete' do
    allow_any_instance_of(Quickpay::Request).to receive(:request).with(:delete, '/dummy')
    client.delete("/dummy")
  end
  
  
end
  