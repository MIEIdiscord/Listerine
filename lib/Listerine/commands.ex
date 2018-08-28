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

  # REVIEW: See if this bug has been patched
  @permit :BAN_MEMBERS
  command addcourses(text) do
    [y | cl] = String.split(text, " ") |> Enum.filter(fn x -> x != "" end)

    cond do
      y in ["1", "2", "3"] ->
        case Listerine.Channels.add_courses(message.guild, y, cl) do
          [] -> Message.reply(message, "Didn't add any channels")
          cl -> Message.reply(message, "Added: #{unwords(cl)}")
        end

      true ->
        Message.reply(message, "Usage: `addcourses [1,2,3] [course, ...]`")
    end
  end

  @permit :BAN_MEMBERS
  command rmcourses(text) do
    case Listerine.Channels.remove_courses(String.split(text)) do
      [] -> Message.reply(message, "Didn't remove any channels")
      cl -> Message.reply(message, "Removed: #{unwords(cl)}")
    end
  end

  defp unwords(words), do: Enum.reduce(words, fn x, a -> a <> " " <> x end)
end
