namespace :lna do
  desc "Reindex all documents in Solr"
  task reindex: :environment do
    ActiveFedora::Base.reindex_everything
  end
end

namespace :lna do
  desc "Reindex, after clearing, all documents in Solr"
  task reindex_hard: :environment do
    require 'active_fedora/cleaner'
    ActiveFedora::Cleaner.cleanout_solr
    ActiveFedora::Base.reindex_everything
  end
end
