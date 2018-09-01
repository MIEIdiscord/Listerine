defmodule Listerine.Helpers do
  use Coxir

  def get_guild_icon_url(guild),
    do: "https://cdn.discordapp.com/icons/" <> guild.id <> "/" <> guild.icon <> ".png"

  def intersect(a, b), do: a -- (a -- b)

  def unwords(words), do: Enum.reduce(words, fn x, a -> a <> " " <> x end)
end
