json.prettify!

json.partial! 'shared/context', vocabs: [:org, :dc, :prov]

json.partial! 'change_event/change_event', event: @change_event

