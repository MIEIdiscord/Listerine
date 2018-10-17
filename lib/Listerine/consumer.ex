defmodule Listerine.Consumer do
  use Coxir.Commander
  use Listerine.Commands

  def handle_event({:GUILD_MEMBER_ADD, member}, state) do
    embed = %{
      title: "Bem vindo ao servidor de MIEI!",
      color: 0xFF0000,
      thumbnail: %{url: Listerine.Helpers.get_guild_icon_url(Guild.get(member.guild_id))},
      footer: %{
        text: "Qualquer dúvida sobre o bot podes usar $man man para saberes o que podes fazer."
      },
      description: """
      O nosso objetivo é facilitar a vossa passagem neste curso, através de um servidor com todas as cadeiras, materiais e conteúdos para que possam estar sempre a par do que acontece em cada cadeira.
      Temos também uma sala `#geral` onde podemos conversar de uma forma mais informal e um conjunto de `#regras` que devem ser cumpridas e que podem sempre consultar com alguma dúvida que tenham.
      Temos também o nosso bot #{User.get().username} que permite que te juntes às salas das cadeiras com o comando `$study CADEIRA1, CADEIRA2, ...` ou, se preferires, podes-te juntar a todas as cadeiras de um ano com o comando `$study Xano` substituindo o `X` pelo ano que queres.
      """
    }

    User.send_message(member.user, %{embed: embed})

    {:ok, state}
  end

  def handle_event({:READY, _user}, state) do
    game = %{
      type: 0,
      name: "$man man"
    }

    Gateway.set_status("online", game)

    {:ok, state}
  end

  def handle_event({:VOICE_STATE_UPDATE, payload}, state) do
    Listerine.VoiceChannels.normalize_voice_channels(payload.guild_id)
    {:ok, state}
  end
end
