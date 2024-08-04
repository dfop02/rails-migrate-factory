require 'migrate_factory_rails/ui'

class MigrateFactoryException < StandardError
  def initialize(table_name, process, backtrace)
    super
    @table_name = table_name
    @process = process
    @backtrace = backtrace
    log_exception
  end

  def message
    "\nOn table #{@table_name}, I do not know how deal with:\n#{@process}"
  end

  def print_msg(msg, color = nil)
    MigrateFactoryRails::UI.print_message(msg, color)
  end

  def log_exception
    print_separator

    print_msg("🚨🚨🚨 #{self.class} 🚨🚨🚨", :red)
    print_msg(message, :red)
    print_msg("\nBacktrace:\n#{@backtrace}")

    print_separator
  end

  def print_separator
    puts "\n"
    ENV['COLUMNS'].to_i.times { print '-' }
    puts "\n"
  end
end
