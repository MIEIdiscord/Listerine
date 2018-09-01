defmodule Listerine.Consumer do
  use Coxir.Commander
  use Listerine.Commands

  def handle_event({:GUILD_MEMBER_ADD, member}, state) do
    embed = %{
      title: "Bem vindo ao servidor de MIEI!",
      color: 0xFF0000,
      thumbnail: %{url: Listerine.Helpers.get_guild_icon_url(Guild.get(member.guild_id))},
      footer: %{
        text: "Qualquer dúvida sobre o bot podes usar `$help` para saberes o que podes fazer."
      },
      description:
        "O nosso objetivo é facilitar a vossa passagem neste curso, através de um server com todas as cadeiras, materiais e conteúdos para que possam estar sempre a par do que acontece em cada cadeira.
        Temos também uma sala `#geral` onde podemos conversar de uma forma mais informal e um conjunto de `#regras` que devem ser cumpridas e que podem sempre consultar com alguma dúvida que tenham.
        Temos também o nosso bot BOT_NAME que permite que te juntes às salas das cadeiras com o comando `$study CADEIRA` ou, se preferires, podes te juntar a todas as cadeiras de um ano com o comando `$study 1ano`"
    }

    User.send_message(member.user, %{embed: embed})

    {:ok, state}
  end
end
