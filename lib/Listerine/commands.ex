defmodule Listerine.Commands do
  use Coxir.Commander

  @prefix "$"

  # PING COMMAND
  command ping do
    Message.reply(message, "pong!")
  end

  command study(roles) do
    case roles do
      [] ->
        Message.reply(message, "Usage: `study [course, ...]`")

      _ ->
        role_list =
          String.upcase(roles)
          |> String.split(" ")

        a = elem(Listerine.Channels.add_role(message, role_list), 1)

        case a do
          [] ->
            Message.reply(message, "No roles were added")

          _ ->
            Message.reply(message, "Studying: #{Listerine.Helpers.unwords(a)}")
        end
    end
  end

  command unstudy(roles) do
    case roles do
      [] ->
        Message.reply(message, "Usage: `unstudy [course, ..]`")

      _ ->
        role_list =
          String.upcase(roles)
          |> String.split(" ")

        a = elem(Listerine.Channels.rm_role(message, role_list), 1)

        case a do
          [] ->
            Message.reply(message, "No roles were removed")

          _ ->
            Message.reply(message, "Stoped studiyng #{Listerine.Helpers.unwords(a)}")
        end
    end
  end

  # REVIEW: See if this bug has been patched
  @permit :BAN_MEMBERS
  command mkcourses(text) do
    [y | cl] =
      text
      |> String.split(" ")
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.map(&String.upcase/1)

    cond do
      y in ["1", "2", "3"] ->
        case Listerine.Channels.add_courses(message.guild, y, cl) do
          [] -> Message.reply(message, "Didn't add any channels")
          cl -> Message.reply(message, "Added: #{Listerine.Helpers.unwords(cl)}")
        end

      true ->
        Message.reply(message, "Usage: `mkcourses [1,2,3] [course, ...]`")
    end
  end

  @permit :BAN_MEMBERS
  command rmcourses(text) do
    text =
      String.split(text, " ")
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.map(&String.upcase/1)

    case Listerine.Channels.remove_courses(text) do
      [] -> Message.reply(message, "Didn't remove any channels")
      cl -> Message.reply(message, "Removed: #{Listerine.Helpers.unwords(cl)}")
    end
  end

  command mancourses() do
    embed = %{
      title: "Informação sobre as cadeiras disponíveis",
      color: 0xFF0000,
      footer: %{
        text: "Qualquer dúvida sobre o bot podes usar `$help` para saberes o que podes fazer."
      },
      description: "`$study CADEIRA` junta-te às salas das cadeiras
         `$study 1ano` junta-te a todas as cadeiras de um ano",
      fields: for(year <- 1..3, do: Listerine.Channels.generate_courses_embed_field(year))
    }

    Message.reply(message, embed: embed)
  end

  command dropbox() do
    text =
      "**Este é o link para o** <:dropbox:419483815912800256>**do curso** -> http://bit.ly/dropboxmiei"

    Message.reply(message, text)
  end

  command datatestes() do
    text =
      "**As datas do teste encontram-se neste** <:googlecalendar:419486445720567809> -> http://bit.ly/calendariomiei"

    Message.reply(message, text)
end
