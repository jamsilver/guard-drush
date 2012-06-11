module Guard
  class Drush
    class DrushPOpen
      def self.popen(command)
        return IO.popen([command, :out=>:out], "w+")
      end
    end
  end
end
