atom_feed url: person_works_feed_url(FedoraID.shorten(@person['id'])) do |feed|
  feed.title "Works for #{@person['full_name_tesi']}"

  feed.updated @works.map{ |w| DateTime.parse(w['system_modified_dtsi']) }.max

  # Who should be listed as the author
  
  @works.each do |work|
    id = FedoraID.shorten(work['id'])
    feed.entry(work, id: work_url(id), url: work_url(id)) do |entry|
      entry.title work['title_tesi']
      entry.content 'citation'
      entry.summary work['abstract_tesi']
      entry.updated work['system_modified_dtsi']
    end
  end
end
