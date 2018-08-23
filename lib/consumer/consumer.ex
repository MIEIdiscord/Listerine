defmodule Consumer do
  use Coxir

  def handle_event({:MESSAGE_CREATE, message}, state) do
    case message.content do
      "ping!" ->
        Message.reply(message, "pong!")
      _ ->
        :ignore
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
