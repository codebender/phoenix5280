defmodule Phoenix5280.PageController do
  use Phoenix5280.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
