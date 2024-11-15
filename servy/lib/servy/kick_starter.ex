defmodule Servy.KickStarter do
  use GenServer

  def start_link(_args) do
    IO.puts("Starting the kickstarter...")

    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts("Starting to HTTP server!")

    ### In Erlang, processes can be linked together. These links are bi-directional. Whenever a process dies,
    ### it sends an exit signal to all linked processes. Each of these processes will have the trapexit flag enabled or disabled.
    ### If the flag is disabled (default), the linked process will crash as soon as it gets the exit signal. If the flag has been
    ### enabled by a call to system_flag(trap_exit, true), the process will convert the received exit signal into an exit message
    ### and it will not crash. The exit message will be queued in its mailbox and treated as a normal message.
    # https://stackoverflow.com/a/6774537
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HTTP server died with reason: #{inspect(reason)}")

    server_pid = start_server()
    {:noreply, server_pid}
  end

  defp start_server do
    IO.puts("Starting the HTTP server...")
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])
    # Process.link(server_pid)
    Process.register(server_pid, :http_server)
    server_pid
  end
end
