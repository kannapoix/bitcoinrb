require 'spec_helper'

describe Bitcoin::RPC::BitcoinCoreClient do

  let!(:client) { 
    # for Bitcoin::RPC::BitcoinCoreClient#initialize
    stub_request(:post, server_url).to_return(body: JSON.generate({ 'result': 'rpccommand' }))
    Bitcoin::RPC::BitcoinCoreClient.new(config)
  }
  let(:config) { {
    schema: 'http',
    host: 'localhost',
    port: 18332,
    user: 'xxx',
    password: 'yyy'
  } }
  let(:server_url) { "#{config[:schema]}://#{config[:host]}:#{config[:port]}" }

  describe '#{rpccommand}' do
    it 'should return rpc response' do
      stub_request(:post, server_url).to_return(
        body: JSON.generate({ 'result': 'RESPONSE' })
      )
      expect(client.rpccommand).to eq('RESPONSE')
    end
    
    context 'error on requesting' do
      it 'should raise error' do
        stub_request(:post, server_url).to_raise(StandardError.new('ERROR'))
        expect { client.rpccommand }.to raise_error(StandardError, 'ERROR')
      end
    end

    context 'server responded with error' do
      it 'should raise with response' do
        stub_request(:post, server_url).to_return(body: JSON.generate({ 'error': { 'code': '-1', 'message': 'RPC ERROR' } }))
        expect { client.rpccommand }.to raise_error(RuntimeError, /RPC ERROR/)
      end
    end
  end
  
  describe '#method_missing' do
    it 'should return rpc response' do
      stub_request(:post, server_url).to_return(
        body: JSON.generate({ 'result': 'RESPONSE' })
      )
      expect(client.rpc_command).to eq('RESPONSE')
    end
    
    context 'method undefined' do
      it 'should raise error' do
        expect { client.undefined_method }.to raise_error(NoMethodError)
        expect { client.undefinedmethod }.to raise_error(NoMethodError)
      end
    end
  end

end