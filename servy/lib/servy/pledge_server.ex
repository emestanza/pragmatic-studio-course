defmodule Servy.GenericServer do
  def start(callback_module, initial_state, server_name) do
    # Starts the server with an empty state
    IO.puts("Starting the Pledge Server...")
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, server_name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    # Listens for incoming requests
    IO.puts("Waiting for a message...")

    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServer do
  @server_name :pledge_server
  alias Servy.GenericServer

  # Client
  def start() do
    GenericServer.start(__MODULE__, [], @server_name)
  end

  def create_pledge(name, amount) do
    # Sends the pledge to the external service and caches it
    # pledge = %{name: name, amount: amount}
    # IO.inspect(pledge)
    GenericServer.call(@server_name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@server_name, :recent_pledges)
  end

  def total_pledged() do
    GenericServer.call(@server_name, :total_pledged)
  end

  def clear() do
    GenericServer.cast(@server_name, :clear)
  end

  # Server

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, fn {_, amount} -> amount end) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent]
    {id, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end

  def send_pledge_to_service(_name, _amount) do
    # Sends the pledge to the external service
    # and returns the ID of the created pledge
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servy.PledgeServer
#
# PledgeServer.start()
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# PledgeServer.clear()
# IO.inspect(PledgeServer.create_pledge("grace", 50))
# IO.inspect(PledgeServer.total_pledged())
