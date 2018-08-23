defmodule Example.Mixfile do
  use Mix.Project

  def project do
    [
      app: :Listerine,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Listerine, []}
    ]
  end

  defp deps do
    [
      {:coxir, git: "https://github.com/satom99/coxir.git"}
    ]
  end
end
