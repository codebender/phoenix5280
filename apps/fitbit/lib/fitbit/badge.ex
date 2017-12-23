defmodule Fitbit.Badge do
  alias Fitbit.HttpClient

  defstruct [
    :category, :name, :date_earned, :image_url, :times_achieved,
    :description, :value
  ]

  @type t :: %__MODULE__{
    category: binary, name: binary, image_url: binary,
    times_achieved: integer, description: binary, value: integer
  }

  def all do
    case HttpClient.user_request("badges") do
      {:ok, body} ->
        body["badges"] |> parse_badges
      error ->
        error
    end
  end

  def all_grouped do
    all()
    |> Enum.sort_by(fn x -> x.value end)
    |> Enum.group_by(fn x -> x.category end)
  end


  defp parse_badges(badges) do
    Enum.map(badges, fn(badge) ->
      %__MODULE__{
        category: badge["category"],
        name: badge["shortName"],
        image_url: badge["image125px"],
        times_achieved: badge["timesAchieved"],
        description: badge["description"],
        value: badge["value"],
        date_earned: badge["dateTime"]
      }
    end)
  end
end
