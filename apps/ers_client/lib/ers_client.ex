defmodule Ers.Client do
  use Application

  @module __MODULE__

  def connect_opts, do: [:binary, active: false]
  def host,         do: Application.get_env(:ers_client, :host)
  def port,         do: Application.get_env(:ers_client, :port)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Task, [@module, :connect, [port]])]

    opts = [strategy: :one_for_one, name: Ers.Client.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def connect(port) do
    IO.puts "trying to connect to #{host}:#{port}"

    case :gen_tcp.connect(to_char_list(host), port, connect_opts) do
      {:ok, server} -> wait_for_input(server)
      _             -> sleep()
    end
  end

  def wait_for_input(server) do
    case :gen_tcp.recv(server, 0) do
      {:ok, cmd} -> process(server, cmd)
      _          -> sleep()
    end
  end

  def process(server, cmd) do
    case String.rstrip(cmd) do
      _ ->
        :gen_tcp.send(server, "pong\n")
        wait_for_input(server)
    end
  end

  def sleep do
    Process.exit(self, :kill)
  end
end
