defmodule Web5280.Router do
  use Web5280.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Web5280 do
    pipe_through :browser # Use the default browser stack

    get "/blog_posts/:slug", BlogPostController, :show
    get "/fitbit", FitbitController, :show

    get "/", PageController, :index
  end
end