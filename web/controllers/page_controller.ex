defmodule Phoenix5280.PageController do
  use Phoenix5280.Web, :controller

  def index(conn, _params) do
    {:ok, blog_posts} = Phoenix5280.Blog.list()
    render conn, "index.html", blog_posts: blog_posts
  end
end
