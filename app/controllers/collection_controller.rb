class CollectionController < ApiController
  include SolrQueryHelper
  
  skip_before_action :verify_authenticity_token, only: [:index, :search]
  before_action :default_to_first_page, only: [:index, :search]

  def default_to_first_page
    params['page'] = (params['page'].blank?) ? 1 : params['page'].to_i
  end
  
  def link_headers(total, rows, page)
    links = { first: 1, last: total.fdiv(rows).ceil }
    links[:last] = 1 if links[:last].zero?

    if page > links[:last]
      links[:prev] = links[:last]
    elsif page > 1
      links[:prev] = page - 1
    end

    links[:next] = page + 1 if page * rows < total

    links.map do |k, v|
      "<#{url_for controller: controller_name, page: v}>; rel=\"#{k}\""
    end.join(', ')
  end
end
