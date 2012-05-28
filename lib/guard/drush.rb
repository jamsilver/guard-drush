require 'guard'
require 'guard/guard'

module Guard
  class Drush < Guard
    autoload :Runner,    'guard/drush/runner'

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
        :drush_alias => nil,
      }.merge(options)

      @runner    = Runner.new(@options)
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      # Validate that Drush is present
      if !@runner.is_drush_present?
        UI.error "Guard::Drush could not find drush. Please ensure it is in your PATH."
        raise :task_has_failed
      else
        UI.info "Guard::Drush is running, with Drush #{@runner.drush_version}!"
      end
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
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
