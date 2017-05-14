defmodule Blog5280.Blog do

  alias Blog5280.BlogPost

  @blog_directory "apps/blog5280/priv/blog"

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
