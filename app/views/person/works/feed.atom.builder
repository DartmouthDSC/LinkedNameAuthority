atom_feed do |feed|
  feed.title "Works for #{@person['full_name_tesi']}"
  feed.generator 'Dartmouth Linked Name Authority'
  feed.icon @person['image_ss']

  unless @works.empty?
    feed.updated @works.map{ |w| DateTime.parse(w['system_modified_dtsi']) }.max
  end

  cp = CiteProc::Processor.new(style: 'apa', format: 'text')

  # TODO: Map the rest of the fields.
  elements_type_to_csl_type = {
    'artefact'             => nil,
    'book'                 => :book,
    'chapter'              => :chapter,
    'composition'          => :entry,
    'conference'           => :'paper-conference',
    'dataset'              => nil,
    'design'               => nil,
    'exhibition'           => nil,
    'figure'               => :figure,
    'fileset'              => nil,
    'internet-publication' => :website,
    'journal-article'      => :'article-journal',
    'media'                => nil,
    'other'                => nil,
    'patent'               => :patent,
    'performance'          => nil,
    'poster'               => :'paper-conference',
    'presentation'         => :speech,
    'report'               => :report,
    'scholarly-edition'    => nil,
    'software'             => nil,
    'thesis-dissertations' => :thesis
  }                
  
  @works.each do |work|
    id = FedoraID.shorten(work['id'])
    
    feed.entry(work, id: work_url(id), url: (work['doi_tesi'] || work_url(id))) do |entry|

      citation_hash = {
        id: work['id'],
        type: elements_type_to_csl_type[work['doc_type_tesi']],
        title: work['title_tesi'],
        issue: work['issue_ss'],
        volume: work['volume_ss'],
        number: work['number_ss'],
        publisher: work['publisher_ss'],
        page: "#{work['page_start_ss']} - #{work['page_end_ss']}",
        :'DOI' => work['doi_tesi'], # TODO: needs help.
        author: work['author_list_tesim'].map do |a|
          last, first = a.split(', ')
          { family: last, given: first }
        end                       
      }
      citation_hash[:issued] = Date.parse(work['date_dtsi']) if work['date_dtsi']
      
      cp.import(CiteProc::Item.new(citation_hash))
      
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
