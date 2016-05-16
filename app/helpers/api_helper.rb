module ApiHelper

  # Map org ids (full fedora ids) to its corresponding uri.
  #
  # @param [Array<String>] ids list of full fedora ids
  # @return list of organization uris or empty array
  def org_ids_to_uri(ids)
    return [] if ids.nil? || ids.empty?

    ids.map do |o|
      organization_url(id: FedoraID.shorten(o))
    end
  end
end
