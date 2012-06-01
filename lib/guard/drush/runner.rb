module Guard
  class Drush
    class Runner
      autoload :RunnerDrush4, 'guard/drush/runner_drush4'
      autoload :RunnerDrush5, 'guard/drush/runner_drush5'
      attr_reader :drush_version
      attr_reader :alias

      def initialize(options = {})
        @options = {
          :maintain_drush_output => true,
          :notification => true
        }.merge(options)

        if drush_present?
          # Detect drush version
          if Gem::Version.new(drush_version) >= Gem::Version.new('5')
            @drush_runner = RunnerDrush5.new(drush_alias, options);
          else
            @drush_runner = RunnerDrush4.new(drush_alias, options);
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
        @drush_runner.run(command, options);
      end

      def stop
        @drush_runner.close
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

      def drush_command(paths, options)
        cmd_parts = []
        cmd_parts << "drush"
        cmd_parts << "#{drush_alias}" if drush_alias
        cmd_parts << "#{options[:command]}"
        cmd_parts += paths
        cmd_parts << "> /dev/null 2>&1" if !options[:maintain_drush_output]
        cmd_parts.compact.join(' ');
      end

      def drush_command_exited_with_an_exception?
        $?.exitstatus != 0
      end

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
