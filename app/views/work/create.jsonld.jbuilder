json.partial! 'shared/context', vocabs: [:dc, :bibo]

json.partial! 'shared/success'

json.partial! 'work/work', work: @work, full: true
