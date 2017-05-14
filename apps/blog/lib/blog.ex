defmodule Blog do
  use GenServer

  alias Blog.BlogPost

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
    posts = Blog.crawl()
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

  @blog_directory "apps/blog/priv/blog"

  def crawl do
    blog_directory()
    |> File.ls!
    |> Enum.map(&BlogPost.compile/1)
    |> Enum.sort(&sort/2)
  end

  def blog_directory do
    @blog_directory
  end

  defp sort(a, b) do
    Date.compare(a.created_at, b.created_at) == :gt
  end
end
