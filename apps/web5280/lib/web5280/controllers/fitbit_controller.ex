defmodule Web5280.FitbitController do
  use Web5280, :controller

  def show(conn, _params) do
    { :ok, user } = Fitbit.user_profile()
    { :ok, badges } = Fitbit.user_badges()
    { :ok, lifetime } = Fitbit.lifetime_stats()

    render(conn, "show.html", user: user, badges: badges, lifetime: lifetime)
  end
end
