json.partial! 'shared/context', vocabs: [:dc, :bibo]

json.status 'success'

json.partial! 'work/work', work: @work, full: true
