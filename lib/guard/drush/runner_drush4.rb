module Guard
  class Drush
    class RunnerDrush4
      autoload :DrushBackgroundTask, 'guard/drush/background_task'

      def initialize(drush_alias)
        cmd_parts = []
        cmd_parts << 'drush'
        cmd_parts << drush_alias if drush_alias
        cmd_parts << 'cli'
        @bg = DrushBackgroundTask.new(cmd_parts.join(' '))
      end

      def run(command, options = {})
        command = drush_command(command, options)
        @bg.writeLine(command)
      end

      def close
        @bg.close
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
