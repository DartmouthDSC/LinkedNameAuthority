# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  include Hydra::Catalog
  # These before_filters apply the hydra access controls
  # before_filter :enforce_show_permissions, :only=>:show
  # This applies appropriate access controls to all solr queries
  # CatalogController.search_params_logic += [:add_access_controls_to_solr_params]

  before_filter :decode_id
  
  # Method to decode fedora id's that have slashes in them.
  def decode_id
    params[:id] = CGI.unescape(params[:id]) if params[:id]
  end

  configure_blacklight do |config|
    config.search_builder_class = Hydra::SearchBuilder
    config.default_solr_params = {
      :qf => 'dc_netid_tesim foaf_name_tesim foaf_given_name_tesim foaf_family_name_tesim foaf_title_tesim vcard_title_tesim vcard_org_tesim time_has_beginning_dtsim time_has_end_dtism dc_title_tesim foaf_account_name_tesim foaf_account_service_homepage_tesim',
      :qt => 'search',
      :rows => 10
    }

    # solr field configuration for search results/index views
    config.index.title_field = ['foaf_name_tesim', 'dc_title_tesim', 'vcard_title_tesim']
    config.index.display_type_field = 'active_fedora_model_ssi'


    # solr field configuration for show page
    config.show.display_type_field = 'active_fedora_model_ssi'
    
    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _tsimed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field solr_name('object_type', :facetable), :label => 'Format'
    config.add_facet_field solr_name('pub_date', :facetable), :label => 'Publication Year'
    config.add_facet_field solr_name('subject_topic', :facetable), :label => 'Topic', :limit => 20
    config.add_facet_field solr_name('language', :facetable), :label => 'Language', :limit => true
    config.add_facet_field solr_name('lc1_letter', :facetable), :label => 'Call Number'
    config.add_facet_field solr_name('subject_geo', :facetable), :label => 'Region'
    config.add_facet_field solr_name('subject_era', :facetable), :label => 'Era'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys


    # solr fields to be displayed in the index (search results) view
    # The ordering of the field names is the order of the display
    # LnaPerson
    config.add_index_field solr_name('foaf_title', :stored_searchable), label: 'Title'
    config.add_index_field solr_name('foaf_name', :stored_searchable), label: 'Name'
    # LnaAccount
    config.add_index_field solr_name('dc_title', :stored_searchable), label: 'Title'
    config.add_index_field solr_name('foaf_account_name', :stored_searchable), label: 'Account Name'
    # LnaAppointment
    config.add_index_field solr_name('vcard_title', :stored_searchable), label: 'Title'
    config.add_index_field solr_name('vcard_org', :stored_searchable), label: 'Org'
    config.add_index_field solr_name('time_has_beginning', :dateable), label: 'Begins'
    config.add_index_field solr_name('tims_has_end', :dateable), label: 'Ends'
    

    # solr fields to be displayed in the show (single result) view
    # The ordering of the field names is the order of the display
    # LnaPerson
    config.add_show_field solr_name('foaf_title', :stored_searchable), label: 'Title'
    config.add_show_field solr_name('foaf_name', :stored_searchable), label: 'Name'
    config.add_show_field solr_name('foaf_given_name', :stored_searchable), label: 'Given Name'
    config.add_show_field solr_name('foaf_family_name', :stored_searchable), label: 'Family Name'
    config.add_show_field solr_name('dc_netid', :stored_searchable), label: 'NetID'
    config.add_show_field solr_name('foaf_image', :displayable), label: 'Image'
    config.add_show_field solr_name('foaf_mbox', :displayable), label: 'MBox'
    config.add_show_field solr_name('foaf_homepage', :displayable), label: 'Homepage'
    config.add_show_field solr_name('foaf_publications', :displayable), label: 'Publications'
    config.add_show_field solr_name('foaf_workplace_homepage', :displayable), label: 'Workplace Homepage'
    # LnaAppointment
    config.add_show_field solr_name('vcard_title', :stored_searchable), label: 'Title'
    config.add_show_field solr_name('vcard_email', :stored_searchable), label: 'Email'
    config.add_show_field solr_name('vcard_org', :stored_searchable), label: 'Org'
    config.add_show_field solr_name('vcard_street_address', :displayable), label: 'Street Address'
    config.add_show_field solr_name('vcard_pobox', :displayable), label: 'P.O. Box'
    config.add_show_field solr_name('vcard_locality', :displayable), label: 'Locality'
    config.add_show_field solr_name('vcard_postal_code', :displayable), label: 'Postal Code'
    config.add_show_field solr_name('vcard_country_name', :displayable), label: 'Country'
    config.add_show_field solr_name('time_has_beginning', :dateable), label: 'Begins'
    config.add_show_field solr_name('time_has_end', :dateable), label: 'Ends'
    # Lna Account
    config.add_show_field solr_name('dc_title', :stored_searchable), label: 'Title'
    config.add_show_field solr_name('foaf_online_account', :displayable), label: 'Online Account'
    config.add_show_field solr_name('foaf_account_name', :stored_searchable), label: 'Account Name'
    config.add_show_field solr_name('foaf_account_service_homepage', :stored_searchable), label: 'Account Service Homepage'

    config.add_show_field 'isDependentOf_ssim', label: 'Belongs to'
    
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to idnentify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', :label => 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('netid') do |field|
      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$dc_netid_qf',
        :pf => '$dc_netid_pf'
      }
    end

    config.add_search_field('name') do |field|
      field.solr_local_parameters = {
        :qf => '$foaf_name_qf',
        :pf => '$foaf_name_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.qt = 'search'
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_dtsi desc, title_tesi asc', :label => 'relevance'
    config.add_sort_field 'pub_date_dtsi desc, title_tesi asc', :label => 'year'
    config.add_sort_field 'author_tesi asc, title_tesi asc', :label => 'author'
    config.add_sort_field 'title_tesi asc, pub_date_dtsi desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

end
