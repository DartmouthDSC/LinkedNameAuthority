class PersonTwoController < ActionController::Base
#  include Hydra::Controller::ControllerBehavior

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ROWS = 50.freeze
  
  def index
    page = params['page'].to_i

    solr_opts = {
      rows: ROWS,
      fq: 'has_model_ssim:"Lna::Person"',
      sort: 'family_name_ssi asc, given_name_ssi asc',
    }
    solr_opts[:start] = page * ROWS if page > 1
    
    @persons = ActiveFedora::SolrService.query("*:*", solr_opts)

    graph = RDF::Graph.new
    @persons.each do |person|
      p = Lna::Person.find(person['id'])
      graph << p.resource
    end

    graph.delete(
      [nil, RDF::Vocab::Fcrepo4.createdBy, nil],
      [nil, RDF::Vocab::Fcrepo4.lastModifiedBy, nil],
      [nil, RDF::Vocab::Fcrepo4.lastModified, nil],
      [nil, RDF::Vocab::Fcrepo4.primaryType, nil],
      [nil, RDF::Vocab::Fcrepo4.created, nil],
      [nil, RDF::Vocab::Fcrepo4.exportsAs, nil],
      [nil, RDF::Vocab::Fcrepo4.hasParent, nil],
      [nil, RDF::Vocab::Fcrepo4.writable, nil],
      [nil, RDF::Vocab::Fcrepo4.mixinTypes, nil],
      [nil, RDF::URI.new('info:fedora/fedora-system:def/model#hasModel'), nil],
      [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/nt/1.0folder")],
      [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/nt/1.0hierarchyNode")],
      [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/nt/1.0base")],
      [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/mix/1.0created")],
      [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/mix/1.0lastModified")],
      [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/mix/1.0referenceable")],
      [nil, nil, RDF::Vocab::Fcrepo4.Container],
      [nil, nil, RDF::Vocab::Fcrepo4.Resource],
      [nil, nil, RDF::Vocab::LDP.Container],
      [nil, nil, RDF::Vocab::LDP.RDFSource],       
    )

    
    render :json => graph.dump(:jsonld, standard_prefixes: true)
  end

  def index_two
    page = params['page'].to_i
    
    solr_opts = {
      rows: ROWS,
      fq: 'has_model_ssim:"Lna::Person"',
      sort: 'family_name_ssi asc, given_name_ssi asc',
    }
    solr_opts[:start] = page * ROWS if page > 1
    
    @persons = ActiveFedora::SolrService.query("*:*", solr_opts)

    buffer = JSON::LD::Writer.buffer(standard_prefixes: true) do |writer|
      @persons.each do |person|
        p = Lna::Person.find(person['id'])
        writer << p.resource.delete(
                [nil, RDF::Vocab::Fcrepo4.createdBy, nil],
                [nil, RDF::Vocab::Fcrepo4.lastModifiedBy, nil],
                [nil, RDF::Vocab::Fcrepo4.lastModified, nil],
                [nil, RDF::Vocab::Fcrepo4.primaryType, nil],
                [nil, RDF::Vocab::Fcrepo4.created, nil],
                [nil, RDF::Vocab::Fcrepo4.exportsAs, nil],
                [nil, RDF::Vocab::Fcrepo4.hasParent, nil],
                [nil, RDF::Vocab::Fcrepo4.writable, nil],
                [nil, RDF::Vocab::Fcrepo4.mixinTypes, nil],
                [nil, RDF::URI.new('info:fedora/fedora-system:def/model#hasModel'), nil],
                [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/nt/1.0folder")],
                [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/nt/1.0hierarchyNode")],
                [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/nt/1.0base")],
                [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/mix/1.0created")],
                [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/mix/1.0lastModified")],
                [nil, nil, RDF::URI.new("http://www.jcp.org/jcr/mix/1.0referenceable")],
                [nil, nil, RDF::Vocab::Fcrepo4.Container],
                [nil, nil, RDF::Vocab::Fcrepo4.Resource],
                [nil, nil, RDF::Vocab::LDP.Container],
                [nil, nil, RDF::Vocab::LDP.RDFSource],
        ) 
      end
    end
    
    render :json => buffer
  end

end
