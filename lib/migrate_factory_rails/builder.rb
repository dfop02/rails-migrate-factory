class MigrateFactoryRails::Builder
  DATABASE_TYPES = %w[
    string text binary boolean date datetime time decimal timestamp
    index float integer references has_attached_file attachment
  ].freeze

  def initialize(*table_name, **options)
    build_database_type_methods
    sanitized_table_name = sanitize_table_names(table_name)

    @join_table = sanitized_table_name.length > 1
    @table_name = @join_table ? sanitized_table_name.map(&:to_s).join('_') : sanitized_table_name.first.to_s
    @table_opt  = options
    @table      = { "#{@table_name}": {} }
  end

  attr_reader :table_name, :table

  def print_columns(space: 6)
    table_columns.map do |column_name, column_options|
      type = column_options.delete(:type)
      next if type == 'index' || type.nil?

      options = column_options.map do |ck, cv|
        next if ck == 'index'

        if type == 'string' && cv == ''
          "#{ck}: ''"
        elsif type == 'string' && ck == :default
          "#{ck}: '#{cv}'"
        elsif cv.is_a?(Symbol)
          "#{ck}: #{cv.inspect}"
        else
          "#{ck}: #{cv}"
        end
      end.compact.join(', ')

      printed_column = "t.#{type}#{valid_column_name(column_name)}"
      printed_column += ", #{options}" if options.present?
      printed_column
    end.compact.join("\n#{' ' * space}")
  end

  def print_indexes(space: 2)
    indexed_columns = table_columns.select { |_, c_opt| c_opt[:type] == 'index' || c_opt[:index] }
    return '' if indexed_columns.empty?

    spaces = ' ' * space
    indexed_columns.map do |column_name, _|
      "add_index :#{table_name},#{valid_column_name(column_name)}"
    end.join("\n#{spaces}").insert(0, "\n\n#{spaces}")
  end

  def print_table_name_and_options
    return print_table_name if @table_opt.blank?

    "#{print_table_name}, #{@table_opt.map { |key, value| print_options_key_value(key, value) }.join(', ') }"
  end

  def print_table_name
    return ":#{table_name.join(', :')}" if @join_table

    ":#{table_name}"
  end

  def print_options_key_value(key, value)
    value = value.inspect if value.is_a?(Symbol)
    "#{key}: #{value}"
  end

  def print_table_type
    @join_table ? 'create_join_table' : 'create_table'
  end

  def build_database_type_methods
    DATABASE_TYPES.each do |name|
      define_singleton_method(name) do |*column_names, **column_options|
        column_names.each do |col|
          if __method__.to_s == 'references'
            table_columns["#{col}_id".to_sym] = column_options.merge(type: :integer)
            next
          end

          table_columns[col] = column_options.merge(type: __method__.to_s)
        end
      end
    end
  end

  def change_column_default(table_name, column_name, default)
    @table[table_name.to_sym][column_name.to_sym][:default] = default.is_a?(Hash) ? default[:to] : default
  end

  def change_column_null(table_name, column_name, null)
    @table[table_name.to_sym][column_name.to_sym][:null] = null
  end

  def timestamps(**column_options)
    table_columns[:timestamps] = column_options.merge(type: __method__.to_s)
  end

  def column(column_name, type, **column_options)
    table_columns[column_name] = column_options.merge(type: type.to_s)
  end

  def remove_column(column_name)
    table_columns.delete(column_name.to_sym)
  end

  def add_index(column_name, **column_options)
    table_columns[column_name][:index] = column_options.present? ? column_options : true
  end

  def remove_index(column_name)
    table_columns[column_name].delete(:index) if table_columns[column_name][:index].present?
  end

  private

  def table_columns
    @table[@table_name.to_sym]
  end

  def valid_column_name(column_name)
    return '' if column_name.to_sym == :timestamps

    " :#{column_name}"
  end

  def sanitize_table_names(table_names)
    table_names.select { |tn| tn.is_a?(Symbol) }
  end
end
