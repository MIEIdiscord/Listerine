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

  def handle_event({:GUILD_MEMBER_ADD, member}, state) do
    message = "Bem vindo ao servidor de MIEI!
    O nosso objetivo é facilitar a vossa passagem neste curso, através de um server com todas as cadeiras, materiais e conteúdos para que possam estar sempre a par do que acontece em cada cadeira.
    Temos também uma sala `#geral` onde podemos conversar de uma forma mais informal e um conjunto de `#regras` que devem ser cumpridas e que podem sempre consultar com alguma dúvida que tenham.
    Temos também o nosso bot BOT_NAME que permite que te juntes às salas das cadeiras com o comando `*study CADEIRA` ou, se preferires, podes te juntar a todas as cadeiras de um ano com o comando `*study 1ano`.
    Qualquer dúvida sobre o bot podes usar `*help` para saberes o que podes fazer"

    User.send_message(member.user, message)
    # TODO: Log potential errors from send_message to a log channel
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
