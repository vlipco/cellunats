module NATS
  module Protocol 
    class Driver

      def encode(*elements)
        elements.push CR_LF # All commands end with the control line
        elements.map! do |e| 
          case e
            when CR_LF; CR_LF
            when EMPTY, SPACE, nil; nil
            else [e]
          end
        end
        encoded = elements.flatten.compact.join(SPACE)
        encoded.gsub("#{SPACE}#{CR_LF}", CR_LF).gsub("#{CR_LF}#{SPACE}", CR_LF)
      end

    end # Driver class
  end # Protocol module
end # NATS module