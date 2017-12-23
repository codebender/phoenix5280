defmodule Blog.BlogPost do
  defstruct [
    :slug, :title, :intro, :created_at, :content
  ]

  @type t :: %__MODULE__{
    slug: binary, title: binary, intro: binary, created_at: binary,
    content: binary
  }

  def compile(file) do
    post = %__MODULE__{
      slug: file_to_slug(file)
    }

    Path.join([Blog.blog_directory(), file])
    |> File.read!
    |> split
    |> extract(post)
  end

  defp file_to_slug(file) do
    String.replace(file, ~r/\.md$/, "")
  end

  defp split(data) do
    [frontmatter, markdown] = String.split(data, ~r/\n-{3,}\n/, parts: 2)
    {parse_yaml(frontmatter), Earmark.as_html!(markdown)}
  end

  defp parse_yaml(yaml) do
    [parsed] = :yamerl_constr.string(yaml)
    parsed
  end

  defp extract({props, content}, post) do
    %{post |
      title: get_prop(props, "title"),
      intro: get_prop(props, "intro"),
      created_at: get_prop(props, "created_at") |> Date.from_iso8601!,
      content: content}
  end

  defp get_prop(props, key) do
    case :proplists.get_value(String.to_char_list(key), props) do
      :undefined -> nil
      x -> to_string(x)
    end
  end
end
