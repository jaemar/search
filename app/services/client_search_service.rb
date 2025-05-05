# frozen_string_literal: true

class ClientSearchService
  INDEX_NAME      = 'idx_clients'
  DEFAULT_CLIENTS = Rails.root.join('lib', 'clients.json')

  attr_accessor :client

  def initialize(clients_json_path = nil)
    @clients = load_clients(clients_json_path)

    reindex!
  end

  def reindex!
    body = @clients.map do |client_data|
      {
        index: {
          _index: INDEX_NAME,
          _id:    client_data.id,
          data:   client_data.as_indexed_json
        }
      }
    end

    client.indices.delete(index: INDEX_NAME) if client.indices.exists?(index: INDEX_NAME)
    client.indices.create(index: INDEX_NAME)
    client.bulk(body: body)
    client.indices.refresh(index: INDEX_NAME)
  end

  def search(keyword, field = nil)
    response = client.search(
      index: INDEX_NAME,
      body: {
        query: build_search_query(field.presence || 'full_name', keyword)
      }
    )

    response.dig('hits', 'hits').map { |hit| hit['_source'] }
  end

  def duplicates(field = nil)
    field = field.presence || 'email'
    response = client.search(
      index: INDEX_NAME,
      body: {
        size: 0,
        aggs: {
          duplicates: {
            terms: {
              field: "#{field}.keyword",
              min_doc_count: 2
            }
          }
        }
      }
    )

    response.dig('aggregations', 'duplicates', 'buckets').map do |bucket|
      { field => bucket['key'], 'count' => bucket['doc_count'] }
    end
  end

  private

  def client
    @client ||= Elasticsearch::Client.new
  end

  def load_clients(path)
    json_path = path.presence || DEFAULT_CLIENTS
    clients = JSON.parse(File.read(json_path), symbolized_names: true)
    clients.map { |client| Client.new(client) }
  end

  # Elastic search use different query for string and numeric value
  # for String value, use 'wildcard'
  # for Numeric value, use 'term'
  def build_search_query(field, value)
    if value.is_a?(Numeric)
      { term: { field => value } }
    else
      { wildcard: { "#{field}.keyword" => { value: "*#{value.downcase}*" } } }
    end
  end
end
