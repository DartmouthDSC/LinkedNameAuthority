module ApiHelper

  # Map org ids (full fedora ids) to its corresponding uri.
  #
  # @params [<Array<String>] list of full fedora ids
  # @return [<Array<String>] list of organization uris or empty array
  def org_ids_to_uri(ids)
    return [] if ids.nil? || ids.empty?

    ids.map do |o|
      organization_url(id: FedoraID.shorten(o))
    end
  end
end
