defmodule Ers.Server do
  use Application

  def port, do: Application.get_env(:ers, :port)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Task, [__MODULE__, :listen, [port]])]

    opts = [strategy: :one_for_one, name: Ers.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def listen(port) do
    IO.puts "hello, world !"
  end
end
