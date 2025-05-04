# Setup and Usage

Requirements:
- Ruby 3
- Rails 8
- Elasticsearch v8.18

Build and run app
```sh
git clone git@github.com:jaemar/search.git
cd search
bundle install
rails server
```

Localhost query
```
// Search
http://localhost:3000/query?keyword=jane
http://localhost:3000/query?keyword=jane&field=email

// Duplicates
http://localhost:3000/duplicates
http://localhost:3000/duplicates?field=full_name
```

### Client Search CLI

These are the command-line tool for searching and finding duplicate client records.

#### Search:
```sh
rake client:search KEYWORD=<keyword> FIELD=<full_name> JSON_PATH=<path-to-json-file>

samples:
// rake client:search KEY=jane
// rake client:search KEY=jane FIELD=email
// rake client:search KEY=jane FIELD=email JSON_PATH=/<root-path>/lib/clients.json
```
Arguments:
- `KEYWORD` (required): value to search
- `FIELD` (optional): field/attribute to search; default field: `full_name`
- `JSON_PATH` (optional): external json file path for `client` objects

#### Duplicate:
```sh
$ rake client:duplicates FIELD=<full_name> JSON_PATH=<path-to-json-file>

samples:
// rake client:duplicates
// rake client:duplicates FIELD=full_name
```
Arguments:
- `FIELD` (optional): field/attribute to search for duplicates; default field: `email`
- `JSON_PATH` (optional): external json file path for `client` objects

#### Assumptions and Decisions Made
- No database will be used.
- A virtual model will be used to load data from clients.json.
- keyword is required for searching.
- Virtual model Client will dynamically populate its attributes.
- Elasticsearch will be used for more refined search functionality.
- Rake tasks have been created for CLI commands: Search and Duplicate.
- Docker is used for faster setup and running of the app and Elasticsearch.

#### Known Limitations and Areas for Future Improvement
**Limitations**
- No database integration.
- Inefficient handling of large data files.
- No authentication implemented.

**Areas for Improvement**
- Add a database with indexing support.
- Use ActiveRecord models.
- Create a base class for Elasticsearch integration.
- Share the Elasticsearch base class across different search services.
- If database use is not planned:
  - Use Redis to cache the uploaded clients.json for better performance instead of reading the file each time.
- Add authentication for HTTP requests.