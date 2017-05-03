defmodule Phoenix5280.Blog do
  use GenServer

  alias Phoenix5280.BlogPost

  @blog_directory "priv/blog"

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def list() do
    GenServer.call(__MODULE__, {:list})
  end

  def get_by_slug(slug) do
    GenServer.call(__MODULE__, {:get_by_slug, slug})
  end

  def init(:ok) do
    posts = crawl()
    {:ok, posts}
  end

  def handle_call({:list}, _from, posts) do
    {:reply, {:ok, posts}, posts}
  end

  def handle_call({:get_by_slug, slug}, _from, posts) do
    case Enum.find(posts, fn(x) -> x.slug == slug end) do
      nil -> {:reply, :not_found, posts}
      post -> {:reply, {:ok, post}, posts}
    end
  end

  def blog_directory do
    @blog_directory
  end

  defp crawl do
    blog_directory()
    |> File.ls!
    |> Enum.map(&BlogPost.compile/1)
    |> Enum.sort(&sort/2)
  end

  defp sort(a, b) do
    Calendar.Date.diff(a.created_at, b.created_at) > 0
  end
end
