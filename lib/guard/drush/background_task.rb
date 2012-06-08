module Guard
  class Drush
    class DrushBackgroundTask

      def initialize(command, options = {})
        options = {
          :maintain_drush_output => true,
        }.merge(options)

        @pipe = IO.popen(command, "w+")
        
        if @pipe.pid
          
          # Spawn a seperate process just for monitoring our background task
          # and printing its output to our own stdout.
          @closing = false
          if options[:maintain_drush_output]
            @monitor_pid = fork do
              while @pipe && !@pipe.closed?
                if output=read
                  puts output
                end
              end
            end
            Process.detach @monitor_pid
          end

          # Cheeky ruby 'destructor' which makes absolute sure we end the
          # background process if it has problems
          ObjectSpace.define_finalizer(self, proc {
            # Indicates that close was not called
            @closing = true
            begin
              if @pipe
                @pipe.close
              end
              if @pipe.pid
                Process.detach @pipe.pid
                Process.kill 'KILL', @pipe.pid
                Process.kill 'KILL', @monitor_pid
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
        @closing = true
        if @pipe
          @pipe.close
        end
        if @pipe.pid
          Process.detach @pipe.pid
          Process.kill 'KILL', @pipe.pid
          Process.kill 'KILL', @monitor_pid
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
      def read(timeout = 60)
        if @pipe && !@pipe.closed?
          ready_read, ready_write, = IO.select([@pipe], nil, nil, timeout)
          return nil if ready_read.empty?
          ready_read.each do |r|
            buf = r.gets
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
