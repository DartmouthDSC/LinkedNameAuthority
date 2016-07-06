xml.feed do |feed|
  feed.title = "Works for #{@person['full_name_tesi']}"
  feed.updated DateTime.now # TODO: need to fix this

  @works.each do |work|
    feed.entry work do |entry|
      entry.title work['title_tesi']
      entry.content 'citation'
      entry.url work_url(work['id'])
    end
  end
end
