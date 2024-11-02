defmodule Servy.PledgeServer do
  @server_name :pledge_server

  # Client
  def start() do
    # Starts the server with an empty state
    IO.puts("Starting the Pledge Server...")
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @server_name)
    pid
  end

  def create_pledge(name, amount) do
    # Sends the pledge to the external service and caches it
    # pledge = %{name: name, amount: amount}
    # IO.inspect(pledge)
    send(@server_name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges() do
    send(@server_name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@server_name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server
  def listen_loop(state) do
    # Listens for incoming requests
    IO.puts("Waiting for a message...")

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent]
        send(sender, {:response, id})
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        # IO.puts("Sending recent pledges to #{inspect(sender)}...")
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledged} ->
        # IO.puts("Sending recent pledges to #{inspect(sender)}...")
        total = Enum.map(state, fn {_, amount} -> amount end) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  def send_pledge_to_service(_name, _amount) do
    # Sends the pledge to the external service
    # and returns the ID of the created pledge
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servy.PledgeServer
##
# PledgeServer.start()
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))
#
# IO.inspect(PledgeServer.total_pledged())
