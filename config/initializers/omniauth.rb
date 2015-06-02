# By default OmniAuth logging is set to STDOUT, we are overriding that
# configuration to point at the rails logger.
OmniAuth.config.logger = Rails.logger
