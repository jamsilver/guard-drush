module Guard
  class Drush
    class DrushBackgroundTask

      def initialize(command, options = {})
        options = {
          :show_output => false,
        }.merge(options)

          
        # If we are running a suitable version of ruby and have specified that
        # we want to see Drush output in the console run popen in a special way.
        if options[:show_output]
          if Gem::Version.new(RUBY_VERSION.scan(/^[0..9.]+/).first) >= Gem::Version.new('1.9')
            UI.info "Running with advanced form"
            require 'guard/drush/background_task_stdout'
            @pipe = DrushPOpen.popen(command)
          else
            UI.info "At least Ruby version 1.9 is needed to support :show_output option (Current version: #{RUBY_VERSION})"
          end
        end
        
        # A fallback simpler popen call which discards stdout.
        if !@pipe
          UI.info "Running with simple form"
          @pipe = IO.popen(command, "w+")
        end

        if @pipe && !@pipe.closed?
          Process.detach @pipe.pid
          # Cheeky ruby 'destructor' which makes absolute sure we end the
          # background process if it has problems
          ObjectSpace.define_finalizer(self, proc {
            begin
              if @pipe
                @pipe.close
              end
              if @pipe.pid
                Process.kill 'TERM', @pipe.pid
              end
            rescue
              # It's not uncommon for a long-running guard command to get a
              # broken pipe error if there was an error in the background
              # process.
            end
          })
        end
      end

      def close
        if @pipe && !$pipe.closed?
          @pipe.puts('exit')
          @pipe.close
        end
        if @pipe.pid
          Process.kill 'TERM', @pipe.pid
        end
      rescue
        # It's not uncommon for a long-running guard command to get a broken
        # pipe error if there was an error in the background process
      end

      # Write a line to the
      def writeLine(text)
        if @pipe && !@pipe.closed?
          @pipe.puts(text)
        end
      end

      # Waits for timeout seconds and returns what was read in that time.
      def read
        if @pipe && !@pipe.closed?
          ready_read, ready_write, = IO.select([@pipe], nil, nil, 1)
          return nil if !ready_read || ready_read.empty?
          ready_read.each do |r|
            buf = ''
            buf += r.readline while !r.eof
            if buf.length == 0
                puts "The server connection is dead. Exiting."
                exit
            else
                return buf
            end
          end
        end
      end

    end
  end
end
