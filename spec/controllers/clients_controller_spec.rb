require 'rails_helper'

describe ClientsController, type: :controller do
  let(:client_search_service) { instance_double(ClientSearchService) }

  describe '#search' do
    it 'returns results for a keyword and default field (email)' do
      expected_return = [ { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' } ]
      allow(ClientSearchService).to receive(:new).with(anything).and_return(client_search_service)
      allow(client_search_service).to receive(:search).with('jane', anything).and_return(expected_return)

      get :search, params: { keyword: 'jane' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'results' => expected_return })
    end

    it 'returns results for a keyword and field' do
      expected_return = [ { 'id' => 1, 'full_name' => 'Jane Doe', 'email' => 'jane@example.com' } ]
      allow(ClientSearchService).to receive(:new).with(anything).and_return(client_search_service)
      allow(client_search_service).to receive(:search).with('jane', anything).and_return(expected_return)

      get :search, params: { keyword: 'jane', field: 'full_name' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'results' => expected_return })
    end

    it 'returns error message for missing keyword' do
      allow(ClientSearchService).to receive(:new).with(anything).and_return(client_search_service)
      allow(client_search_service).to receive(:search).with(nil).and_return([])

      get :search
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'error' => { 'message'=>'Missing keyword' } })
    end
  end

  describe '#duplicates' do
    it 'returns duplicate results for a given field' do
      expected_returns = [ { 'email' => 'jane.smith@yahoo.com', 'count' => 2 } ]

      allow(ClientSearchService).to receive(:new).with(anything).and_return(client_search_service)
      allow(client_search_service).to receive(:duplicates).with('email').and_return(expected_returns)

      get :duplicates, params: { field: 'email' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'duplicates' => expected_returns })
    end

    it 'returns duplicate results even if field param is missing as email is the default field to search for duplicate' do
      expected_returns = [ { 'email' => 'jane.smith@yahoo.com', 'count' => 2 } ]

      allow(ClientSearchService).to receive(:new).with(anything).and_return(client_search_service)
      allow(client_search_service).to receive(:duplicates).with(nil).and_return(expected_returns)

      get :duplicates
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'duplicates' => expected_returns })
    end

    it 'returns duplicate results for a different field search' do
      expected_returns = [ { 'full_name' => 'Jane Doe', 'count' => 2 } ]
      allow(ClientSearchService).to receive(:new).with(nil).and_return(client_search_service)
      allow(client_search_service).to receive(:duplicates).with('full_name').and_return(expected_returns)

      get :duplicates, params: { field: 'full_name' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'duplicates' => expected_returns })
    end
  end
end
