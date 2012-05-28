module Guard
  class Drush
    class Runner
      attr_reader :drush_version
      attr_reader :drush_alias

      def initialize(options = {})
        @options = {
          :maintain_drush_output => true,
          :notification => true
        }.merge(options)
      end

      def run(paths, options = {})
        return false if paths.empty?

        options = @options.merge(options)
        command = drush_command(paths, options);

        message = options[:message] || "Running: #{command}"
        UI.info(message, :reset => true)

        success = system(command);

        if @options[:notification] && !success && drush_command_exited_with_an_exception?
          Notifier.notify("Failed", :title => "Drush results", :image => :failed, :priority => 2);
        end


      end

      # Validates that drush is available on the shell
      def is_drush_present?
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
        cmd_parts << "> /dev/null 2>&1" if options[:maintain_drush_output]
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
      # a valid alias is found.
      #  1. @drush_alias-esque argument passed to the original guard call
      #  2. Passes as the :drush_alias option
      def determine_drush_alias

        drush_alias = nil

        # 1. Check through all command-line arguments to the initial `guard`
        # call to see if the user supplied it there.
        # *edit*: OK, this doesn't work. Guard checks all it's options.
        #$*.each do |arg|
        #  if !drush_alias && arg.strip!.match(/\A\@\w+\z/)
        #    drush_alias = arg
        #  end
        #end

        # 2. Failing that, look in the options
        if !drush_alias && @options.has_key?(:drush_alias)
          drush_alias = @options[:drush_alias]
        end

        return drush_alias ? drush_alias.strip : nil
      end

    end
  end
end
