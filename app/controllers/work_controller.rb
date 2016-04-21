class WorkController < CrudController
  before_action :convert_creator_to_fedora_id

  PARAM_TO_MODEL = {
      'bibo:doi'         => 'doi',
      'bibo:uri'         => 'canonical_uri',
      'bibo:volume'      => 'volume',
      'bibo:pages'       => 'pages',
      'bibo:pageStart'   => 'page_start',
      'bibo:pageEnd'     => 'page_end',
      'bibo:authorList'  => 'author_list',
      'dc:title'         => 'title',
      'dc:abstract'      => 'abstract',
      'dc:publisher'     => 'publisher',
      'dc:date'          => 'date',
      'dc:bibliographicCitation' => 'bibliographic_citation'
  }.freeze

  # GET /work/:id
  def show
    @work = search_for_works(id: params[:id])
    @licenses = search_for_licenses(document_id: params[:id])
    @person = search_for_persons(id: @work['creator_id_ssi'])

    super
  end
  
  # POST /work
  def create
    render_unprocessable_entity && return unless params['dc:creator']
    @person = search_for_persons(id: params['dc:creator'])

    # Create work
    attributes = params_to_attributes(work_params, collection_id: @person['collection_id_ssi'])
    w = Lna::Collection::Document.new(attributes)
    render_unprocessable_entity && return unless w.save

    @work = search_for_id(w.id)
    
    location = work_path(id: FedoraID.shorten(w.id))
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
      f.html { redirect_to location }
    end
  end


  # PUT /work/:id
  def update
    work = search_for_works(id: params[:id])

    render_unprocessable_entity && return unless params['dc:creator']
    @person = search_for_persons(id: params['dc:creator'])

    # Update work.
    attributes = params_to_attributes(work_params, put: true,
                                      collection_id: @person['collection_id_ssi'] )
    w = Lna::Collection::Document.find(params[:id])
    render_unprocessable_entity && return unless w.update(attributes)
    
    @work = search_for_id(params[:id])
    
    super
  end

  # DELETE /work/:id
  def destroy
    work = search_for_works(id: params[:id])

    # Delete account.
    w = Lna::Collection::Document.find(work['id'])
    w.destroy
    render_unprocessable_entiry && return unless w.destroyed?

    super
  end
  
  private

  def convert_creator_to_fedora_id
    if uri = params['dc:creator']
      if match = %r{^#{Regexp.escape(root_url)}person/([a-zA-Z0-9-]+$)}.match(uri)
        params['dc:creator'] = FedoraID.lengthen(match[1])
      end
    end
  end
    
  def work_params
    params.permit('id', 'dc:creator', 'bibo:doi', 'bibo:volume', 'bibo:pages', 'bibo:pageStart',
                  'bibo:pageEnd', 'dc:title', 'dc:abstract', 'dc:publisher', 'dc:date',
                  'dc:bibliographicCitation', 'authenticity_token', 'bibo:authorList' => [], 'bibo:uri' => [])
  end
end