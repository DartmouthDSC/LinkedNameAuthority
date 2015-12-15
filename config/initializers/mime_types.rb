# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
Mime::Type.register "application/ld+json", :jsonld, %w( application/json )

ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::Type.lookup('application/ld+json')]=lambda { |body| JSON.parse(body) }

