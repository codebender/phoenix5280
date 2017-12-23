defmodule Fitbit.Lifetime do
  alias Fitbit.HttpClient
  alias Fitbit.Utils

  defstruct [
    :best_steps, :best_steps_date, :best_distance, :best_distance_date,
    :best_floors, :best_floors_date, :total_steps, :total_distance,
    :total_floors
  ]

  @type t :: %__MODULE__{
    best_steps: binary, best_steps_date: binary, best_distance: binary,
    best_distance_date: binary, best_floors: binary,
    best_floors_date: binary, total_steps: binary, total_distance: binary,
    total_floors: binary
  }

  def stats do
    case HttpClient.user_request("activities") do
      {:ok, body} ->
        body |> parse_lifetime_stats
      error ->
        error
    end
  end

  defp parse_lifetime_stats(lifetime_stats) do
    %__MODULE__{
      best_steps: Utils.delimit(lifetime_stats["best"]["total"]["steps"]["value"], 0),
      best_steps_date: Utils.display_date(lifetime_stats["best"]["total"]["steps"]["date"]),
      best_distance: Utils.delimit(lifetime_stats["best"]["total"]["distance"]["value"], 2),
      best_distance_date: Utils.display_date(lifetime_stats["best"]["total"]["distance"]["date"]),
      best_floors: Utils.delimit(lifetime_stats["best"]["total"]["floors"]["value"], 0),
      best_floors_date: Utils.display_date(lifetime_stats["best"]["total"]["floors"]["date"]),
      total_steps: Utils.delimit(lifetime_stats["lifetime"]["total"]["steps"], 0),
      total_distance: Utils.delimit(lifetime_stats["lifetime"]["total"]["distance"], 2),
      total_floors: Utils.delimit(lifetime_stats["lifetime"]["total"]["floors"], 0),
    }
  end
end
