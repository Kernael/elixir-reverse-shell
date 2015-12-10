defmodule Ers.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     app: :ers,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  defp deps do
    []
  end
end
