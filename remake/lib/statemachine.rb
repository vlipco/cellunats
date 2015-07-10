puts "%%%%%%"
module NATS

  module Protocol

    class StateMachine

      class << self

        def build
          
          Statemachine.build do

            state :disconnected do
              event :connect, :connecting, :open_connection_action
            end

            state :connecting do
              on_entry :authenticate_action
              event :listen, :listening
            end

            superstate :connected do
              event :disconnect, :disconnected, :disconnect_action

              state :listening do
                on_entry :receive_line_action
                event :process_line, :processing
              end

              state :processing do
                on_entry :process_line_action
                event :expect_payload, :waiting_payload
              end

              state :waiting_payload do
                on_entry :receive_payload_action
                event :listen, :listening
              end
            end

            state :disconnected

          end

        end

      end

    end

  end

end