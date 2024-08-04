require_relative 'migrate_factory_rails/version'
require_relative 'migrate_factory_rails/factory'

module MigrateFactoryRails
  class Error < StandardError; end
  require 'migrate_factory_rails/railtie' if defined?(Rails)
end
