namespace :lna do
  desc "Reindex all documents in Solr"
  task reindex: :environment do
    ActiveFedora::Base.reindex_everything
  end
end
