require 'guard'
require 'guard/guard'

module Guard
  class Drush < Guard
    autoload :Runner,    'guard/drush/runner'
    autoload :BackgroundTask,    'guard/drush/background_task'

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super
      @options = {
        # The drush command to run
        :command => nil,
        # The @drush_alias to run the command as.
        # Can also be specified by supplying it directly with the guard command
        # E.g. `guard @my_drush_alias`
        :alias => nil,
      }.merge(options)

      @runner    = Runner.new(@options)
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      if @runner.drush_present?
        msg = "Guard::Drush is running, with Drush #{@runner.drush_version}";
        msg = msg + " #{@runner.drush_alias}" if @runner.drush_alias
        msg = msg + '!'
        UI.info msg
      end
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
      @runner.stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_change(paths)
      @runner.run(paths)
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_deletion(paths)
      @runner.run(paths)
    end
  end
end
