# frozen_string_literal: true

module Uncruft
  class DeprecationHandler
    def call(message, _callstack)
      line_number = line_number(message)
      message = normalize_message(message)
      handle_unknown_deprecation!(message, line_number) unless known_deprecations.include?(message)
    end

    def arity
      2
    end

    private

    def handle_unknown_deprecation!(message, line_number)
      if Uncruft.record_deprecations?
        known_deprecations << message
        write_deprecations_file!
      else
        raise error_message(message, line_number)
      end
    end

    def write_deprecations_file!
      file = File.open(Uncruft.ignorefile_path, 'w')
      file.puts(file_content(known_deprecations))
      file.close
    end

    def line_number(message)
      message.match(/called from( .+ at)? .+:(\d+)/)&.[](2)
    end

    # Rails deprecation message formats found here:
    # https://github.com/rails/rails/blob/5-0-stable/activesupport/lib/active_support/deprecation/reporting.rb#L75
    def normalize_message(message)
      remove_line_number(normalize_caller(normalize_callstack_path(message)))
    end

    def normalize_callstack_path(message)
      if (gem_home = gem_home(message)).present?
        message.gsub!(gem_home, '$GEM_PATH')
      end

      if message.include?(bin_dir)
        message.gsub!(bin_dir, '$BIN_PATH')
      end

      if (absolute_path = absolute_path(message)).present?
        message.gsub!(absolute_path, relative_path(absolute_path))
      end
    end

    def normalize_caller(message)
      normalize_require_callers(remove_view_callers(message))
    end

    def normalize_require_callers(message)
      message.gsub(/ <(top \(required\)|main)> at /, ' <global scope> at ')
    end

    def remove_view_callers(message)
      message.gsub(/ _\w+__+\d+_\d+ at /, ' ')
    end

    def remove_line_number(message)
      message.sub(/(called from( .+ at)? .+):\d+/, '\1')
    end

    def gem_home(message)
      message.match(%r{(?i:c)alled from( .+ at)? (#{ENV['GEM_HOME']}/(.+/)*gems)})&.[](2) # rubocop:disable Style/FetchEnvVar
    end

    def absolute_path(message)
      message.match(/called from( .+ at)? (.+):\d/)&.[](2)
    end

    def relative_path(absolute_path)
      Pathname.new(absolute_path)
        .relative_path_from(Rails.root).to_s
        .gsub(%r{\A(../)*vendor/cache}, '$GEM_PATH')
        .gsub(%r{\A(vendor/bundle/ruby/\d\.\d\.\d/bin)}, '$BIN_PATH')
    rescue ArgumentError # When `relative_path_from` cannot find a relative path.
      absolute_path
    end

    def bin_dir
      RbConfig::CONFIG['bindir']
    end

    def error_message(message, line_number)
      <<~ERROR.strip
        #{message}:#{line_number}

        To resolve this error, adjust your code according to the instructions above.
        If you did not introduce this error or are unsure why you are seeing it,
        you will find additional guidance at the URL below:
        https://github.com/Betterment/uncruft/blob/main/GUIDE.md
      ERROR
    end

    def known_deprecations_file_exists?
      File.file?(Uncruft.ignorefile_path)
    end

    def known_deprecations
      @known_deprecations ||= if known_deprecations_file_exists?
                                file = File.read(Uncruft.ignorefile_path)
                                JSON.parse(file)['ignored_warnings'].to_set
                              else
                                Set.new
                              end
    end

    def file_content(deprecations)
      JSON.pretty_generate ignored_warnings: deprecations.sort,
                           updated: now,
                           rails_version: Rails::VERSION::STRING
    end

    def now
      if defined?(Timecop)
        Timecop.return { Time.zone.now }
      else
        Time.zone.now
      end
    end
  end
end
