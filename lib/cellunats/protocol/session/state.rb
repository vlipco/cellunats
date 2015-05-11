require 'statemachine'

module CelluNATS
  module Protocol
    module Decoder

      include Constants

      def new_protocol_machine

        fsm = Statemachine.build do

          state :disconnected do
            event :connect, :reading_info
          end

          state :reading_info do
            on_entry :read_info
            event :info, :connecting
          end

          state :connecting do
            on_entry :send_connect 
            event :ok, :waiting_command
          end

          state :waiting_command do
            on_entry :flush_pending # in case there were enqueued commands, send them
            event :ping, :waiting_command, :send_pong # reply with pong when pinged 
            event :message, :waiting_payload
            event :ok, :waiting_command # ok must be accepted but it's a NOOP
            #event :pong, :waiting_command, :ping
          end

          state :waiting_pong do
            on_entry :read_command
            event :pong, :waiting_command
          end

          state :waiting_payload do
            on_entry :receive_payload
            event :notify_message, :waiting_command, :notify_message
          end

        end # closes build block
        
        fsm.context = self
        return fsm
      end

    end
  end
end