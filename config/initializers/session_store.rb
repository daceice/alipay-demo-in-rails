# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_alipay_session',
  :secret      => 'f14f3b7f63d0c79b6921751ac4dd4eb04f641fd959cdc06543336612623a3a84b4abb85a404f51410fafe10c2880be73f16c3338a386f866ae47884b3097ff0e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
