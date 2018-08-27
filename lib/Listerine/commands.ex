defmodule Listerine.Commands do
  use Coxir.Commander

  @prefix "$"

  # PING COMMAND
  command ping do
    Message.reply(message, "pong!")
  end

  command study(roles) do
    role_list = String.split(roles, " ")
    Listerine.Helpers.add_role_list(message, role_list)
  end
end
