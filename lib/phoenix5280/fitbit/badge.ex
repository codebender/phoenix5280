defmodule Phoenix5280.Fitbit.Badge do
  alias Phoenix5280.Fitbit

  defstruct [
    :category, :name, :date_earned, :image_url, :times_achieved,
    :description, :value
  ]

  @type t :: %__MODULE__{
    category: binary, name: binary, image_url: binary,
    times_achieved: integer, description: binary, value: integer
  }

  def all(user_token) do
    case Fitbit.user_request(:get, "badges", user_token) do
      {:ok, body} ->
        body["badges"] |> parse_badges
      error ->
        error
    end
  end

  def all_grouped(user_token) do
    all(user_token)
    |> Enum.sort_by(fn x -> x.value end)
    |> Enum.group_by(fn x -> x.category end)
  end


  defp parse_badges(badges) do
    Enum.map(badges, fn(badge) ->
      %Phoenix5280.Fitbit.Badge{
        category: badge["category"],
        name: badge["shortName"],
        image_url: badge["image125px"],
        times_achieved: badge["timesAchieved"],
        description: badge["description"],
        value: badge["value"]
      }
    end)
  end
end
