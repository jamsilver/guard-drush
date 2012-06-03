module Guard
  class Drush
    class DrushBackgroundTask

      def initialize(command)
        if @pipe = IO.popen(command, "w+")
          pipe = @pipe
          pid = pipe.pid

          # Cheeky ruby 'destructor' which makes absolute sure we end the
          # background process if it has problems
          ObjectSpace.define_finalizer(self, proc {
            # Indicates that close was not called
            begin
              if @pipe && !@pipe.closed?
                @pipe.puts('')
                @pipe.puts('exit')
                Process.detach pid
                pipe.close
              end
              if pid
                Process.kill 'TERM', pid
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
        if @pipe && !@pipe.closed?
          @pipe.puts('')
          @pipe.puts('exit')
          Process.detach @pipe.pid
          @pipe.close
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
      def read(timeout = 1)
        if @pipe && !@pipe.closed?
          if output = IO.select([@pipe], nil, nil, timeout)
            return output[0]
          end
        end
      end
    end
  end
end
