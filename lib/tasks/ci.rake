
# Rake task taken from Hydra-PCDM.
desc "Sets up Fedora + Solr and runs specs"
task ci: :environment do
  require 'rspec/core/rake_task'
  require 'fcrepo_wrapper'
  require 'solr_wrapper'
  
  solr_params = { version: '5.5.1', verbose: true, managed: true }
  SolrWrapper.wrap(solr_params) do |solr|
    solr.with_collection(name: 'lna_test', dir: File.join(File.expand_path('../..', File.dirname(__FILE__)), 'solr', 'config')) do
      FcrepoWrapper.wrap do
        RSpec::Core::RakeTask.new(:specs_minus_oracle) do |t|
          t.exclude_pattern = '**/models/oracle/*_spec.rb'
          t.rspec_opts = '--color'
        end
        Rake::Task['specs_minus_oracle'].invoke
      end
    end
  end
end
