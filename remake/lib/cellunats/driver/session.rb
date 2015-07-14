 def connect # PRV
        opt = Hashie::Mash.new verbose: false, pedantic: false
        cs = { :verbose => opt[:verbose], :pedantic => opt[:pedantic] }
        # TODO add cs[:user] & cs[:pass] support for auth
        raise "Auth not implemented" if auth_required?
        cs[:ssl_required] = opt[:ssl] if opt[:ssl]
        push_line CONNECT, cs.to_json
        expect_ok if opt.verbose
      end

      def auth_required?
        server_info.auth_required
      end

      def server_info
        unless @server_info
          if receive_line =~ INFO_PATTERN
            @server_info = Hashie::Mash.new JSON.parse($1)
            debug "Server INFO: #{@server_info.to_h}"
          else
            raise "NATS protocol error, expecting INFO but received: #{info_command}"
          end
        end
        return @server_info
      end

      def expect_ok
        incoming = receive_line
        if incoming =~ OK_PATTERN
          return true  
        else
          raise "NATS protocol error: expected OK but received [#{incoming}]"
        end
      end