module NATS
  module Protocol
    class StateMachine
      class << self

        def build(context)
          sm = Statemachine.build do
            state :disconnected do
              event :connect, :connecting
              on_exit :receive_server_info_action
            end

            state :connecting do
              on_entry :establish_connection_action
              event :wait_line, :waiting_line
            end

            superstate :connected do
              event :disconnect, :disconnected, :disconnect_action
              # this state does nothing when triggered
              state :waiting_line do
                # set the context's current_line and then trigger this event
                event :process_line, :waiting_line, :process_line_action
                # if the context gets a message notification, it'll trigger this event
                event :expect_payload, :waiting_payload
              end

              state :waiting_payload do
                on_entry :receive_payload_action
                event :wait_line, :waiting_line
              end
            end
            state :disconnected
          end
          sm.context = context
          return sm
        end # build

      end # class methods
    end # Statemachine class
  end # Protocol module
end # NATS module