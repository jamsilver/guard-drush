module Guard
  class Drush
    class RunnerDrush5

      def initialize(drush_alias = nil)
        @drush_alias = drush_alias
        if @drush_alias
          system("drush use #{@drush_alias}");
        end
      end

      def run(command, options = {})
        command = drush_command(command, options)
        system(drush_command(command, options))
      end

      def close
      end

    private

      def drush_command(command, options = {})
        cmd_parts = []
        cmd_parts << "drush"
        cmd_parts << command
        cmd_parts << "> /dev/null 2>&1" if !options[:maintain_drush_output]
        cmd_parts.compact.join(' ');
      end

    end
  end
end
