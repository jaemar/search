class ClientsController < ApplicationController
  def search
    path    = params[:path]
    field   = params[:field]

    begin
      keyword = params.require(:keyword)

      client_search = ClientSearchService.new(path)
      response = client_search.search(keyword, field)

      render json: { results: response }
    rescue ActionController::ParameterMissing
      render json: { error: { message: 'Missing keyword' } }
    end
  end

  def duplicates
    path    = params[:path]
    field   = params[:field]

    client_search = ClientSearchService.new(path)
    response = client_search.duplicates(field)

    render json: { duplicates: response }
  end
end
