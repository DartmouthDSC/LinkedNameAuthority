class WorkController < ApiController

  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :convert_to_full_fedora_id, except: :create
  before_action :convert_creator_to_fedora_id

  PARAM_TO_MODEL = {
      'bibo:doi'         => 'doi',
      'bibo:uri'         => 'canonical_uri',
      'bibo:volume'      => 'volume',
      'bibo:pages'       => 'pages',
      'bibo:pageStart'   => 'page_start',
      'bibo:pageEnd'     => 'page_end',
      'bibo:authorsList' => 'author_list',
      'dc:title'         => 'title',
      'dc:abstract'      => 'abstract',
      'dc:publisher'     => 'publisher',
      'dc:date'          => 'date',
  }.freeze

  # GET /work/:id
  def show
    @work = search_for_work(id: params[:id])
  end
  
  # POST /work
  def create
    @person = search_for_person(params['dc:creator'])
    
    attributes = { collection_id: @person['collection_id_ssi'] }
    PARAM_TO_MODEL.select { |f, _| work_params[f] }.each do |f, v|
      attributes[v] = work_params[f]
    end

    # Create work
    w = Lna::Collection::Document.create!(attributes)

    # Throw errors if not enough information
    @work = search_for_id(w.id)
    
    location = "/work/#{FedoraID.shorten(w.id)}"
    
    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json' }
    end
  end


  # PUT /work/:id
  def update
    work = search_for_works(id: params[:id])

    @person = search_for_person(params['dc:creator'])

    # update person's account
    attributes = { collection_id: @person['collection_id_ssi'] }
    PARAM_TO_MODEL.each do |f, v|
      attributes[v] = work_params[f] || ''
    end

    Lna::Collection::Document.find(params[:id]).update(attributes)
    
    # what should happen if update doesnt work

    @work = search_for_id(params[:id])
    
    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end
  end

  # DELETE /work/:id
  def destroy
    work = search_for_works(id: params[:id])

    # Delete account.
    Lna::Collection::Document.find(work['id']).destroy

    # what to do if it doesnt work?

    respond_to do |f|
      f.jsonld { render json: '{ "status": "success" }', content_type: 'application/ld+json' }
    end
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
    params.permit(PARAM_TO_MODEL.keys << 'id')
  end
end
