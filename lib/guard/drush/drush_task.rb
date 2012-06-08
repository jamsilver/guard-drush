module Guard
  class Drush
    class DrushTask
      autoload :DrushBackgroundTask, 'guard/drush/background_task'

      def initialize(drush_alias, options = {})

        @drush_alias = drush_alias

        @options = {
          :drush_live => true,
          :drush_live_auto_reload => true,
          :drush_live_timeout => false,
        }.merge(options)

        # Run a drush_live command in case it's available!
        cmd_parts = []
        if @options[:drush_live]
          cmd_parts << 'drush'
          cmd_parts << drush_alias if drush_alias
          cmd_parts << '--auto-reload' if options[:drush_live_auto_reload]
          cmd_parts << %Q{--reload-timeout="#{options[:drush_live_timeout]}"} if options[:drush_live_timeout]
          # We need this option so we can pass aliases to drush live later on
          # and for them to be silently ignored.
          # Necessary so we can pass the same format of commands in later, and
          # for it to work the same whether or not drush live is around.
          cmd_parts << '--strip-aliases'
          cmd_parts << 'live'
        end
        @bg = DrushBackgroundTask.new(cmd_parts.join(' '), @options)
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
        cmd_parts << @drush_alias if @drush_alias
        cmd_parts << command
        cmd_parts.compact.join(' ');
      end

    end
  end
end
