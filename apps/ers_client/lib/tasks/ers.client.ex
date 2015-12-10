defmodule Mix.Tasks.Ers.Client do
  use Mix.Task

  def run(args) do
    Mix.Task.run("run", run_args() ++ args)
  end

  defp run_args do
    if iex_running?, do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
