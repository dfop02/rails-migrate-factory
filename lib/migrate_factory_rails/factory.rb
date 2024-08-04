require 'migrate_factory_rails/builder'
require 'migrate_factory_rails/exceptions'
require 'migrate_factory_rails/ui'

class MigrateFactoryRails::Factory
  def initialize(migrate_content)
    @migrate_content = migrate_content
    @builder         = create_table_from_migrate_content
    @table_name      = @builder&.table_name if @builder.present?
    build_collection_methods
  end

  attr_reader :table_name

  def create_table(table_name, **options)
    @builder = MigrateFactoryRails::Builder.new(table_name, options)
    yield @builder
    @builder
  end

  def create_join_table(*table_name, **options)
    @builder = MigrateFactoryRails::Builder.new(table_name, options)
    yield @builder
    @builder
  end

  def add_column(_table_name, column_name, type, **column_options)
    @builder.send(type.to_s, *column_name, **column_options)
  end

  def remove_column(_table_name, column_name, _type = nil)
    @builder.remove_column(column_name)
  end

  def change_column_default(table_name, column_name, default)
    @builder.change_column_default(table_name, column_name, default)
  end

  def change_column_null(table_name, column_name, null)
    @builder.change_column_null(table_name, column_name, null)
  end

  def add_attachment(table_name, *column_name, **column_options)
    add_column(table_name, *column_name, :attachment, **column_options)
  end

  def remove_attachment(table_name, column_name, **_column_options)
    remove_column(table_name, column_name, :attachment)
  end

  def add_index(_table_name, column_name, **column_options)
    @builder.add_index(column_name, **column_options)
  end

  def remove_index(_table_name, column_name, **_column_options)
    @builder.remove_index(column_name)
  end

  def collect_info_from_children_migrate_content(children_content)
    collect_column(children_content)        if has_add_or_remove_column?(children_content)
    collect_index(children_content)         if has_add_or_remove_index?(children_content)
    collect_attachment(children_content)    if has_add_or_remove_attachment?(children_content)
    collect_change_column(children_content) if has_change_column?(children_content)
  end

  def rebuild_file_migration(file)
    file.write(generate_new_file)
  end

  private

  def table_name_from_migrate_content
    @migrate_content[/create_table[\s+|(]:(.*?)\)?\s+/, 1]
  end

  def create_table_from_migrate_content
    return eval(@migrate_content[/create_table(.*?)\W+end\W?$/m])      if has_create_table?(@migrate_content)
    return eval(@migrate_content[/create_join_table(.*?)\W+end\W?$/m]) if has_create_join_table?(@migrate_content)

    ''
  rescue StandardError => e
    MigrateFactoryRails::UI.print_message("\nError while rebuilding this table:\n", :red)
    puts @migrate_content[/create_table(.*?)\W+end\W?$/m].squeeze.gsub(/ end/, 'end')
    raise e
  end

  def has_create_table?(content)
    content[/create_table(.*?)\W+end\W?$/m].present?
  end

  def has_create_join_table?(content)
    content[/create_join_table(.*?)\W+end\W?$/m].present?
  end

  def build_collection_methods
    %w[column index attachment].each do |action|
      define_singleton_method("has_add_or_remove_#{action}?") do |children_content|
        children_content[/(add|remove)_#{action}\s+:#{@table_name}/].present?
      end

      define_singleton_method("collect_#{action}") do |children_content|
        block_pattern = /def\s+(change|up|self\.up)(.*?)\s+end/xm
        command_pattern = /(?:add|remove)_(?:#{action})\s+:#{@table_name}.*/

        columns_to_process = children_content.scan(block_pattern).flat_map do |_, body|
          # Clean block to collect actions:
          # Remove comment lines
          # Remove extra spaces
          # Add newline before all actions
          # Remove only the first newline
          body = body.gsub(/#\s*.*/, '').gsub(/\s+/, ' ').gsub(/((?:add|remove)_(?:\w+))/, "\n\\1").sub(/\s+\n/, '')
          body.scan(command_pattern).map do |command|
            # Define the regex pattern to match everything up to the first occurrence of a class/module name followed by '::' or '.'
            pattern = /.*?(?=[A-Z][a-zA-Z0-9_]*.?:?)/
            command = command.match(pattern).to_s if command.match(pattern)
            command.squish
          end
        end

        begin
          columns_to_process.each do |process|
            eval(process)
          end
        rescue StandardError => e
          raise MigrateFactoryException.new(@table_name, process, e.backtrace[0, 10].join("\n"))
        end
      end
    end
  end

  def has_change_column?(children_content)
    children_content[/change_column_(null|default).*/].present?
  end

  def collect_change_column(children_content)
    columns_to_process = children_content.to_enum(:scan, /change_column_(null|default)\s+:#{@table_name}.*/).map { Regexp.last_match.to_s }
    columns_to_process.each { |process| eval(process) }
  end

  def generate_new_file
    rails_version = Rails.version[/\d\.\d/]
    <<~END
    class Create#{@table_name.classify.pluralize} < ActiveRecord::Migration[#{rails_version}]
      def change
        #{@builder.print_table_type}(#{@builder.print_table_name_and_options}) do |t|
          #{@builder.print_columns}
        end
      end#{@builder.print_indexes}
    end
    END
  end
end
