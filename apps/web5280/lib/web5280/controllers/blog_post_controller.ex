defmodule Web5280.BlogPostController do
  use Web5280, :controller

  def show(conn, %{"slug" => slug}) do
    case Blog.get_by_slug(slug) do
      {:ok, post} -> render conn, "show.html", post: post
      :not_found -> not_found(conn)
    end
  end

  def not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(Web5280.ErrorView, "404.html")
  end
end
