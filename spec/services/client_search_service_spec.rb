
require 'rails_helper'

describe ClientSearchService do
  let(:json_path) { Rails.root.join('spec', 'fixtures', 'clients.json') }
  let(:client) do
    instance_double(
      Elasticsearch::Client,
      indices: instance_double('Indices', exists?: true, delete: true, create: true, refresh: true),
      bulk: true,
      search: {}
    )
  end

  let(:clients_data) do
    [
      double('Client', id: 1, as_indexed_json: { id: 1, full_name: 'Jane Doe', email: 'jane@example.com' }),
      double('Client', id: 2, as_indexed_json: { id: 2, full_name: 'Jane Smith', email: 'jane@example.com' })
    ]
  end

  before do
    allow(JSON).to receive(:parse).and_return([
      { id: 1, full_name: 'Jane Doe', email: 'jane@example.com' },
      { id: 2, full_name: 'Jane Smith', email: 'jane@example.com' }
    ])
    allow(Client).to receive(:new).and_return(*clients_data)
    allow(Elasticsearch::Client).to receive(:new).and_return(client)
  end

  describe '#initialize' do
    it 'loads clients and calls reindex!' do
      expect_any_instance_of(ClientSearchService).to receive(:reindex!)
      service = ClientSearchService.new(json_path)
      expect(service.instance_variable_get(:@clients)).to match_array(clients_data)
    end
  end

  describe '#search' do
    context "'full_name' field search" do
      before do
        expect_any_instance_of(ClientSearchService).to receive(:search).with(anything).and_call_original
      end

      it 'returns single results' do
        search_response = {
          'hits' => {
            'hits' => [
              { '_source' => { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' } }
            ]
          }
        }
        allow(client).to receive(:search).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('doe')
        expect(result).to eq([ { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' } ])
      end

      it 'returns multiple results' do
        search_response = {
          'hits' => {
            'hits' => [
              { '_source' => { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' } },
              { '_source' => { 'id' => 1, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' } }
            ]
          }
        }
        allow(client).to receive(:search).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('jane')
        expect(result).to eq([
          { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' },
          { 'id' => 1, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' }
        ])
      end

      it 'returns empty results' do
        search_response = {
          'hits' => {
            'hits' => []
          }
        }
        allow(client).to receive(:search).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('john')
        expect(result).to eq([])
      end
    end

    context "'email' field search" do
      before do
        allow_any_instance_of(ClientSearchService).to receive(:search).with(anything, 'email').and_call_original
      end

      it 'returns single results' do
        search_response = {
          'hits' => {
            'hits' => [
              { '_source' => { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane.doe@example.com' } }
            ]
          }
        }
        allow(client).to receive(:search).with(anything).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('doe', 'email')
        expect(result).to eq([ { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane.doe@example.com' } ])
      end

      it 'returns multiple results' do
        search_response = {
          'hits' => {
            'hits' => [
              { '_source' => { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' } },
              { '_source' => { 'id' => 1, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' } }
            ]
          }
        }
        allow(client).to receive(:search).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('jane', 'email')
        expect(result).to eq([
          { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' },
          { 'id' => 1, 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' }
        ])
      end

      it 'returns empty results' do
        search_response = {
          'hits' => {
            'hits' => []
          }
        }
        allow(client).to receive(:search).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('john', 'email')
        expect(result).to eq([])
      end
    end

    context "'non_existing' field search" do
      before do
        allow_any_instance_of(ClientSearchService).to receive(:search).with(anything, 'non_existing').and_call_original
      end

      it 'returns empty results' do
        search_response = {
          'hits' => {
            'hits' => []
          }
        }
        allow(client).to receive(:search).and_return(search_response)

        service = ClientSearchService.new(json_path)
        result = service.search('john', 'non_existing')
        expect(result).to eq([])
      end
    end
  end

  describe '#duplicates' do
    context "'full_name' field" do
      it 'returns duplicates' do
        dup_response = {
          'aggregations' => {
            'duplicates' => {
              'buckets' => [
                { 'key' => 'Jane Doe', 'doc_count' => 2 }
              ]
            }
          }
        }
        allow(client).to receive(:search).and_return(dup_response)

        service = ClientSearchService.new(json_path)
        result = service.duplicates('full_name')
        expect(result).to eq([ { "full_name"=>"Jane Doe", "count"=>2 } ])
      end

      it 'returns empty' do
        dup_response = {
          'aggregations' => {
            'duplicates' => {
              'buckets' => []
            }
          }
        }
        allow(client).to receive(:search).and_return(dup_response)

        service = ClientSearchService.new(json_path)
        result = service.duplicates('full_name')
        expect(result).to eq([])
      end
    end

    context "'email' field" do
      it 'returns duplicates' do
        dup_response = {
          'aggregations' => {
            'duplicates' => {
              'buckets' => [
                { 'key' => 'jane.doe@email.com', 'doc_count' => 2 }
              ]
            }
          }
        }
        allow(client).to receive(:search).and_return(dup_response)

        service = ClientSearchService.new(json_path)
        result = service.duplicates
        expect(result).to eq([ { "email"=>"jane.doe@email.com", "count"=>2 } ])
      end

      it 'returns empty' do
        dup_response = {
          'aggregations' => {
            'duplicates' => {
              'buckets' => []
            }
          }
        }
        allow(client).to receive(:search).and_return(dup_response)

        service = ClientSearchService.new(json_path)
        result = service.duplicates
        expect(result).to eq([])
      end
    end

    context "'non_existing' field" do
      it 'returns empty' do
        dup_response = {
          'aggregations' => {
            'duplicates' => {
              'buckets' => []
            }
          }
        }
        allow(client).to receive(:search).and_return(dup_response)

        service = ClientSearchService.new(json_path)
        result = service.duplicates('non_existing')
        expect(result).to eq([])
      end
    end
  end
end
