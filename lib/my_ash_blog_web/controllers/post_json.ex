defmodule MyAshBlogWeb.PostJSON do
  alias MyAshBlog.Blog.Post

  def render("index.json", %{posts: posts}) do
    %{data: Enum.map(posts, &post_to_json/1)}
  end

  def render("show.json", %{post: post}) do
    %{data: post_to_json(post)}
  end

  defp post_to_json(%Post{id: id, title: title, content: content}) do
    %{
      id: id,
      title: title,
      content: content
    }
  end
end
