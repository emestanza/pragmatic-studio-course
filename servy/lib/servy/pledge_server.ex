defmodule Servy.PledgeServer do
  @server_name :pledge_server

  use GenServer, restart: :temporary

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client
  def start_link(_args) do
    IO.puts("Starting the pledge server...")
    GenServer.start_link(__MODULE__, %State{}, name: @server_name)
  end

  def create_pledge(name, amount) do
    # Sends the pledge to the external service and caches it
    # pledge = %{name: name, amount: amount}
    # IO.inspect(pledge)
    GenServer.call(@server_name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@server_name, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@server_name, :total_pledged)
  end

  def clear() do
    GenServer.cast(@server_name, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast(@server_name, {:set_cache_size, size})
  end

  # Server Callbacks
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, fn {_, amount} -> amount end) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    {:noreply, %{state | cache_size: size}}
  end

  def handle_info(msg, state) do
    IO.inspect("Can't handle this message: #{msg}")
    {:noreply, state}
  end

  def send_pledge_to_service(_name, _amount) do
    # Sends the pledge to the external service
    # and returns the ID of the created pledge
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end
end

# alias Servy.PledgeServer
#
# {:ok, pid} = PledgeServer.start()
# PledgeServer.clear()
# PledgeServer.set_cache_size(4)
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))
# IO.inspect(PledgeServer.total_pledged())
