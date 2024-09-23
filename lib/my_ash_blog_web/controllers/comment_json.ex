defmodule MyAshBlogWeb.CommentJSON do
  alias MyAshBlog.Blog.Comment

  def render("index.json", %{comments: comments}) do
    %{data: Enum.map(comments, &comment_to_json/1)}
  end

  def render("show.json", %{comment: comment}) do
    %{data: comment_to_json(comment)}
  end

  defp comment_to_json(%Comment{id: id, author: author, content: content}) do
    %{
      id: id,
      author: author,
      content: content
    }
  end
end
