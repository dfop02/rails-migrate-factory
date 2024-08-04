class MigrateFactoryRails::UI
  class << self
    def print_message(message, color = nil)
      if color.nil?
        puts message
        return
      end

      puts color_msg(color.to_sym, message)
    end

    private

    def color_msg(color, msg)
      case color
      when :black
        "\033[30m#{msg}\033[0m"
      when :red
        "\033[31m#{msg}\033[0m"
      when :green
        "\033[32m#{msg}\033[0m"
      when :brown
        "\033[33m#{msg}\033[0m"
      when :blue
        "\033[34m#{msg}\033[0m"
      when :magenta
        "\033[35m#{msg}\033[0m"
      when :cyan
        "\033[36m#{msg}\033[0m"
      when :gray
        "\033[37m#{msg}\033[0m"
      else
        msg
      end
    end
  end
end
