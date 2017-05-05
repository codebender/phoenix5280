defmodule Web5280.FitbitController do
  use Web5280.Web, :controller

  alias Web5280.Fitbit

  def show(conn, _params) do
    user = Fitbit.User.profile(Fitbit.token)
    badges = Fitbit.Badge.all_grouped(Fitbit.token)
    lifetime = Fitbit.Lifetime.stats(Fitbit.token)

    render(conn, "show.html", user: user, badges: badges, lifetime: lifetime)
  end
end
