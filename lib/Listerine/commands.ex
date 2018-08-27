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
  command addcourses(courses) do
    [y | cl] = String.split(courses, " ")

    cond do
      y in ["1", "2", "3"] ->
        Listerine.Channels.add_courses(message.guild, y, Enum.uniq(cl))

      true ->
        Message.reply(message, "Usage: `addcourses [1,2,3] [course, ...]`")
    end
  end

  @permit :BAN_MEMBERS
  command rmcourses(courses) do
    [y | cl] = String.split(courses, " ")

    cond do
      y in ["1", "2", "3"] ->
        Listerine.Channels.remove_courses(message.guild, y, Enum.uniq(cl))

      true ->
        Message.reply(message, "Usage: `addcourses [1,2,3] [course, ...]`")
    end
  end
end
