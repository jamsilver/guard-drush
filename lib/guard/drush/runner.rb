module Guard
  class Drush
    class Runner
      autoload :Drush4Task, 'guard/drush/drush4_task'
      autoload :Drush5Task, 'guard/drush/drush5_task'
      attr_reader :drush_version
      attr_reader :alias

      def initialize(options = {})
        @options = {
          :notification => true
        }.merge(options)

        if drush_present?
          # Detect drush version
          if Gem::Version.new(drush_version.scan(/^[0..9.]+/).first) >= Gem::Version.new('5')
            @drush_task = Drush5Task.new(drush_alias, options);
          else
            @drush_task = Drush4Task.new(drush_alias, options);
          end
        else
          UI.error "Guard::Drush could not find drush. Please ensure it is in your PATH."
          raise :task_has_failed
        end
      end

      def run(paths, options = {})
        return false if paths.empty?

        options = @options.merge(options)
        # Escape " in paths as we use this to delimit them
        paths.each_index {|i|
          paths[i].gsub!(/"/, '\\"')
        }
        command = %Q{#{options[:command]} "#{paths.join('" "')}"}
        UI.info %Q{Running Drush command: #{command}}
        @drush_task.run(command, options);
      end

      def stop
        @drush_task.close
      end

      # Validates that drush is available on the shell
      def drush_present?
        `drush --version > /dev/null 2>&1`
        $?.success?
      end

      def drush_version
        @drush_version ||= @drush_version || determine_drush_version
      end

      def drush_alias
        @drush_alias ||= @drush_alias || determine_drush_alias
      end

    private

      def determine_drush_version
        version = `drush --version`
        return version.downcase.gsub(/^\s*drush\s*version/, '').strip
      end

      # Determine which drush @alias the user specified we should run under.
      # The following locations are looked in high -> low priority order until
      # a valid alias is found:
      #  1. Passed as the :alias option
      #  2. @drush_alias-esque argument passed to the original guard call
      #  3. DRUSH_ALIAS environment variable
      def determine_drush_alias

        drush_alias = nil

        # 1. Failing that, look in the options
        if @options.has_key?(:alias)
          drush_alias = @options[:alias]
        end

        # 2. Check through all command-line arguments to the initial `guard`
        # call to see if the user supplied it there.
        # *edit*: OK, this doesn't work. Guard checks all it's options.
        #$*.each do |arg|
        #  if !drush_alias && arg.strip!.match(/\A\@\w+\z/)
        #    drush_alias = arg
        #  end
        #end

        # 3. Failing that, check for environment variable
        if !drush_alias && ENV.has_key?('DRUSH_ALIAS')
          drush_alias = ENV['DRUSH_ALIAS']
        end

        # Ensure drush_alias begins with '@'
        return drush_alias ? ('@' + drush_alias.strip.gsub(/^@/, '')) : nil
      end

    end
  end
end
