require 'fcrepo_wrapper'
require 'solr_wrapper'

# Rake task taken from Hydra-PCDM.
desc "Sets up Fedora + Solr and runs specs"
task :ci do
  solr_params = { port: 8983, version: '5.3.1', verbose: true, managed: true }
  fedora_params = { port: 8080, version: '4.3.0', verbose: true, managed: true }
  SolrWrapper.wrap(solr_params) do |solr|
    solr.with_collection(name: 'lna_test', dir: File.join(File.expand_path('../..', File.dirname(__FILE__)), 'solr', 'config')) do
      FcrepoWrapper.wrap(fedora_params) do
        Rake::Task['spec'].invoke
      end
    end
  end
end

desc "Running Specs"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--tag ~oracle'
  end
end
