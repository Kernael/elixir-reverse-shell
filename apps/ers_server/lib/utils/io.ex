defmodule Ers.Server.Utils.IO do
  def put_info(msg) do
    IO.puts(IO.ANSI.blue <> msg <> IO.ANSI.reset)
  end
  def put_msg(msg \\ "ping") do
    IO.puts(IO.ANSI.yellow <> msg <> IO.ANSI.reset)
  end
  def put_success(msg \\ "ok") do
    IO.puts(IO.ANSI.green <> msg <> IO.ANSI.reset)
  end
  def put_error(msg \\ "error") do
    IO.puts(IO.ANSI.red <> msg <> IO.ANSI.reset)
  end
end
