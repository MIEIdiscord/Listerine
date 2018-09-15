defmodule Listerine.Commands do
  use Coxir.Commander

  @prefix "$"
  @man_pages [
    study: [
      description: "Permite a um aluno juntar-se às salas das cadeiras.",
      synopse: "`#{@prefix}study [CADEIRA|ANO, ...]`",
      options: :nil,
      example: """
      `#{@prefix}study Algebra PI`
      Adiciona-te às salas de Algebra e PI.
      `#{@prefix}study 1ano`
      Adiciona-te a todas as cadeiras do primeiro ano.
      """,
      return_value: "A lista de cadeiras validas a que foste adicionado."
    ],
    unstudy: [
      description: "Permite a um aluno sair das salas das cadeiras.",
      synopse: "`#{@prefix}unstudy [CADEIRA|ANO, ...]`",
      options: :nil,
      example: """
      `#{@prefix}unstudy Algebra PI`
      Remove-te das salas de Algebra e PI.
      `#{@prefix}unstudy 1ano`
      Remove-te de todas as cadeiras do primeiro ano.
      """,
      return_value: "A lista de cadeiras validas a que foste removido."
    ],
    courses: [
      description: "Permite interagir com as salas das cadeiras.",
      synopse: """
      ```
      #{@prefix}courses list
               mk ano [CADEIRA, ...] (admin only)
               rm [CADEIRA, ...] (admin only)
      ```
      """,
      options:
      """
      __mk__
      -> Cria salas das cadeiras especificadas, associadas ao ano especificado.
      __rm__
      -> Remove salas das cadeiras especificadas.
      __list__
      -> Lista as cadeiras disponíveis.
      """,
      example: :nil,
      return_value: :nil
    ],
    material: [
      description: "Apresenta o link para o material de apoio do curso.",
      synopse: "`#{@prefix}material`",
      options: :nil,
      example: :nil,
      return_value: "O link para o material de apoio do curso."
    ]
    #    datatestes: "Apresenta o link para o calendario de testes.",
  ]

  command study(roles) do
    if Listerine.Helpers.bot_commands?(message) do
      role_list = Listerine.Helpers.upcase_words(roles) |> Listerine.Helpers.roles_per_year()

      case Listerine.Channels.add_roles(message, role_list) do
        [] -> Message.reply(message, "Não foste adicionado a nenhuma sala.")
        cl -> Message.reply(message, "Studying: #{Listerine.Helpers.unwords(cl)}")
      end
    else
      Channel.send_message(
        Channel.get(Listerine.Helpers.get_bot_commands_id()),
        Listerine.Helpers.make_mention(message.author) <>
          " Esse commando tem de ser utilizado nesta sala!"
      )
    end
  end

  command unstudy(roles) do
    if Listerine.Helpers.bot_commands?(message) do
      role_list = Listerine.Helpers.upcase_words(roles) |> Listerine.Helpers.roles_per_year()

      case Listerine.Channels.rm_role(message, role_list) do
        [] -> Message.reply(message, "Não foste removido de nenhuma sala.")
        cl -> Message.reply(message, "Stopped studiyng #{Listerine.Helpers.unwords(cl)}")
      end
    else
      Channel.send_message(
        Channel.get(Listerine.Helpers.get_bot_commands_id()),
        Listerine.Helpers.make_mention(message.author) <>
          " Esse commando tem de ser utilizado nesta sala!"
      )
    end
  end

  @permit :MANAGE_CHANNELS
  @space :courses
  command mk(text) do
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
  @space :courses
  command rm(text) do
    args = Listerine.Helpers.upcase_words(text)

    case Listerine.Channels.remove_courses(args) do
      [] -> Message.reply(message, "Didn't remove any channels")
      cl -> Message.reply(message, "Removed: #{Listerine.Helpers.unwords(cl)}")
    end
  end

  @permit :ADMINISTRATOR
  command setbotcommands() do
    Listerine.Helpers.set_bot_commands(message.channel)
    Message.reply(message, "Channel set")
  end

  @space :courses
  command list() do
    if Listerine.Helpers.bot_commands?(message) do
    embed = %{
      title: "Informação sobre as cadeiras disponíveis",
      color: 0x000000,
      description: """
      `$study CADEIRA` junta-te às salas das cadeiras
      `$study 1ano` junta-te a todas as cadeiras de um ano
      """,
        fields: Listerine.Channels.generate_courses_embed_fields()
      }

      Message.reply(message, embed: embed)
    else
      Channel.send_message(
        Channel.get(Listerine.Helpers.get_bot_commands_id()),
        Listerine.Helpers.make_mention(message.author) <>
          " Esse commando tem de ser utilizado nesta sala!"
      )
    end
  end

  command material() do
    text =
      "**Este é o link para o material do curso** -> http://bit.ly/materialmiei"

    Message.reply(message, text)
  end

  # command datatestes() do
  # text =
  #  "**As datas do teste encontram-se neste calendário** -> http://bit.ly/calendariomiei"

  # Message.reply(message, text)
  # end

  command man(arg) do
    if Listerine.Helpers.bot_commands?(message) do
    arg = String.downcase(arg)
    msg = cond do
      arg === "man" ->
        %{
          title: "Comandos:",
          color: 0x000000,
          description:
          @man_pages
          |> Enum.map(fn {name, cmd} -> "**#{name}** -> #{
            Enum.find(cmd, fn {a,_} -> a == :description end) |> elem(1)
          }\n" end)
          |> Enum.reduce("", fn x, acc -> acc <> x end),
          footer: %{ text: "$man [comando] para saberes mais sobre algum comando" }
        }
        Enum.any?(@man_pages, fn {name, _} -> Atom.to_string(name) == arg end) ->
        %{
          title: arg,
          color: 0x000000,
          fields: Enum.find(@man_pages, nil, fn {name, _} -> Atom.to_string(name) == arg end)
          |> elem(1)
          |> Enum.filter(fn {_, text} -> text != :nil end)
          |> Enum.map(fn {section, text} -> %{
            name: section |> Atom.to_string() |> String.upcase(),
            value: text,
            inline: false
          } end)
        }
      true ->
        %{
          title: "No manual entry for #{arg}",
          color: 0xFF0000,
          description: "Usa `$man man` para ver a lista de comandos."
        }
    end
    Message.reply(message, embed: msg)
    else
      Channel.send_message(
        Channel.get(Listerine.Helpers.get_bot_commands_id()),
        Listerine.Helpers.make_mention(message.author) <>
          " Esse commando tem de ser utilizado nesta sala!"
      )
    end
  end
end
