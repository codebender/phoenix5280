defmodule Web5280.PageController do
  use Web5280.Web, :controller

  def index(conn, _params) do
    {:ok, blog_posts} = Blog.list()
    render conn, "index.html", blog_posts: blog_posts
  end
end
