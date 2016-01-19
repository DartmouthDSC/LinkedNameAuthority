json.set! '@graph' do
  json.array! @works do |work|
    json.partial! 'work/work', work: work, full: false
  end
end
