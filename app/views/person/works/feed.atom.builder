atom_feed url: person_works_feed_url(FedoraID.shorten(@person['id'])) do |feed|
  feed.title "Works for #{@person['full_name_tesi']}"
  feed.updated DateTime.now # TODO: need to fix this

  @works.each do |work|
    id = FedoraID.shorten(work['id'])
    feed.entry(work, id: work_url(id), url: work_url(id)) do |entry|
      entry.title work['title_tesi']
      entry.content 'citation'
      entry.summary work['abstract_tesi']
    end
  end
end
