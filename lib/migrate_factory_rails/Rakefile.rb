require 'migrate_factory_rails'

path = File.expand_path(__dir__)
Dir.glob("#{path}/tasks/**/*.rake").each { |f| import f }
