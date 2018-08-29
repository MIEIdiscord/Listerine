defmodule Listerine.Helpers do
  use Coxir
  
  def merge(a, b, c) do
    merged = Map.merge(a, b)
    Map.merge(merged, c)
  end
  
  def intersect(a, b), do: a -- a -- b
end
