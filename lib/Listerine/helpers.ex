defmodule Listerine.Helpers do
  use Coxir
  
  def intersect(a, b), do: a -- a -- b
end
