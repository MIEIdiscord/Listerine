defmodule Listerine.Helpers do
  use Coxir

  def get_guild_icon_url(guild),
    do: "https://cdn.discordapp.com/icons/" <> guild.id <> "/" <> guild.icon <> ".png"

  def roles_per_year(role_list) do
    Enum.map(
      role_list,
      fn
        <<year::binary-size(1), "ANO">> -> Listerine.Channels.get_roles_year(year)
        x -> x
      end
    )
    |> List.flatten()
  end

  @doc """
  Returns the intersection of the two sets.
  Note: It's right associative.
  """
  def intersect(a, b), do: a -- a -- b

  @doc """
  Joins words with separating spaces.

  ### Example:

  `["The", "fox"]` becomes `"The fox"`
  """
  def unwords(words), do: Enum.reduce(words, fn x, a -> a <> " " <> x end)

  @doc """
  Turns a string into a list of it's upcased words.

  ### Example:
  `"The quick brown fox jumps over the lazy dog"` becomes
  `["THE", "QUICK", "BROWN", "FOX", "JUMPS", "OVER", "THE", "LAZY", "DOG"]`
  """
  def upcase_words(string) do
    String.split(string, " ")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(&String.upcase/1)
  end
end
