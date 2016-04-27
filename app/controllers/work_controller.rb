class WorkController < CrudController
  before_action :convert_creator_to_fedora_id
  before_action :load_collection, only: [:create, :update]

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
    authorize! :create, Lna::Collection::Document
    @work = Lna::Collection::Document.create!(attributes)
    @work = search_for_id(@work.id)
    
    location = work_path(FedoraID.shorten(@work['id']))
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json' }
    end
  end


  # PUT /work/:id
  def update
    unless @work = @collection.documents.find(params[:id])
      raise ActiveFedora::ObjectNotFoundError, "work id not valid"
    end

    authorize! :update, @work
    @work.update(attributes)
    @work.save!
    
    @work = search_for_id(params[:id])
    
    super
  end

  # DELETE /work/:id
  def destroy
    @work = Lna::Collection::Document.find(params[:id])
    authorize! :destroy, @work
    @work.destroy!

    super
  end
  
  private

  def attributes
    params_to_attributes(work_params, collection_id: @collection.id)
  end

  def load_collection
    @collection = Lna::Person.find(work_params['dc:creator']).collections.first
  end
  
  def convert_creator_to_fedora_id
    if uri = params['dc:creator']
      if match = %r{^#{Regexp.escape(root_url)}person/([a-zA-Z0-9-]+$)}.match(uri)
        params['dc:creator'] = FedoraID.lengthen(match[1])
      end
    end
  end
    
  def work_params
    params.require('dc:creator')
    params.require('bibo:authorList')
    params.require('dc:title')
    params.permit('id', 'bibo:doi', 'dc:creator', 'bibo:volume', 'bibo:pages', 'bibo:pageStart',
                  'bibo:pageEnd', 'dc:title', 'dc:abstract', 'dc:publisher', 'dc:date',
                  'dc:bibliographicCitation', 'authenticity_token', 'bibo:authorList' => [],
                  'bibo:uri' => [])
  end
end
