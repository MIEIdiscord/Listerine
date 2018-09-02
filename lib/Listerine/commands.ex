defmodule Listerine.Commands do
  use Coxir.Commander

  @prefix "$"

  # PING COMMAND
  command ping do
    Message.reply(message, "pong!")
  end

  @description "Adiciona-te aos channels das cadeiras."
  command study(roles) do
    role_list = Listerine.Helpers.upcase_words(roles)

    case Listerine.Channels.add_roles(message, role_list) do
      [] -> Message.reply(message, "No roles were added")
      cl -> Message.reply(message, "Studying: #{Listerine.Helpers.unwords(cl)}")
    end
  end

  @description "Remove-te dos channels das cadeiras."
  command unstudy(roles) do
    role_list = Listerine.Helpers.upcase_words(roles)

    case Listerine.Channels.rm_role(message, role_list) do
      [] -> Message.reply(message, "No roles were removed")
      cl -> Message.reply(message, "Stoped studiyng #{Listerine.Helpers.unwords(cl)}")
    end
  end

  @permit :MANAGE_CHANNELS
  command mkcourses(text) do
    [y | cl] = Listerine.Helpers.upcase_words(text)

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

  @permit :MANAGE_CHANNELS
  command rmcourses(text) do
    args = Listerine.Helpers.upcase_words(text)

    case Listerine.Channels.remove_courses(args) do
      [] -> Message.reply(message, "Didn't remove any channels")
      cl -> Message.reply(message, "Removed: #{Listerine.Helpers.unwords(cl)}")
    end
  end

  @description "Apresenta informação sobre como aceder aos channels das cadeiras"
  command mancourses() do
    embed = %{
      title: "Informação sobre as cadeiras disponíveis",
      color: 0xFF0000,
      footer: %{
        text: "Qualquer dúvida sobre o bot podes usar `$help` para saberes o que podes fazer."
      },
      description: "`$study CADEIRA` junta-te às salas das cadeiras
         `$study 1ano` junta-te a todas as cadeiras de um ano",
      fields: Listerine.Channels.generate_courses_embed_fields()
    }

    Message.reply(message, embed: embed)
  end

  @description "Apresenta o link para a dropbox do curso."
  command dropbox() do
    text =
      "**Este é o link para o** <:dropbox:419483815912800256>**do curso** -> http://bit.ly/dropboxmiei"

    Message.reply(message, text)
  end

  @description "Apresenta o link para o calendario de testes."
  command datatestes() do
    text =
      "**As datas do teste encontram-se neste** <:googlecalendar:419486445720567809> -> http://bit.ly/calendariomiei"

    Message.reply(message, text)
  end

  @description "Apresenta esta mensagem de ajuda."
  command help() do
    embed = %{
      title: "Commands",
      color: 0xFF0000,
      fields:
        @commands
        |> Enum.filter(fn {_, _, _, desc, _} -> desc != :"" end)
        |> Enum.map(fn {_, name, _, desc, _} -> %{name: name, value: desc, inline: true} end)
    }

    Message.reply(message, embed: embed)
  end
end
