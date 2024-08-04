require 'migrate_factory_rails'
require 'rails'

module MigrateFactoryRails
  class Railtie < Rails::Railtie
    railtie_name :migrate_factory

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
