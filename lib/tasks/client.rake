require 'pp'

namespace :client do
  task search: :environment do |t, args|
    keyword = ENV['KEYWORD']
    field   = ENV['FIELD'].presence
    path    = ENV['JSON_PATH'].presence

    unless keyword
      pp 'Usage: rake client:search KEYWORD=foo [FIELD=field_name] [JSON_PATH=path/to/file]'
      exit 1
    end

    client = ClientSearchService.new(path)

    results = client.search(keyword, field)

    pp "Found #{results.size} result/s"
    pp results
  end

  task duplicate: :environment do |t, args|
    field   = ENV['FIELD'].presence
    path    = ENV['JSON_PATH'].presence

    client = ClientSearchService.new(path)

    results = client.duplicates(field)

    pp "Found #{results.size} result/s"
    pp results
  end
end
