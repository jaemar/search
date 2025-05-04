require 'rails_helper'
require 'elasticsearch'

describe Client do
  let(:attr) { { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john.doe@email.com' } }
  subject(:client) { described_class.new(attr) }

  let(:mock_client) do
    instance_double(
      Elasticsearch::Client,
      indices: instance_double(
        'Indices',
        exists?: true,
        delete: true,
        create: true,
        refresh: true
      ),
      bulk: true,
      search: {}
    )
  end
  let(:clients) do
    [
      client,
      Client.new({ id: 2, full_name: 'Jane Smith', email: 'jane@example.com' }),
      Client.new({ id: 3, full_name: 'Jane Doe', email: 'jane@example.com' })
    ]
  end
  let(:index_name) { 'idx_clients' }

  it 'returns client attribute value' do
    expect(client.full_name).to eq('John Doe')
    expect(client.email).to eq('john.doe@email.com')
  end

  it 'raises NoMethodError for unknown attr/method' do
    expect { client.test }.to raise_error(NoMethodError)
  end

  it 'returns serialized JSON' do
    expect(client.as_indexed_json).to eq(attr.stringify_keys)
  end

  it 'responds to dynamic methods' do
    expect(client).to respond_to(:email)
    expect(client).not_to respond_to(:unknown_field)
  end
end
