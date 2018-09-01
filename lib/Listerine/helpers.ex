defmodule Listerine.Helpers do
  use Coxir

  def intersect(a, b), do: a -- (a -- b)

  def unwords(words), do: Enum.reduce(words, fn x, a -> a <> " " <> x end)

end
