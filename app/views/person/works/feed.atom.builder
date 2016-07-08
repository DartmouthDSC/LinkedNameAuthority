atom_feed do |feed|
  feed.title "Works for #{@person['full_name_tesi']}"
  feed.updated @works.map{ |w| DateTime.parse(w['system_modified_dtsi']) }.max
  feed.generator 'Dartmouth Linked Name Authority'
  feed.icon @person['image_ss'] 

  cp = CiteProc::Processor.new(style: 'apa', format: 'text')
  
  @works.each do |work|
    id = FedoraID.shorten(work['id'])
    feed.entry(work, id: work_url(id), url: (work['doi_tesi'] || work_url(id))) do |entry|
      cp.import(CiteProc::Item.new(
                 id: work['id'],
                 type: :'article-journal',
                 title: work['title_tesi'],
                 issue: work['issue_ss'],
                 volume: work['volume_ss'],
                 issued: Date.parse(work['date_dtsi']),
                 number: work['number_ss'],
                 publisher: work['publisher_ss'],
                 page: "#{work['page_start_ss']} - #{work['page_end_ss']}",
                 :'DOI' => work['doi_tesi'], # TODO: needs help.
                 author: work['author_list_tesim'].map do |a|
                   last, first = a.split(', ')
                   { family: last, given: first }
                 end
               ))
      
      entry.title work['title_tesi']
      entry.content cp.render(:bibliography, id: work['id']).first
      entry.summary work['abstract_tesi']
      entry.updated DateTime.parse(work['system_modified_dtsi'])
      
      work['author_list_tesim'].each do |author|
        entry.author do |a|
          a.name(author)
        end
      end
    end
  end
end
