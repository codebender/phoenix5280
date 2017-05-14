defmodule Fitbit do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def user_profile() do
    GenServer.call(__MODULE__, {:user_profile})
  end

  def user_badges() do
    GenServer.call(__MODULE__, {:user_badges})
  end

  def lifetime_stats() do
    GenServer.call(__MODULE__, {:lifetime_stats})
  end

  def init(:ok) do
    {:ok, nil}
  end

  def handle_call({:user_profile}, _from, _state) do
    {:reply, {:ok, Fitbit.User.profile()}, nil}
  end

  def handle_call({:user_badges}, _from, _state) do
    {:reply, {:ok, Fitbit.Badge.all_grouped()}, nil}
  end

  def handle_call({:lifetime_stats}, _from, _state) do
    {:reply, {:ok, Fitbit.Lifetime.stats()}, nil}
  end

end
